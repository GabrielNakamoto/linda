const std = @import("std");
const c = @import("capi.zig").imports;

pub const Accelerator = struct {
  triple: []const u8,
  cpu: []const u8
};

pub const RDNA3: Accelerator = .{ .triple = "amdgcn-amd-amdhsa", .cpu = "gfx1100" };
pub const NVIDIA: Accelerator = .{ .triple = "nvptx-nvidia-cuda", .cpu = "sm60" };

pub fn compileKernelModule(module: c.LLVMModuleRef, arch: Accelerator, debug: bool) !void {
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

  // run final llvmir optimization passes
  const options = c.LLVMCreatePassBuilderOptions();
  c.LLVMPassBuilderOptionsSetVerifyEach(options, 1);
  _ = c.LLVMRunPasses(module, "default<O2>", machine, options);

  // emit kernel asm as binary image
  // - probably want to store in memory buffer?
  // - how to call ROCM with host buffer ptrs, issue DMA or memory requests etc..
  if (debug) {
    _ = c.LLVMTargetMachineEmitToFile(machine, module, "dump/kernel.s", c.LLVMAssemblyFile, @ptrCast(&msg));
  }
}

