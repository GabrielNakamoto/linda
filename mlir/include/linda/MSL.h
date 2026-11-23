#pragma once

#include "mlir/Support/LogicalResult.h"

namespace llvm {
class raw_ostream;
}

namespace mlir{
class ModuleOp;
}

namespace linda {

mlir::LogicalResult translateToMSL(mlir::ModuleOp module, llvm::raw_ostream &output);
void registerMSLTranslation();

}
