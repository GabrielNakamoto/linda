#ifndef LINDA_PASSES_H
#define LINDA_PASSES_H

#include <memory>

namespace mlir {
class Pass;
}

namespace linda {

std::unique_ptr<mlir::Pass> createLowerToAffinePass();
// std::unique_ptr<mlir::Pass> createLowerToLLVMIRPass();

}

#endif
