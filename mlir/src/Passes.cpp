#include "mlir/IR/BuiltinDialect.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/BuiltinTypes.h"
#include "linda/Dialect.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Memref/IR/MemRef.h"

#include <memory>


using namespace mlir;

static MemRefType convertTensorToMemRef(RankedTensorType type) {
  return MemRefType::get(type.getShape(), type.getElementType());
}

static Value insertAllocAndDealloc(MemRefType type, Location loc, PatternRewriter &rewriter) {
  auto alloc = memref::AllocOp::create(rewriter, loc, type);

  auto *parentBlock = alloc->getBlock();
  alloc->moveBefore(&parentBlock->front());

  auto dealloc = memref::DeallocOp::create(rewriter, loc, alloc);
  dealloc->moveBefore(&parentBlock->back());
  return alloc;
}

using LoopIterationFn = function_ref<Value(OpBuilder &rewriter, ValueRange loopIvs)>;

static void lowerOpToLoops(Operation *op, PatternRewriter &rewriter, LoopIterationFn processIteration) {
  auto tensorType = llvm::cast<RankedTensorType>((*op->result_type_begin()));
  auto loc = op->getLoc();

  auto memRefType = convertTensorToMemRef(tensorType);
  auto alloc = insertAllocAndDealloc(memRefType, loc, rewriter);

  SmallVector<int64_t, 4> lowerBounds(tensorType.getRank(), 0);
  SmallVector<int64_t, 4> steps(tensorType.getRank(), 1);
  affine::buildAffineLoopNest(
    rewriter, loc, lowerBounds, tensorType.getShape(), steps,
    [&](OpBuilder &nestedBuilder, Location loc, ValueRange ivs){
      Value valueToStore = processIteration(nestedBuilder, ivs);
      affine::AffineStoreOp::create(nestedBuilder, loc, valueToStore, alloc, ivs);
    }
  );

  rewriter.replaceOp(op, alloc);
}

namespace {

struct LowerToAffinePass
  : public PassWrapper<LowerToAffinePass, OperationPass<ModuleOp>> {

  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(LowerToAffinePass)

  StringRef getArgument() const override { return "linda-to-affine"; }

  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<affine::AffineDialect, arith::ArithDialect, memref::MemRefDialect>();
  }

  void runOnOperation() final;
};

}

void LowerToAffinePass::runOnOperation() {
  ConversionTarget target(getContext());

  target.addLegalDialect<affine::AffineDialect, BuiltinDialect, arith::ArithDialect, memref::MemRefDialect>();
  target.addIllegalDialect<linda::LindaDialect>();

  RewritePatternSet patterns(&getContext());

  patterns.add<>();

  if (failed(
    applyPartialConversion(getOperation(), target, std::move(patterns))))
    signalPassFailure();
}


std::unique_ptr<mlir::Pass> createLowerToAffinePass() {
  return std::make_unique<LowerToAffinePass>();
}
