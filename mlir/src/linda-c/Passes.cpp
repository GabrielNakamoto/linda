#include "linda/Passes.h"
#include "linda-c/Passes.h"
#include "mlir/CAPI/Pass.h"

#ifdef __cplusplus
extern "C" {
#endif

MlirPass mlirCreateLindaLowerToAffinePass() { return wrap(linda::createLowerToAffinePass().release()); }
MlirPass mlirCreateLindaLowerToLLVMPass() { return wrap(linda::createLowerToLLVMPass().release()); }

#ifdef __cplusplus
}
#endif
