#ifndef LINDA_DIALECT
#define LINDA_DIALECT

include "mlir/IR/OpBase.td"
include "mlir/Interfaces/FunctionInterfaces.td"
include "mlir/IR/SymbolInterfaces.td"

def LindaDialect : Dialect {
  let name = "linda";
  let cppNamespace = "linda";
  let summary = [{
    A pedagogical Tensor Compiler and HPC runtime
  }];

  let description = [{
    You know whats better then a loving embrace?
A compiler for the end of Moores law!

Don't become an incel kids; become a hacker.
  }];
}

class LindaOp<string mnemonic, list<Trait> traits = []> :
  Op<LindaDialect, mnemonic, traits>;

// TODO: untyped/generic dtype tensors?

// ----- Operations -----
def CreateOp : LindaOp<"create"> {
  let summary = "initialize Tensor with runtime memory buffer";

  let arguments = (ins MemRefRankOf<[I8], [1]>:$buffer);
  let results = (outs F32Tensor:$res);
}

def AddOp : LindaOp<"add"> {
  let summary = "elementwise addition with broadcasting";

  let arguments = (ins F32Tensor:$lhs, F32Tensor:$rhs);
  let results = (outs F32Tensor:$res);

  let assemblyFormat = "$lhs `:` type($lhs) `,` $rhs `:` type($rhs) attr-dict `:` type($res)";
}

def MulOp : LindaOp<"mul"> {
  let summary = "elementwise multiplication with broadcasting";

  let arguments = (ins F32Tensor:$lhs, F32Tensor:$rhs);
  let results = (outs F32Tensor:$res);

  let assemblyFormat = "$lhs `:` type($lhs) `,` $rhs `:` type($rhs) attr-dict `:` type($res)";
}

def ReshapeOp : LindaOp<"reshape"> {
  let summary = "";

  let arguments = (ins F32Tensor:$value);
  let results = (outs F32Tensor:$res);

  let assemblyFormat = "$value `:` type($value) attr-dict `:` type($res)";
}

#endif
