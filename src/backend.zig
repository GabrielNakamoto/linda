const std = @import("std");
const c = @import("capi.zig").imports;
const helpers = @import("helpers.zig");

pub const Arch = enum { NV, METAL };

// TODO: pass sm version for ptx
pub fn compileKernel(mlirCtx: c.MlirContext, mlirModule: c.MlirModule, arch: Arch, debug: bool) ![]const u8 {
  return switch (arch) {
    .NV => compilePTX(mlirCtx, mlirModule, debug),
    .METAL => compileMetal(mlirCtx, mlirModule, debug)
  };
}

// ********* METAL **********
fn compileMetal(mlirCtx: c.MlirContext, mlirModule: c.MlirModule, debug: bool) ![]const u8 {
  // (1) need to lower affine -> scf first
  const pm = c.mlirPassManagerCreate(mlirCtx);
  const opPm = c.mlirPassManagerGetAsOpPassManager(pm);
  helpers.mlirAssertGood(c.mlirOpPassManagerAddPipeline(
    opPm, helpers.stringRef("gpu.module(lower-affine)"), helpers.pipelineDiagnostic, null));
  helpers.mlirAssertGood(c.mlirPassManagerRunOnOp(pm, c.mlirModuleGetOperation(mlirModule)));

  if (debug) {
    c.mlirOperationDump(c.mlirModuleGetOperation(mlirModule));
  }

  const raw = c.mlirLindaTranslateModuleToMSL(mlirModule) orelse return error.MSLTranslationFailed;
  std.debug.print("{s}", .{raw});

  // TODO: when does this get freed?
  return std.mem.span(raw);
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

