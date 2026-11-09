#include "linda/Dialect.h"
#include "linda-c/Dialect.h"
#include "mlir/CAPI/Registration.h"

#include "linda/Dialect.cpp.inc"

void linda::LindaDialect::initialize() {
  addOperations<
  #define GET_OP_LIST
  #include "linda/Ops.cpp.inc"
    >();
}

#define GET_OP_CLASSES
#include "linda/Ops.cpp.inc"

MLIR_DEFINE_CAPI_DIALECT_REGISTRATION(
  Linda, linda, linda::LindaDialect)
