#ifndef LINDA_DIALECT_H
#define LINDA_DIALECT_H

#include "mlir/IR/Builders.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/Dialect.h"

#include "linda/Dialect.h.inc"

#define GET_OP_CLASSES
#include "linda/Ops.h.inc"

#endif
