// -----// IR Dump After GpuLaunchSinkIndexComputationsPass (gpu-launch-sink-index-computations) ('func.func' operation: @linda_program) //----- //
#map = affine_map<()[s0] -> (s0 + 8)>
#map1 = affine_map<()[s0] -> (s0 + 16)>
module {
  func.func @linda_program(%arg0: memref<32x64xf32>, %arg1: memref<32x64xf32>) {
    %c4 = arith.constant 4 : index
    %c1 = arith.constant 1 : index
    %c16 = arith.constant 16 : index
    %c8 = arith.constant 8 : index
    %alloc = memref.alloc() : memref<32x64xf32>
    %alloc_0 = memref.alloc() : memref<32x64xf32>
    %alloc_1 = memref.alloc() : memref<32x64xf32>
    %alloc_2 = memref.alloc() : memref<32x64xf32>
    gpu.launch blocks(%arg2, %arg3, %arg4) in (%arg8 = %c4, %arg9 = %c1, %arg10 = %c1) threads(%arg5, %arg6, %arg7) in (%arg11 = %c4, %arg12 = %c1, %arg13 = %c1) {
      %c8_3 = arith.constant 8 : index
      %c16_4 = arith.constant 16 : index
      %0 = arith.muli %arg2, %c8_3 : index
      %1 = arith.muli %arg5, %c16_4 : index
      affine.for %arg14 = %0 to #map()[%0] {
        affine.for %arg15 = %1 to #map1()[%1] {
          %2 = affine.load %arg0[%arg14, %arg15] : memref<32x64xf32>
          %3 = affine.load %arg1[%arg14, %arg15] : memref<32x64xf32>
          %4 = arith.addf %2, %3 : f32
          affine.store %4, %alloc_2[%arg14, %arg15] : memref<32x64xf32>
          %5 = affine.load %arg0[%arg14, %arg15] : memref<32x64xf32>
          %6 = affine.load %alloc_2[%arg14, %arg15] : memref<32x64xf32>
          %7 = arith.addf %5, %6 : f32
          affine.store %7, %alloc_1[%arg14, %arg15] : memref<32x64xf32>
          %8 = affine.load %alloc_2[%arg14, %arg15] : memref<32x64xf32>
          %9 = affine.load %arg0[%arg14, %arg15] : memref<32x64xf32>
          %10 = arith.mulf %8, %9 : f32
          affine.store %10, %alloc_0[%arg14, %arg15] : memref<32x64xf32>
          %11 = affine.load %alloc_1[%arg14, %arg15] : memref<32x64xf32>
          %12 = affine.load %alloc_0[%arg14, %arg15] : memref<32x64xf32>
          %13 = arith.mulf %11, %12 : f32
          affine.store %13, %alloc[%arg14, %arg15] : memref<32x64xf32>
        }
      }
      gpu.terminator
    }
    memref.dealloc %alloc_2 : memref<32x64xf32>
    memref.dealloc %alloc_1 : memref<32x64xf32>
    memref.dealloc %alloc_0 : memref<32x64xf32>
    memref.dealloc %alloc : memref<32x64xf32>
    return
  }
}


