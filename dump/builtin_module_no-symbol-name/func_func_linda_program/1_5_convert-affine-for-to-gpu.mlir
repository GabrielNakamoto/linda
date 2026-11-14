// -----// IR Dump After ConvertAffineForToGPUPass (convert-affine-for-to-gpu) ('func.func' operation: @linda_program) //----- //
#map = affine_map<(d0) -> (d0)>
#map1 = affine_map<(d0) -> (d0 + 8)>
#map2 = affine_map<(d0) -> (d0 + 16)>
module {
  func.func @linda_program(%arg0: memref<32x64xf32>, %arg1: memref<32x64xf32>) {
    %alloc = memref.alloc() : memref<32x64xf32>
    %alloc_0 = memref.alloc() : memref<32x64xf32>
    %alloc_1 = memref.alloc() : memref<32x64xf32>
    %alloc_2 = memref.alloc() : memref<32x64xf32>
    %c0 = arith.constant 0 : index
    %c32 = arith.constant 32 : index
    %0 = arith.subi %c32, %c0 : index
    %c8 = arith.constant 8 : index
    %1 = arith.ceildivsi %0, %c8 : index
    %c0_3 = arith.constant 0 : index
    %c64 = arith.constant 64 : index
    %2 = arith.subi %c64, %c0_3 : index
    %c16 = arith.constant 16 : index
    %3 = arith.ceildivsi %2, %c16 : index
    %c1 = arith.constant 1 : index
    gpu.launch blocks(%arg2, %arg3, %arg4) in (%arg8 = %1, %arg9 = %c1, %arg10 = %c1) threads(%arg5, %arg6, %arg7) in (%arg11 = %3, %arg12 = %c1, %arg13 = %c1) {
      %4 = arith.muli %c8, %arg2 : index
      %5 = arith.addi %c0, %4 : index
      %6 = arith.muli %c16, %arg5 : index
      %7 = arith.addi %c0_3, %6 : index
      affine.for %arg14 = #map(%5) to #map1(%5) {
        affine.for %arg15 = #map(%7) to #map2(%7) {
          %8 = affine.load %arg0[%arg14, %arg15] : memref<32x64xf32>
          %9 = affine.load %arg1[%arg14, %arg15] : memref<32x64xf32>
          %10 = arith.addf %8, %9 : f32
          affine.store %10, %alloc_2[%arg14, %arg15] : memref<32x64xf32>
          %11 = affine.load %arg0[%arg14, %arg15] : memref<32x64xf32>
          %12 = affine.load %alloc_2[%arg14, %arg15] : memref<32x64xf32>
          %13 = arith.addf %11, %12 : f32
          affine.store %13, %alloc_1[%arg14, %arg15] : memref<32x64xf32>
          %14 = affine.load %alloc_2[%arg14, %arg15] : memref<32x64xf32>
          %15 = affine.load %arg0[%arg14, %arg15] : memref<32x64xf32>
          %16 = arith.mulf %14, %15 : f32
          affine.store %16, %alloc_0[%arg14, %arg15] : memref<32x64xf32>
          %17 = affine.load %alloc_1[%arg14, %arg15] : memref<32x64xf32>
          %18 = affine.load %alloc_0[%arg14, %arg15] : memref<32x64xf32>
          %19 = arith.mulf %17, %18 : f32
          affine.store %19, %alloc[%arg14, %arg15] : memref<32x64xf32>
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


