// MLIR Tablegen include wrapper

#ifndef LINDA_DIALECT_H
#define LINDA_DIALECT_H

#include "mlir/IR/Dialect.h"
#include "mlir/IR/SymbolTable.h"


#include "linda-dialect.h.inc"

#define GET_OP_CLASSES
#include "linda-ops.h.inc"

#endif
