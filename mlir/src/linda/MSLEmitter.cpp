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
  LogicalResult emitOp(Operation &op);
  LogicalResult emitType(Value val);
  LogicalResult emitBinary(Operation *op, std::string _operator);
  LogicalResult emitOffset(Operation::operand_range indices, llvm::ArrayRef<int64_t> shape);

  llvm::raw_ostream &os;
};

}

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
  if (type.isF32()) rep = "float";
  if (type.isF16()) rep = "half";
  if (type.isF64()) rep = "double";
  if (type.isInteger())
    rep = (type.isUnsignedInteger() ? "u" : "") + std::string("int")
      + std::to_string(type.getIntOrFloatBitWidth()) + "_t";
  if (rep == "") return failure();

  os << rep;
  return success();
}

// TOOD: error messages?
LogicalResult MSLEmitter::emitBinary(Operation *op, std::string _operator) {
  if (op->getNumOperands() != 2) return failure();

  this->emitType(op->getResult(0));
  os << " ";
  op->getResult(0).print(os);
  os << " = ";
  op->getOperand(0).print(os);
  os << " " << _operator << " ";
  op->getOperand(1).print(os);
  os << ";\n";
  return success();
}

LogicalResult MSLEmitter::emitOffset(Operation::operand_range indices, llvm::ArrayRef<int64_t> shape) {
  os << "[";
  if (indices.size() != shape.size()) return failure();
  size_t n = shape.size();
  size_t stride = 1;
  for (size_t i=0; i<n; ++i) {
    indices[i].print(os);
    os << "*" << stride;
    if (i < n-1) os << "+";
    stride *= shape[i];
  }
  os << "]";
  return success();
}

LogicalResult MSLEmitter::emitOp(Operation &op) {
  return TypeSwitch<Operation *, LogicalResult>(&op)
    .Case<gpu::GridDimOp>([&](auto x) {
      x.getResult().print(os);
      os << " = ldim." << gpu::stringifyDimension(x.getDimension()) << ";\n";
      return success();
    })
    .Case<gpu::BlockDimOp>([&](auto x) {
      x.getResult().print(os);
      os << " = gdim." << gpu::stringifyDimension(x.getDimension()) << ";\n";
      return success();
    })
    .Case<gpu::BlockIdOp>([&](auto x) {
      x.getResult().print(os);
      os << " = lidx." << gpu::stringifyDimension(x.getDimension()) << ";\n";
      return success();
    })
    .Case<gpu::ThreadIdOp>([&](auto x) {
      x.getResult().print(os);
      os << " = gidx." << gpu::stringifyDimension(x.getDimension()) << ";\n";
      return success();
    })
    .Case<arith::ConstantOp>([&](auto x) {
      this->emitType(x.getResult());
      x.getResult().print(os);

      os << " = ";
      TypedAttr val = x.getValue();
      // TODO: handle unmatched case
      if (auto intAttr = dyn_cast<IntegerAttr>(val)) os << intAttr.getInt();
      if (auto floatAttr = dyn_cast<FloatAttr>(val)) os << floatAttr.getValueAsDouble();
      os << ";\n";
      return success();
    })
    .Case<arith::AddFOp, arith::AddIOp>([&](auto x) { return this->emitBinary(x.getOperation(), "+"); })
    .Case<arith::MulFOp, arith::MulIOp>([&](auto x) { return this->emitBinary(x.getOperation(), "*"); })
    .Case<memref::LoadOp>([&](auto x) {
      auto buf = x.getMemref();

      this->emitType(x.getResult());
      os << " ";
      x.getResult().print(os);
      os << " = ";
      buf.print(os);
      this->emitOffset(x.getIndices(), buf.getType().getShape());
      os << ";\n";
      return success();
    })
    .Case<memref::StoreOp>([&](auto x) {
      auto buf = x.getMemref();

      buf.print(os);
      this->emitOffset(x.getIndices(), buf.getType().getShape());
      os << " = ";
      x.getValue().print(os);
      os << ";\n";
      return success();
    })
    .Case<scf::ForOp>([&](auto x) {
      os << "for (int ";
      x.getInductionVar().print(os);
      os << "=";
      x.getLowerBound().print(os);
      os << ";";
      x.getInductionVar().print(os);
      os << "<";
      x.getUpperBound().print(os);
      os << ";";
      x.getInductionVar().print(os);
      os << "+=";
      x.getStep().print(os);
      os << ") {\n";
      for (auto &bb : x.getRegion().getBlocks())
        for (auto &op : bb.getOperations())
          this->emitOp(op);
      os << "}\n";
      return success();
    });

}

LogicalResult MSLEmitter::emitKernel(gpu::GPUFuncOp &op) {
  os << "kernel void " << op.getName().str() << "(\n";

  for (auto &arg : op.getArguments()) {
    this->emitType(arg); // TODO: this needs to handle memref ptr conversions
    os << " ";
    arg.print(os);
    os << ",\n";
  }

  os << "uint3 gdim [[threads_per_grid]],\n";
  os << "uint3 ldim [[threadgroups_per_grid]],\n";
  os << "uint3 gidx [[thread_position_in_grid]],\n";
  os << "uint3 lidx [[thread_position_in_threadgroup]])\n{\n";

  for (auto &bb : op.getRegion().getBlocks())
    for (auto &op : bb.getOperations())
      this->emitOp(op);

  os << "}";
  return success();
}

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
