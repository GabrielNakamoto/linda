// NOTE: centralized import so duplicates don't get opaque struct errors
// between modules due to zig interop
pub const imports = @cImport({
	// llvm CAPI
  @cInclude("llvm-c/Core.h");
  @cInclude("llvm-c/Target.h");
  @cInclude("llvm-c/TargetMachine.h");
  @cInclude("llvm-c/Analysis.h");
  @cInclude("llvm-c/Transforms/PassBuilder.h");

	// mlir CAPI
  @cInclude("mlir-c/RegisterEverything.h");
  @cInclude("mlir-c/IR.h");
  @cInclude("mlir-c/Target/LLVMIR.h");
  @cInclude("mlir-c/BuiltinTypes.h");
  @cInclude("mlir-c/BuiltinAttributes.h");
  @cInclude("mlir-c/Dialect/Bufferization.h");
  @cInclude("mlir-c/Dialect/Affine.h");
  @cInclude("mlir-c/Dialect/GPU.h");
  @cInclude("mlir-c/Dialect/NVVM.h");
  @cInclude("mlir-c/Conversion.h");
  @cInclude("mlir-c/Dialect/Func.h");

	// custom mlir CAPI
  @cInclude("linda-c/Passes.h");
  @cInclude("linda-c/Dialect.h");
});

