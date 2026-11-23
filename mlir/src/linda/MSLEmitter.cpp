#include "Passes.h"
#include <memory>
#include <map>

using namespace mlir;

namespace {

class MSLEmitter {
public:

  MSLEmitter(llvm::raw_ostream &output);

  LogicalResult emitKernel(gpu::GPUFuncOp virtualKernel);
  LogicalResult emitModule(gpu::GPUModuleOp gpuModule);
  LogicalResult emitType(Operation &op);

private:
  llvm::raw_ostream os;
  DenseMap<Value, std::string> _names;

  LogicalResult emitOp();
};

}

MSLEmitter::MSLEmitter(llvm::raw_ostream &output) : os(output) {}

LogicalResult MSLEmitter::emitModule(gpu::GPUModuleOp gpuModule) {
  os << "include <metal_stdlib>\n";
  os << "using namespace metal;\n\n";

  for (auto function : gpuModule.getOps<mlir::gpu::GPUFuncOp>()) {
    if (! function.isKernel()) continue;

    if (failed(this->emitKernel(function)))
      return failure();
  }

  return succes();
}
LogicalResult MSLEmitter::emitType(Operation &op) {
  // this has to handle integer types differently
  static std::map<Type, std::string> mslType = {
    {Float32Type, "float"},
    {Float32Type, "float"},
  };
  // assert at least 1 result
  Type type = op.getResult(0).getType();

  if (mslType.find(type) == mslType.end()) return failure();

  os << mslType.get(type);
  return succes();
}

// TOOD: error messages?
LogicalResult MSLEmitter::emitBinary(Operation &op, std::string _operator) {
  if (op.getNumOperands() != 2) return failure();

  this->emitType(op);
  os << " ";
  op.getResult(0).print(os);
  os << " = ";
  op.getOperand(0).print(os);
  os << " " << _operator << " ";
  op.getOperand(1).print(os);
  os << ";\n";
}

LogicalResult MSLEmitter::emitOffset(Operation::operand_range indices, llvm::Arrayref<int64_t> shape) {
  os << "[";
  if (indices.size() != shape.size()) return failure();
  size_t n = shape.size();
  for (size_t i=0; i<n; ++i) {
    os.print(indices[i]);
    os << "*" << shape[i];
    if (i < n-1) os << "+";
  }
  os << "]";
  return succes();
}

LogicalResult MSLEmitter::emitOp(Operation &op) {
  // hard part: scf
  return TypeSwitch<Operation *, LogicalResult>(op)
    .Case<gpu::GridDimOp>([&](auto x) { })
    .Case<gpu::BlockDimOp>([&](auto x) { })
    .Case<gpu::BlockIdOp>([&](auto x) { })
    .Case<gpu::ThreadIdOp>([&](auto x) { })
    .Case<arith::ConstantOp>([&](auto x) {
      this->emitType(x);
      os << " = ";
      TypedAttr val = x.getValue();
      // TODO: handle unmatched case
      if (auto intAttr = dyn_cast<IntegerAttr>(val)) os << intAttr.getInt();
      if (auto floatAttr = dyn_cast<FloatAttr>(val)) os << intAttr.getFloat();
      os << ";\n";
      return success();
    })
    .Case<arith::AddFOp, arith::AddIOp>([&](auto x) { return this->emitBinary(x, "+"); })
    .Case<arith::MulFOp, arith::MulIOp>([&](auto x) { return this->emitBinary(x, "*"); })
    .Case<memref::LoadOp>([&](auto x) {
      auto loadOp = llvm::dyn_cast<memref::LoadOp>(x);
      auto buf = loadOp.getMemref();

      this->emitType(x);
      os << " ";
      x.getResult(0).print(os);
      os << " = ";
      buf.print(os);
      this->emitOffset(loadOp.getIndices(), buf.getShape());
      os << ";\n"
      return success();
    })
    .Case<memref::StoreOp>([&](auto x) {
      auto storeOp = llvm::dyn_cast<memref::StoreOp>(x);
      auto buf = storeOp.getMemref();

      buf.print(os);
      os << "[";
      this->emitOffset(storeOp.getIndices(), buf.getShape());
      os << "] = ";
      storeOp.getValue().print(os);
      os << ";\n";
      return success();
    });
}

// support only scf, simple arith, memref, gpu ops; no affine
LogicalResult MSLEmitter::emitKernel(gpu::GPUFuncOp &op) {
  os << "kernel void " << op.getName().str() << "(\n";

  for (auto &arg : op.getArguments()) {
    // emit arg
  }

  os << ")\n{\n";

  for (auto &bb : op.getRegion(0).getBlocks())
    for (auto &op : bb.getOperations())
      this->emitOp(op);

  os << "}";
  return success();
}

LogicalResult translateToMSL(mlir::ModuleOp module, llvm::raw_ostream &output) {
  bool foundKernelModuel = false;
  for (mlir::gpu::GPUModuleOp gpuModule : module.getOps<mlir::gpu::GPUModuleOp>()) {
    foundKernelModuel = true;

    MSLEmitter emitter(output);

    if (failed(emitter.emitModule(gpuModule)))
      return failure();
  }

  if (! foundKernelModule)
    return module.emitError("expected at least one gpu.module");
  return success();
}
