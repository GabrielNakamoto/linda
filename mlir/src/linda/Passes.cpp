#include "linda/Dialect.h"
#include "linda/Passes.h"

#include "mlir/IR/BuiltinDialect.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Transforms/DialectConversion.h"

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/ControlFlow/IR/ControlFlow.h"

#include "mlir/Conversion/LLVMCommon/TypeConverter.h"
#include "mlir/Conversion/LLVMCommon/ConversionTarget.h"
#include "mlir/Conversion/AffineToStandard/AffineToStandard.h"
#include "mlir/Conversion/ArithToLLVM/ArithToLLVM.h"
#include "mlir/Conversion/SCFToControlFlow/SCFToControlFlow.h"
#include "mlir/Conversion/MemRefToLLVM/MemRefToLLVM.h"
#include "mlir/Conversion/FuncToLLVM/ConvertFuncToLLVM.h"
#include "mlir/Conversion/ControlFlowToLLVM/ControlFlowToLLVM.h"

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

using LoopIterationFn = function_ref<Value(OpBuilder &rewriter, ValueRange memRefOperands, ValueRange loopIvs)>;

static void lowerOpToLoops(Operation *op, ValueRange operands, PatternRewriter &rewriter, LoopIterationFn processIteration) {
  auto tensorType = llvm::cast<RankedTensorType>((*op->result_type_begin()));
  auto loc = op->getLoc();

  auto memRefType = convertTensorToMemRef(tensorType);
  auto alloc = insertAllocAndDealloc(memRefType, loc, rewriter);

  SmallVector<int64_t, 4> lowerBounds(tensorType.getRank(), 0);
  SmallVector<int64_t, 4> steps(tensorType.getRank(), 1);
  affine::buildAffineLoopNest(
    rewriter, loc, lowerBounds, tensorType.getShape(), steps,
    [&](OpBuilder &nestedBuilder, Location loc, ValueRange ivs){
      Value valueToStore = processIteration(nestedBuilder, operands, ivs);
      affine::AffineStoreOp::create(nestedBuilder, loc, valueToStore, alloc, ivs);
    }
  );

  rewriter.replaceOp(op, alloc);
}

// **** Op Specific Rewrite Patterns ****
namespace {

struct ToTensorLowering : OpConversionPattern<bufferization::ToTensorOp> {
  using OpConversionPattern::OpConversionPattern;

  LogicalResult matchAndRewrite(bufferization::ToTensorOp op, OpAdaptor adaptor,
    ConversionPatternRewriter &rewriter) const override {
    rewriter.replaceOp(op, adaptor.getBuffer());
    return success();
  }
};

template <typename BinaryOp, typename LoweredBinaryOp>
struct BinaryOpLowering : public ConversionPattern {
  BinaryOpLowering(TypeConverter &typeConverter, MLIRContext *ctx)
    : ConversionPattern(typeConverter, BinaryOp::getOperationName(), 1, ctx) {}

  LogicalResult
  matchAndRewrite(Operation *op, ArrayRef<Value> operands,
                  ConversionPatternRewriter &rewriter) const final {
    auto loc = op->getLoc();
    lowerOpToLoops(op, operands, rewriter,
          [loc](OpBuilder &builder, ValueRange memRefOperands, ValueRange loopIvs) {
            typename BinaryOp::Adaptor binaryAdaptor(memRefOperands);

            // load both tensor buffers from memory in affine loop and apply binop
            auto loadedLhs = builder.create<affine::AffineLoadOp>(
              loc, binaryAdaptor.getLhs(), loopIvs);
            auto loadedRhs = builder.create<affine::AffineLoadOp>(
              loc, binaryAdaptor.getRhs(), loopIvs);

            return builder.create<LoweredBinaryOp>(
              loc, loadedLhs, loadedRhs);
          });
    return success();
  }
};

using AddOpLowering = BinaryOpLowering<linda::AddOp, arith::AddFOp>;
using MulOpLowering = BinaryOpLowering<linda::MulOp, arith::MulFOp>;

}

namespace {

struct LowerToAffinePass
  : public PassWrapper<LowerToAffinePass, OperationPass<ModuleOp>> {

  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(LowerToAffinePass)

  StringRef getArgument() const override { return "linda-to-affine"; }

  void getDependentDialects(DialectRegistry &registry) const override {
    registry.insert<affine::AffineDialect, arith::ArithDialect, memref::MemRefDialect, bufferization::BufferizationDialect>();
  }

  void runOnOperation() final;
};


struct LowerToLLVMPass
  : public PassWrapper<LowerToLLVMPass, OperationPass<ModuleOp>> {

    MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(LowerToLLVMPass)

    StringRef getArgument() const override { return "affine-to-llvm"; }

    void getDependentDialects(DialectRegistry &registry) const override {
      registry.insert<LLVM::LLVMDialect, scf::SCFDialect, cf::ControlFlowDialect>();
    }

  	void runOnOperation() final;
};

}

void LowerToAffinePass::runOnOperation() {
  ConversionTarget target(getContext());

  target.addLegalDialect<affine::AffineDialect, BuiltinDialect, arith::ArithDialect, memref::MemRefDialect>();
  target.addIllegalDialect<linda::LindaDialect>();
  target.addIllegalOp<bufferization::ToTensorOp>();

  RewritePatternSet patterns(&getContext());

  TypeConverter typeConverter;

  typeConverter.addConversion([](Type type) { return type; });
  typeConverter.addConversion([](RankedTensorType type) -> Type {
    return MemRefType::get(type.getShape(), type.getElementType());
  });

  // register all rewrite pass patterns here
  patterns.add<AddOpLowering, MulOpLowering, ToTensorLowering>(typeConverter, &getContext());

  if (failed(
    applyPartialConversion(getOperation(), target, std::move(patterns))))
    signalPassFailure();
}

void LowerToLLVMPass::runOnOperation() {
  LLVMConversionTarget target(getContext());

  target.addLegalOp<mlir::ModuleOp>();

  LLVMTypeConverter typeConverter(&getContext());

  RewritePatternSet patterns(&getContext());
  populateAffineToStdConversionPatterns(patterns);
  populateSCFToControlFlowConversionPatterns(patterns);
  arith::populateArithToLLVMConversionPatterns(typeConverter, patterns);
  populateFinalizeMemRefToLLVMConversionPatterns(typeConverter, patterns);
  cf::populateControlFlowToLLVMConversionPatterns(typeConverter, patterns);
  populateFuncToLLVMConversionPatterns(typeConverter, patterns);

	if (failed(
		applyFullConversion(getOperation(), target, std::move(patterns))))
		signalPassFailure();
}

std::unique_ptr<mlir::Pass> linda::createLowerToAffinePass() {
  return std::make_unique<LowerToAffinePass>();
}

std::unique_ptr<mlir::Pass> linda::createLowerToLLVMPass() {
  return std::make_unique<LowerToLLVMPass>();
}
