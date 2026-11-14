const std = @import("std");
const c = @import("capi.zig").imports;
const helpers = @import("helpers.zig");

const Arch = enum { NV, AMD };

pub const Accelerator = struct {
  arch: Arch,
  triple: []const u8,
  cpu: []const u8
};

pub const RDNA3: Accelerator = .{ .arch = .AMD, .triple = "amdgcn-amd-amdhsa", .cpu = "gfx1100" };
pub const NVPTX: Accelerator = .{ .arch = .NV, .triple = "nvptx-nvidia-cuda", .cpu = "sm_120" };

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

pub fn compileKernelModule(mlirCtx: c.MlirContext, mlirModule: c.MlirModule, arch: Accelerator, debug: bool) ![]const u8 {
  _ = arch;
  const pm = c.mlirPassManagerCreate(mlirCtx);
  //const gpuToArchPass = switch (arch.arch) {
    //.NV => c.mlirCreateConversionConvertGpuOpsToNVVMOps(),
    //.AMD => c.mlirCreateConversionConvertGpuOpsToROCDLOps()
  //};
  if (debug) {
    c.mlirPassManagerEnableIRPrinting(
      pm, true, true, true, false, false, c.mlirOpPrintingFlagsCreate(), helpers.stringRef("dump/")
    );
  }

  const rootPm = c.mlirPassManagerGetAsOpPassManager(pm);
  // https://mlir.llvm.org/docs/Dialects/GPU/#compilation-overview
  helpers.mlirAssertGood(c.mlirOpPassManagerAddPipeline(rootPm,
    helpers.stringRef(
    \\nvvm-attach-target{chip=sm_120},
    \\gpu.module(lower-affine, convert-scf-to-cf, convert-gpu-to-nvvm, reconcile-unrealized-casts),
    \\gpu-to-llvm,
    \\gpu-module-to-binary{format=assembly}
    ), helpers.pipelineDiagnostic, null));

  helpers.mlirAssertGood(c.mlirPassManagerRunOnOp(pm, c.mlirModuleGetOperation(mlirModule)));

  const ptx = try extractGpuBinary(mlirModule);
  const slice = ptx.data[0..ptx.length];

  if (debug) {
    c.mlirOperationDump(c.mlirModuleGetOperation(mlirModule));
    std.debug.print("{s}\n", .{slice});
  }

  return slice;
}
