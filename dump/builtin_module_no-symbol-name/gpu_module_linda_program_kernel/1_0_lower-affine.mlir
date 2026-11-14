// -----// IR Dump Before LowerAffinePass (lower-affine) ('gpu.module' operation: @linda_program_kernel) //----- //
#map = affine_map<()[s0] -> (s0 + 8)>
#map1 = affine_map<()[s0] -> (s0 + 16)>
module attributes {gpu.container_module} {
  func.func @linda_program(%arg0: memref<32x64xf32>, %arg1: memref<32x64xf32>) {
    %c4 = arith.constant 4 : index
    %c1 = arith.constant 1 : index
    %c16 = arith.constant 16 : index
    %c8 = arith.constant 8 : index
    %alloc = memref.alloc() : memref<32x64xf32>
    %alloc_0 = memref.alloc() : memref<32x64xf32>
    %alloc_1 = memref.alloc() : memref<32x64xf32>
    %alloc_2 = memref.alloc() : memref<32x64xf32>
    gpu.launch_func  @linda_program_kernel::@linda_program_kernel blocks in (%c4, %c1, %c1) threads in (%c4, %c1, %c1)  args(%arg0 : memref<32x64xf32>, %arg1 : memref<32x64xf32>, %alloc_2 : memref<32x64xf32>, %alloc_1 : memref<32x64xf32>, %alloc_0 : memref<32x64xf32>, %alloc : memref<32x64xf32>)
    memref.dealloc %alloc_2 : memref<32x64xf32>
    memref.dealloc %alloc_1 : memref<32x64xf32>
    memref.dealloc %alloc_0 : memref<32x64xf32>
    memref.dealloc %alloc : memref<32x64xf32>
    return
  }
  gpu.module @linda_program_kernel [#nvvm.target<chip = "sm_86">] {
    gpu.func @linda_program_kernel(%arg0: memref<32x64xf32>, %arg1: memref<32x64xf32>, %arg2: memref<32x64xf32>, %arg3: memref<32x64xf32>, %arg4: memref<32x64xf32>, %arg5: memref<32x64xf32>) kernel attributes {known_block_size = array<i32: 4, 1, 1>, known_grid_size = array<i32: 4, 1, 1>} {
      %block_id_x = gpu.block_id  x
      %block_id_y = gpu.block_id  y
      %block_id_z = gpu.block_id  z
      %thread_id_x = gpu.thread_id  x
      %thread_id_y = gpu.thread_id  y
      %thread_id_z = gpu.thread_id  z
      %grid_dim_x = gpu.grid_dim  x
      %grid_dim_y = gpu.grid_dim  y
      %grid_dim_z = gpu.grid_dim  z
      %block_dim_x = gpu.block_dim  x
      %block_dim_y = gpu.block_dim  y
      %block_dim_z = gpu.block_dim  z
      %c8 = arith.constant 8 : index
      %c16 = arith.constant 16 : index
      %0 = arith.muli %block_id_x, %c8 : index
      %1 = arith.muli %thread_id_x, %c16 : index
      affine.for %arg6 = %0 to #map()[%0] {
        affine.for %arg7 = %1 to #map1()[%1] {
          %2 = affine.load %arg0[%arg6, %arg7] : memref<32x64xf32>
          %3 = affine.load %arg1[%arg6, %arg7] : memref<32x64xf32>
          %4 = arith.addf %2, %3 : f32
          affine.store %4, %arg2[%arg6, %arg7] : memref<32x64xf32>
          %5 = affine.load %arg0[%arg6, %arg7] : memref<32x64xf32>
          %6 = affine.load %arg2[%arg6, %arg7] : memref<32x64xf32>
          %7 = arith.addf %5, %6 : f32
          affine.store %7, %arg3[%arg6, %arg7] : memref<32x64xf32>
          %8 = affine.load %arg2[%arg6, %arg7] : memref<32x64xf32>
          %9 = affine.load %arg0[%arg6, %arg7] : memref<32x64xf32>
          %10 = arith.mulf %8, %9 : f32
          affine.store %10, %arg4[%arg6, %arg7] : memref<32x64xf32>
          %11 = affine.load %arg3[%arg6, %arg7] : memref<32x64xf32>
          %12 = affine.load %arg4[%arg6, %arg7] : memref<32x64xf32>
          %13 = arith.mulf %11, %12 : f32
          affine.store %13, %arg5[%arg6, %arg7] : memref<32x64xf32>
        }
      }
      gpu.return
    }
  }
}


