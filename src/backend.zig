const std = @import("std");
const c = @import("capi.zig").imports;

pub const Accelerator = struct {
  triple: []const u8,
  cpu: []const u8
};

pub const RDNA3: Accelerator = .{ .triple = "amdgcn-amd-amdhsa", .cpu = "gfx1100" };
pub const NVIDIA: Accelerator = .{ .triple = "nvptx-nvidia-cuda", .cpu = "sm60" };

pub fn compileKernelModule(mlirModule: c.MlirModule, arch: Accelerator, debug: bool) !c.LLVMMemoryBufferRef {
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

  // run final llvmir optimization passes
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
