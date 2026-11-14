// -----// IR Dump After GpuKernelOutliningPass (gpu-kernel-outlining) ('builtin.module' operation) //----- //
#map = affine_map<(d0) -> (d0)>
#map1 = affine_map<(d0) -> (d0 + 8)>
#map2 = affine_map<(d0) -> (d0 + 16)>
module attributes {gpu.container_module} {
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
    gpu.launch_func  @linda_program_kernel::@linda_program_kernel blocks in (%1, %c1, %c1) threads in (%3, %c1, %c1)  args(%c8 : index, %c0 : index, %c16 : index, %c0_3 : index, %arg0 : memref<32x64xf32>, %arg1 : memref<32x64xf32>, %alloc_2 : memref<32x64xf32>, %alloc_1 : memref<32x64xf32>, %alloc_0 : memref<32x64xf32>, %alloc : memref<32x64xf32>)
    memref.dealloc %alloc_2 : memref<32x64xf32>
    memref.dealloc %alloc_1 : memref<32x64xf32>
    memref.dealloc %alloc_0 : memref<32x64xf32>
    memref.dealloc %alloc : memref<32x64xf32>
    return
  }
  gpu.module @linda_program_kernel {
    gpu.func @linda_program_kernel(%arg0: index, %arg1: index, %arg2: index, %arg3: index, %arg4: memref<32x64xf32>, %arg5: memref<32x64xf32>, %arg6: memref<32x64xf32>, %arg7: memref<32x64xf32>, %arg8: memref<32x64xf32>, %arg9: memref<32x64xf32>) kernel {
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
      %0 = arith.muli %arg0, %block_id_x : index
      %1 = arith.addi %arg1, %0 : index
      %2 = arith.muli %arg2, %thread_id_x : index
      %3 = arith.addi %arg3, %2 : index
      affine.for %arg10 = #map(%1) to #map1(%1) {
        affine.for %arg11 = #map(%3) to #map2(%3) {
          %4 = affine.load %arg4[%arg10, %arg11] : memref<32x64xf32>
          %5 = affine.load %arg5[%arg10, %arg11] : memref<32x64xf32>
          %6 = arith.addf %4, %5 : f32
          affine.store %6, %arg6[%arg10, %arg11] : memref<32x64xf32>
          %7 = affine.load %arg4[%arg10, %arg11] : memref<32x64xf32>
          %8 = affine.load %arg6[%arg10, %arg11] : memref<32x64xf32>
          %9 = arith.addf %7, %8 : f32
          affine.store %9, %arg7[%arg10, %arg11] : memref<32x64xf32>
          %10 = affine.load %arg6[%arg10, %arg11] : memref<32x64xf32>
          %11 = affine.load %arg4[%arg10, %arg11] : memref<32x64xf32>
          %12 = arith.mulf %10, %11 : f32
          affine.store %12, %arg8[%arg10, %arg11] : memref<32x64xf32>
          %13 = affine.load %arg7[%arg10, %arg11] : memref<32x64xf32>
          %14 = affine.load %arg8[%arg10, %arg11] : memref<32x64xf32>
          %15 = arith.mulf %13, %14 : f32
          affine.store %15, %arg9[%arg10, %arg11] : memref<32x64xf32>
        }
      }
      gpu.return
    }
  }
}


