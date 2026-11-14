// -----// IR Dump Before AffineLoopFusion (affine-loop-fusion) ('func.func' operation: @linda_program) //----- //
module {
  func.func @linda_program(%arg0: memref<32x64xf32>, %arg1: memref<32x64xf32>) {
    %alloc = memref.alloc() : memref<32x64xf32>
    %alloc_0 = memref.alloc() : memref<32x64xf32>
    %alloc_1 = memref.alloc() : memref<32x64xf32>
    %alloc_2 = memref.alloc() : memref<32x64xf32>
    affine.for %arg2 = 0 to 32 {
      affine.for %arg3 = 0 to 64 {
        %0 = affine.load %arg0[%arg2, %arg3] : memref<32x64xf32>
        %1 = affine.load %arg1[%arg2, %arg3] : memref<32x64xf32>
        %2 = arith.addf %0, %1 : f32
        affine.store %2, %alloc_2[%arg2, %arg3] : memref<32x64xf32>
      }
    }
    affine.for %arg2 = 0 to 32 {
      affine.for %arg3 = 0 to 64 {
        %0 = affine.load %arg0[%arg2, %arg3] : memref<32x64xf32>
        %1 = affine.load %alloc_2[%arg2, %arg3] : memref<32x64xf32>
        %2 = arith.addf %0, %1 : f32
        affine.store %2, %alloc_1[%arg2, %arg3] : memref<32x64xf32>
      }
    }
    affine.for %arg2 = 0 to 32 {
      affine.for %arg3 = 0 to 64 {
        %0 = affine.load %alloc_2[%arg2, %arg3] : memref<32x64xf32>
        %1 = affine.load %arg0[%arg2, %arg3] : memref<32x64xf32>
        %2 = arith.mulf %0, %1 : f32
        affine.store %2, %alloc_0[%arg2, %arg3] : memref<32x64xf32>
      }
    }
    affine.for %arg2 = 0 to 32 {
      affine.for %arg3 = 0 to 64 {
        %0 = affine.load %alloc_1[%arg2, %arg3] : memref<32x64xf32>
        %1 = affine.load %alloc_0[%arg2, %arg3] : memref<32x64xf32>
        %2 = arith.mulf %0, %1 : f32
        affine.store %2, %alloc[%arg2, %arg3] : memref<32x64xf32>
      }
    }
    memref.dealloc %alloc_2 : memref<32x64xf32>
    memref.dealloc %alloc_1 : memref<32x64xf32>
    memref.dealloc %alloc_0 : memref<32x64xf32>
    memref.dealloc %alloc : memref<32x64xf32>
    return
  }
}


