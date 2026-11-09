set(LLVM_TARGET_DEFINITIONS linda/Linda.td)

mlir_tablegen(linda/Ops.h.inc -gen-op-decls)
mlir_tablegen(linda/Ops.cpp.inc -gen-op-defs)
mlir_tablegen(linda/Dialect.h.inc -gen-dialect-decls)
mlir_tablegen(linda/Dialect.cpp.inc -gen-dialect-defs)

add_public_tablegen_target(LindaIncGen)
