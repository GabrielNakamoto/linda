const std = @import("std");
const c = @import("../capi.zig").imports;

// For a launchable kernel, your entry function must also use the AMDGPU kernel calling convention and a
// GPU-compatible argument/address-space ABI. A normal C-style llvm.func @kernel may compile,
// but it will not automatically become a launchable HSA kernel.
pub fn compileKernelToAsm(module: c.LLVMModuleRef) !void {
  c.LLVMInitializeAllTargets();
  c.LLVMInitializeAllTargetMCs();
  c.LLVMInitializeAllTargetInfos();
  c.LLVMInitializeAllAsmPrinters();
  c.LLVMInitializeAllAsmParsers();

  var target: c.LLVMTargetRef = null;
  const triple = "amdgcn-amd-amdhsa";

  {
    var msg = "";
    _ = c.LLVMGetTargetFromTriple(triple, &target, @ptrCast(&msg));
  }

  const machine = c.LLVMCreateTargetMachine(
    target, triple, "gfx1100", "",
    c.LLVMCodeGenLevelDefault, c.LLVMRelocDefault, c.LLVMCodeModelDefault
  );
  const layout = c.LLVMCreateTargetDataLayout(machine);

  // configure module
  c.LLVMSetTarget(module, triple);
  c.LLVMSetModuleDataLayout(module, layout);

  // TODO: run final IR optimization passes

  // emit kernel asm as binary image
  {
    var msg = "";
    _ = c.LLVMTargetMachineEmitToFile(machine, module, "dump/kernel.s", c.LLVMAssemblyFile, @ptrCast(&msg));
  }
}
