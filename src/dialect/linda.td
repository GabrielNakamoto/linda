#ifndef LINDA_DIALECT
#define LINDA_DIALECT

include "mlir/IR/OpBase.td"
include "mlir/IR/FunctionInterfaces.td"
include "mlir/IR/SymbolInterfaces.td"


def LindaDialect : Dialect {
  let name = "linda";
  let cppNamespace = "linda";
  let summmary = [{
    A Tensor Compiler and HPC runtime in the name of Linda and my curiosity for MLIR
  }];

  let description = [{
    You know whats better then a loving embrace? A compiler for the end of Moores law!
    Don't become an incel kids, become a hacker
  }];
}


class LindaOp<string mnemonic, list<Trait> traits = []> :
  OP<LindaDialect, mnemonic, traits>;


// ----- Operations -----
def AddOp : LindaOp<"add"> {
  let summary = [{elementwise addition with broadcasting}];

  let arguments = (ins F32Tensor:$lhs, ins F32Tensor:$rhs);
  let results = (outs F32Tensor);

  let builder = [
    OpBuilder<(ins "Value":$lhs, "Value":$rhs)>
  ];
}

def MulOp : LindaOp<"mul"> {
  let summary = [{elementwise multiplication with broadcasting}];

  let arguments = (ins F32Tensor:$lhs, ins F32Tensor:$rhs);
  let results = (outs F32Tensor);

  let builder = [
    OpBuilder<(ins "Value":$lhs, "Value":$rhs)>
  ];
}

def ReshapeOp : LindaOp<"reshape"> {
  let summary = [{}];

  let arguments = (ins F32Tensor:$value);
  let results = (outs F32Tensor);

  let builder = {
    OpBuilder<(ins "Value":%value)>
  };
}

#endif
