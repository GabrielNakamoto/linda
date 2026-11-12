#include "linda/Dialect.h"
#include "mlir/IR/OpImplementation.h"
#include "linda/Dialect.cpp.inc"

void linda::LindaDialect::initialize() {
  addOperations<
  #define GET_OP_LIST
  #include "linda/Ops.cpp.inc"
    >();
}

#define GET_OP_CLASSES
#include "linda/Ops.cpp.inc"
