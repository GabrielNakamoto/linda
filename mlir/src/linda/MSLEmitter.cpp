#include "linda/MSL.h"

#include "mlir/IR/AsmState.h"
#include "mlir/Tools/mlir-translate/Translation.h"
#include "mlir/IR/BuiltinDialect.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/ControlFlow/IR/ControlFlow.h"
#include "mlir/Dialect/GPU/IR/GPUDialect.h"
#include "mlir/Support/LogicalResult.h"
#include "llvm/Support/raw_ostream.h"

#include <memory>
#include <map>

using namespace mlir;

namespace {

class MSLEmitter {
public:
  MSLEmitter(llvm::raw_ostream &output);
  LogicalResult emitModule(gpu::GPUModuleOp gpuModule);

private:
  LogicalResult emitKernel(gpu::GPUFuncOp &op);
  LogicalResult emitOp(Operation &op, Operation *scopeOp, int depth);
  LogicalResult emitType(Value val);
  LogicalResult emitBinary(Operation *op, std::string _operator, AsmState &state);
  LogicalResult emitOffset(Operation::operand_range indices, llvm::ArrayRef<int64_t> shape, AsmState &state);

  llvm::raw_ostream &os;
};

MSLEmitter::MSLEmitter(llvm::raw_ostream &output) : os(output) {}

LogicalResult MSLEmitter::emitModule(gpu::GPUModuleOp gpuModule) {
  os << "#include <metal_stdlib>\n";
  os << "using namespace metal;\n\n";

  for (auto function : gpuModule.getOps<mlir::gpu::GPUFuncOp>()) {
    if (! function.isKernel()) continue;

    if (failed(this->emitKernel(function)))
      return failure();
  }

  return success();
}

LogicalResult MSLEmitter::emitType(Value val) {
  Type type = val.getType();
  std::string rep = "";

  bool ptr = false;
  if (auto memrefType = llvm::dyn_cast<MemRefType>(type)) {
    ptr = true;
    rep += "device ";
    type = memrefType.getElementType();
  }

  if (type.isF32()) rep += "float";
  else if (type.isF16()) rep += "half";
  else if (type.isF64()) rep += "double";
  else if (type.isIndex()) rep += "size_t";
  else if (type.isInteger()) {
    rep += (type.isUnsignedInteger() ? "u" : "") + std::string("int")
      + std::to_string(type.getIntOrFloatBitWidth()) + "_t";
  }
  if (rep == "") return failure();

  os << rep << " " << (ptr ? "*" : "");
  return success();
}

// TOOD: error messages?
LogicalResult MSLEmitter::emitBinary(Operation *op, std::string _operator, AsmState &state) {
  if (op->getNumOperands() != 2)
    return op->emitOpError("expected 2 operands for binop");

  if (failed(this->emitType(op->getResult(0))))
    return op->emitOpError("couldn't emit result type");
  os << " ";
  op->getResult(0).printAsOperand(os, state);
  os << " = ";
  op->getOperand(0).printAsOperand(os, state);
  os << " " << _operator << " ";
  op->getOperand(1).printAsOperand(os, state);
  os << ";\n";
  return success();
}

LogicalResult MSLEmitter::emitOffset(Operation::operand_range indices, llvm::ArrayRef<int64_t> shape, AsmState &state) {
  os << "[";
  if (indices.size() != shape.size()) return failure();
  size_t n = shape.size();
  size_t stride = 1;
  for (size_t i=0; i<n; ++i) {
    indices[i].printAsOperand(os, state);
    os << "*" << stride;
    if (i < n-1) os << "+";
    stride *= shape[i];
  }
  os << "]";
  return success();
}

LogicalResult MSLEmitter::emitOp(Operation &op, Operation *scopeOp, int depth) {
  AsmState state(scopeOp);
  for (int i=0; i<depth; ++i) os << "  ";
  return TypeSwitch<Operation *, LogicalResult>(&op)
    .Case<scf::YieldOp, gpu::ReturnOp>([&](auto x) { return success(); })
    .Case<gpu::GridDimOp>([&](auto x) {
      os << "size_t ";
      x.getResult().printAsOperand(os, state);
      os << " = ldim." << gpu::stringifyDimension(x.getDimension()) << ";\n";
      return success();
    })
    .Case<gpu::BlockDimOp>([&](auto x) {
      os << "size_t ";
      x.getResult().printAsOperand(os, state);
      os << " = gdim." << gpu::stringifyDimension(x.getDimension()) << ";\n";
      return success();
    })
    .Case<gpu::BlockIdOp>([&](auto x) {
      os << "size_t ";
      x.getResult().printAsOperand(os, state);
      os << " = lidx." << gpu::stringifyDimension(x.getDimension()) << ";\n";
      return success();
    })
    .Case<gpu::ThreadIdOp>([&](auto x) {
      os << "size_t ";
      x.getResult().printAsOperand(os, state);
      os << " = gidx." << gpu::stringifyDimension(x.getDimension()) << ";\n";
      return success();
    })
    .Case<arith::ConstantOp>([&](auto x) -> LogicalResult {
      if (failed(this->emitType(x.getResult())))
        return x.emitOpError("couldn't emit result type") << ": " << x.getResult().getType();
      x.getResult().printAsOperand(os, state);

      os << " = ";
      TypedAttr val = x.getValue();
      // TODO: handle unmatched case
      if (auto intAttr = dyn_cast<IntegerAttr>(val)) os << intAttr.getInt();
      if (auto floatAttr = dyn_cast<FloatAttr>(val)) os << floatAttr.getValueAsDouble();
      os << ";\n";
      return success();
    })
    .Case<arith::AddFOp, arith::AddIOp>([&](auto x) { return this->emitBinary(x.getOperation(), "+", state); })
    .Case<arith::MulFOp, arith::MulIOp>([&](auto x) { return this->emitBinary(x.getOperation(), "*", state); })
    .Case<memref::LoadOp>([&](auto x) -> LogicalResult {
      auto buf = x.getMemref();

      if (failed(this->emitType(x.getResult())))
        return x.getOperation()->emitOpError("couldn't emit result type") << ": " << x.getResult().getType();
      os << " ";
      x.getResult().printAsOperand(os, state);
      os << " = ";
      buf.printAsOperand(os, state);
      if (failed(this->emitOffset(x.getIndices(), buf.getType().getShape(), state)))
        return x.getOperation()->emitOpError("couldn't emit memref offset");
      os << ";\n";
      return success();
    })
    .Case<memref::StoreOp>([&](auto x) -> LogicalResult {
      auto buf = x.getMemref();

      buf.printAsOperand(os, state);
      if (failed(this->emitOffset(x.getIndices(), buf.getType().getShape(), state)))
        return x.getOperation()->emitOpError("couldn't emit memref offset");
      os << " = ";
      x.getValue().printAsOperand(os, state);
      os << ";\n";
      return success();
    })
    .Case<scf::ForOp>([&](auto x) {
      os << "for (int ";
      x.getInductionVar().printAsOperand(os, state);
      os << "=";
      x.getLowerBound().printAsOperand(os, state);
      os << ";";
      x.getInductionVar().printAsOperand(os, state);
      os << "<";
      x.getUpperBound().printAsOperand(os, state);
      os << ";";
      x.getInductionVar().printAsOperand(os, state);
      os << "+=";
      x.getStep().printAsOperand(os, state);
      os << ") {\n";
      for (auto &bb : x.getRegion().getBlocks()) {
        for (auto &op : bb.getOperations()) {
          if (failed(this->emitOp(op, scopeOp, depth+1))) return failure();
        }
      }
      os << "}\n";
      return success();
    })
    .Default([](Operation *op) {
      return op->emitOpError("no MSL pattern");
    });
}

LogicalResult MSLEmitter::emitKernel(gpu::GPUFuncOp &op) {
  os << "kernel void " << op.getName().str() << "(\n";

  AsmState state(op.getOperation());
  for (auto &arg : op.getArguments()) {
    os << "  ";
    if (failed(this->emitType(arg)))
      return op->emitOpError("couldn't emit arg type") << ": " << arg.getType();
    os << " ";
    arg.printAsOperand(os, state);
    os << ",\n";
  }

  os << "  uint3 gdim [[threads_per_grid]],\n";
  os << "  uint3 ldim [[threadgroups_per_grid]],\n";
  os << "  uint3 gidx [[thread_position_in_grid]],\n";
  os << "  uint3 lidx [[thread_position_in_threadgroup]])\n{\n";

  for (auto &bb : op.getRegion().getBlocks())
    for (auto &_op : bb.getOperations())
      if (failed(this->emitOp(_op, op.getOperation(), 1))) return failure();

  os << "}";
  return success();
}

}

namespace linda {

LogicalResult translateToMSL(mlir::ModuleOp module, llvm::raw_ostream &output) {
  bool foundKernelModule = false;
  for (mlir::gpu::GPUModuleOp gpuModule : module.getOps<mlir::gpu::GPUModuleOp>()) {
    foundKernelModule = true;

    MSLEmitter emitter(output);

    if (failed(emitter.emitModule(gpuModule)))
      return failure();
  }

  if (! foundKernelModule)
    return module.emitError("expected at least one gpu.module");
  return success();
}

void registerMSLTranslation() {
  TranslateFromMLIRRegistration registration(
    "gpu-to-msl",
    "Custom minimal translation pass from MLIR GPU module to Metal Shading Language",
    [](ModuleOp module, llvm::raw_ostream &output) -> LogicalResult { return translateToMSL(module, output); },
    [](mlir::DialectRegistry &registry) {
    registry.insert<
      arith::ArithDialect,
      memref::MemRefDialect,
      gpu::GPUDialect,
      scf::SCFDialect
    >();
  });
}

}
