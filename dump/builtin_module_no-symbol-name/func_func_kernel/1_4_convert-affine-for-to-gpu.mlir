// -----// IR Dump Before ConvertAffineForToGPUPass (convert-affine-for-to-gpu) ('func.func' operation: @kernel) //----- //
#map = affine_map<(d0) -> (d0)>
#map1 = affine_map<(d0) -> (d0 + 8)>
#map2 = affine_map<(d0) -> (d0 + 16)>
module {
  func.func @kernel(%arg0: memref<32x64xf32>, %arg1: memref<32x64xf32>) {
    %alloc = memref.alloc() : memref<32x64xf32>
    %alloc_0 = memref.alloc() : memref<32x64xf32>
    %alloc_1 = memref.alloc() : memref<32x64xf32>
    %alloc_2 = memref.alloc() : memref<32x64xf32>
    affine.for %arg2 = 0 to 32 step 8 {
      affine.for %arg3 = 0 to 64 step 16 {
        affine.for %arg4 = #map(%arg2) to #map1(%arg2) {
          affine.for %arg5 = #map(%arg3) to #map2(%arg3) {
            %0 = affine.load %arg0[%arg4, %arg5] : memref<32x64xf32>
            %1 = affine.load %arg1[%arg4, %arg5] : memref<32x64xf32>
            %2 = arith.addf %0, %1 : f32
            affine.store %2, %alloc_2[%arg4, %arg5] : memref<32x64xf32>
            %3 = affine.load %arg0[%arg4, %arg5] : memref<32x64xf32>
            %4 = affine.load %alloc_2[%arg4, %arg5] : memref<32x64xf32>
            %5 = arith.addf %3, %4 : f32
            affine.store %5, %alloc_1[%arg4, %arg5] : memref<32x64xf32>
            %6 = affine.load %alloc_2[%arg4, %arg5] : memref<32x64xf32>
            %7 = affine.load %arg0[%arg4, %arg5] : memref<32x64xf32>
            %8 = arith.mulf %6, %7 : f32
            affine.store %8, %alloc_0[%arg4, %arg5] : memref<32x64xf32>
            %9 = affine.load %alloc_1[%arg4, %arg5] : memref<32x64xf32>
            %10 = affine.load %alloc_0[%arg4, %arg5] : memref<32x64xf32>
            %11 = arith.mulf %9, %10 : f32
            affine.store %11, %alloc[%arg4, %arg5] : memref<32x64xf32>
          }
        }
      }
    }
    memref.dealloc %alloc_2 : memref<32x64xf32>
    memref.dealloc %alloc_1 : memref<32x64xf32>
    memref.dealloc %alloc_0 : memref<32x64xf32>
    memref.dealloc %alloc : memref<32x64xf32>
    return
  }
}


