#include "mlir/CAPI/Registration.h"
#include "linda-c/Dialect.h"
#include "linda/Dialect.h"

MLIR_DEFINE_CAPI_DIALECT_REGISTRATION(
  Linda, linda, linda::LindaDialect)
