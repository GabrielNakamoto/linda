#ifndef LINDA_C_PASSES_H
#define LINDA_C_PASSES_H

#include "mlir-c/Pass.h"
#include "mlir-c/Support.h"

#ifdef __cplusplus
extern "C" {
#endif

MLIR_CAPI_EXPORTED MlirPass mlirCreateLindaLowerToAffinePass(void);

#ifdef __cplusplus
}
#endif

#endif
