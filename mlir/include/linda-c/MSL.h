#ifndef LINDA_MSL_H
#define LINDA_MSL_H

#include "mlir-c/IR.h"
#include "mlir-c/Support.h"

#ifdef __cplusplus
extern "C" {
#endif

MLIR_CAPI_EXPORTED char *mlirLindaTranslateModuleToMSL(MlirModule module);

#ifdef __cplusplus
}
#endif

#endif
