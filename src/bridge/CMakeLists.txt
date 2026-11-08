set(LLVM_TARGET_DEFINITIONS linda.td)

mlir_tablegen(LindaOps.h.inc -gen-op-decls)
mlir_tablegen(LindaOps.cpp.inc -gen-op-defs)
mlir_tablegen(LindaDialect.h.inc -gen-dialect-decls)
mlir_tablegen(LindaDialect.cpp.inc -gen-dialect-defs)
add_public_tablegen_target(LindaIncGen)

add_mlir_dialect_library(MLIRLinda
  Dialect.cpp
)
