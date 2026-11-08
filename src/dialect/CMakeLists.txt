# Auto-generates c++ headers/impls of custom tablegen dialect/op descriptions

set(LLVM_TARGET_DEFINITIONS linda.td)
mlir_tablegen(linda-ops.h.inc --gen-op-decls)
mlir_tablegen(linda-ops.cpp.inc --gen-op-defs)
mlir_tablegen(linda-dialect.h.inc, --gen-dialect-decls)
mlir_tablegen(linda-dialect.cpp.inc, --gen-dialect-defs)
add_public_tablegen_target(LindaIncGen)

add_mlir_dialect_library(
)
