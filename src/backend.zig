const std = @import("std");
const c = @import("capi.zig").imports;
const helpers = @import("helpers.zig");

pub const Arch = enum { NV, METAL };

// TODO: pass sm version for ptx
pub fn compileKernel(io: std.Io, gpa: std.mem.Allocator, mlirCtx: c.MlirContext, mlirModule: c.MlirModule, arch: Arch, debug: bool) ![]const u8 {
  return switch (arch) {
    .NV => compilePTX(mlirCtx, mlirModule, debug),
    .METAL => compileMetal(io, gpa, mlirCtx, mlirModule, debug)
  };
}

// ********* METAL **********
fn compileMetal(io: std.Io, gpa: std.mem.Allocator, mlirCtx: c.MlirContext, mlirModule: c.MlirModule, debug: bool) ![]const u8 {
  // (1) need to lower affine -> scf first
  const pm = c.mlirPassManagerCreate(mlirCtx);
  const opPm = c.mlirPassManagerGetAsOpPassManager(pm);
  helpers.mlirAssertGood(c.mlirOpPassManagerAddPipeline(
    opPm, helpers.stringRef("gpu.module(lower-affine)"), helpers.pipelineDiagnostic, null));
  helpers.mlirAssertGood(c.mlirPassManagerRunOnOp(pm, c.mlirModuleGetOperation(mlirModule)));

  if (debug) c.mlirOperationDump(c.mlirModuleGetOperation(mlirModule));

  // (2)  Call custom MSL translation pass, converts gpu.func MLIR kernel IR representation
  //      to a valid, equivalent Metal Shader Language source string
  const raw = c.mlirLindaTranslateModuleToMSL(mlirModule) orelse return error.MSLTranslationFailed;
  defer std.c.free(raw);

  const kernel = try std.mem.replaceOwned(u8, gpa, std.mem.span(raw), "%", "_");
  if (debug) std.debug.print("{s}\n", .{kernel});

  // (3) compile string to .metallib binary loadable by swift runtime using child process call
  const argv = [_][]const u8{ "xcrun", "-sdk", "macosx", "metal", "-x", "metal", "-", "-o", "kernel.metallib" };
  var child = try std.process.spawn(io, .{ .argv = &argv, .stdin = .pipe, .stdout = .pipe, .stderr = .pipe });

  var stdin_buf: [2048]u8 = undefined;
  var stdin_writer = child.stdin.?.writerStreaming(io, &stdin_buf);
  try stdin_writer.interface.writeAll(kernel);
  try stdin_writer.interface.flush();
  child.stdin.?.close(io);
  child.stdin = null;

  var stderr_buf: [2048]u8 = undefined;
  var stderr_reader = child.stderr.?.readerStreaming(io, &stderr_buf);
  const stderr_output = try stderr_reader.interface.allocRemaining(gpa, .limited(64 * 1024));
  defer gpa.free(stderr_output);

  const term = try child.wait(io);

  switch (term) {
    .exited => |code| {
      if (code != 0) {
        std.debug.print("MSL Compile Exited with code: {d}\n{s}\n", .{code, stderr_output});
        return error.MSLCompileFailed;
      }
    },
    else => return error.MSLCompileFailed
  }

  return kernel;
}

// ********* NVIDIA **********
fn extractGpuBinary(module: c.MlirModule) !c.MlirStringRef {
  const moduleOp = c.mlirModuleGetOperation(module);
  const symbols = c.mlirSymbolTableCreate(moduleOp);
  defer c.mlirSymbolTableDestroy(symbols);

  const binary = c.mlirSymbolTableLookup(symbols, helpers.stringRef("linda_program_kernel"));
  if (c.mlirOperationIsNull(binary)) return error.GpuBinNotFound;

  const objects = c.mlirOperationGetInherentAttributeByName(binary, helpers.stringRef("objects"));
  const object = c.mlirArrayAttrGetElement(objects, 0);
  return c.mlirGPUObjectAttrGetObject(object);
}

fn compilePTX(mlirCtx: c.MlirContext, mlirModule: c.MlirModule, debug: bool) ![]const u8 {
  const pm = c.mlirPassManagerCreate(mlirCtx);

  if (debug) {
    c.mlirPassManagerEnableIRPrinting(
      pm, true, true, true, false, false, c.mlirOpPrintingFlagsCreate(), helpers.stringRef("dump/")
    );
  }

  const rootPm = c.mlirPassManagerGetAsOpPassManager(pm);
  // https://mlir.llvm.org/docs/Dialects/GPU/#compilation-overview
  helpers.mlirAssertGood(c.mlirOpPassManagerAddPipeline(rootPm,
    helpers.stringRef(
    \\nvvm-attach-target{chip=sm_86},
    \\gpu.module(
    \\  lower-affine,
    \\  convert-scf-to-cf,
    \\  convert-gpu-to-nvvm{use-bare-ptr-memref-call-conv=true},
    \\  reconcile-unrealized-casts),
    \\gpu-to-llvm,
    \\gpu-module-to-binary{format=assembly}
    ), helpers.pipelineDiagnostic, null));

  helpers.mlirAssertGood(c.mlirPassManagerRunOnOp(pm, c.mlirModuleGetOperation(mlirModule)));

  const ptx = try extractGpuBinary(mlirModule);
  const slice = ptx.data[0..ptx.length:0];

  if (debug) {
    c.mlirOperationDump(c.mlirModuleGetOperation(mlirModule));
    std.debug.print("{s}\n", .{slice});
  }

  return slice;
}

