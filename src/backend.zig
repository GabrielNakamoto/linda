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

pub fn compileKernelModule(mlirCtx: c.MlirContext, mlirModule: c.MlirModule, arch: Accelerator, debug: bool) !c.LLVMMemoryBufferRef {
  // (1) finish converting gpu mlir diaslect to target specific host/device binaries
  // and kernel launches; NVVM for ptx, ROCDL for AMD
  const pm = c.mlirPassManagerCreate(mlirCtx);
  //const gpuToArchPass = switch (arch.arch) {
    //.NV => c.mlirCreateConversionConvertGpuOpsToNVVMOps(),
    //.AMD => c.mlirCreateConversionConvertGpuOpsToROCDLOps()
  //};

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

  c.mlirOperationDump(c.mlirModuleGetOperation(mlirModule));

  const ctx = c.LLVMContextCreate();
  defer c.LLVMContextDispose(ctx);
  const module = c.mlirTranslateModuleToLLVMIR(c.mlirModuleGetOperation(mlirModule), ctx);

	c.LLVMInitializeAllTargets();
	c.LLVMInitializeAllTargetMCs();
	c.LLVMInitializeAllTargetInfos();
	c.LLVMInitializeAllAsmPrinters();
	c.LLVMInitializeAllAsmParsers();

  var target: c.LLVMTargetRef = null;
  var msg = "";
  _ = c.LLVMGetTargetFromTriple(@ptrCast(arch.triple), &target, @ptrCast(&msg));
  const machine = c.LLVMCreateTargetMachine(target, @ptrCast(arch.triple), @ptrCast(arch.cpu), "",
    c.LLVMCodeGenLevelDefault, c.LLVMRelocDefault, c.LLVMCodeModelDefault);
  const layout = c.LLVMCreateTargetDataLayout(machine);

  // configure module
  c.LLVMSetTarget(module, @ptrCast(arch.triple));
  c.LLVMSetModuleDataLayout(module, layout);

  if (debug) _ = c.LLVMPrintModuleToFile(module, "dump/kernel.ll", @ptrCast(&msg));

  // (2) run final llvmir optimization passes
  const options = c.LLVMCreatePassBuilderOptions();
  c.LLVMPassBuilderOptionsSetVerifyEach(options, 1);
  _ = c.LLVMRunPasses(module, "default<O2>", machine, options);

  if (debug) {
    _ = c.LLVMPrintModuleToFile(module, "dump/kernel-opt.ll", @ptrCast(&msg));
    _ = c.LLVMTargetMachineEmitToFile(machine, module, "dump/kernel.s", c.LLVMAssemblyFile, @ptrCast(&msg));
  }

  var buffer: c.LLVMMemoryBufferRef = null;
  _ = c.LLVMTargetMachineEmitToMemoryBuffer(machine, module, c.LLVMAssemblyFile, @ptrCast(&msg), &buffer);
  return buffer;
}
