// -----// IR Dump Before (anonymous namespace)::LowerToAffinePass (linda-to-affine) ('builtin.module' operation) //----- //
module {
  func.func @linda_program(%arg0: memref<32x64xf32>, %arg1: memref<32x64xf32>) {
    %0 = bufferization.to_tensor %arg0 : memref<32x64xf32> to tensor<32x64xf32>
    %1 = bufferization.to_tensor %arg1 : memref<32x64xf32> to tensor<32x64xf32>
    %2 = linda.add %0 : tensor<32x64xf32>, %1 : tensor<32x64xf32> : tensor<32x64xf32>
    %3 = linda.add %0 : tensor<32x64xf32>, %2 : tensor<32x64xf32> : tensor<32x64xf32>
    %4 = linda.mul %2 : tensor<32x64xf32>, %0 : tensor<32x64xf32> : tensor<32x64xf32>
    %5 = linda.mul %3 : tensor<32x64xf32>, %4 : tensor<32x64xf32> : tensor<32x64xf32>
    return
  }
}


