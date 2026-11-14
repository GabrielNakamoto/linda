// -----// IR Dump After SCFToControlFlowPass (convert-scf-to-cf) ('gpu.module' operation: @linda_program_kernel) //----- //
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
      %c8_0 = arith.constant 8 : index
      %2 = arith.addi %0, %c8_0 : index
      %c1 = arith.constant 1 : index
      cf.br ^bb1(%0 : index)
    ^bb1(%3: index):  // 2 preds: ^bb0, ^bb5
      %4 = arith.cmpi slt, %3, %2 : index
      cf.cond_br %4, ^bb2, ^bb6
    ^bb2:  // pred: ^bb1
      %c16_1 = arith.constant 16 : index
      %5 = arith.addi %1, %c16_1 : index
      %c1_2 = arith.constant 1 : index
      cf.br ^bb3(%1 : index)
    ^bb3(%6: index):  // 2 preds: ^bb2, ^bb4
      %7 = arith.cmpi slt, %6, %5 : index
      cf.cond_br %7, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      %8 = memref.load %arg0[%3, %6] : memref<32x64xf32>
      %9 = memref.load %arg1[%3, %6] : memref<32x64xf32>
      %10 = arith.addf %8, %9 : f32
      memref.store %10, %arg2[%3, %6] : memref<32x64xf32>
      %11 = memref.load %arg0[%3, %6] : memref<32x64xf32>
      %12 = memref.load %arg2[%3, %6] : memref<32x64xf32>
      %13 = arith.addf %11, %12 : f32
      memref.store %13, %arg3[%3, %6] : memref<32x64xf32>
      %14 = memref.load %arg2[%3, %6] : memref<32x64xf32>
      %15 = memref.load %arg0[%3, %6] : memref<32x64xf32>
      %16 = arith.mulf %14, %15 : f32
      memref.store %16, %arg4[%3, %6] : memref<32x64xf32>
      %17 = memref.load %arg3[%3, %6] : memref<32x64xf32>
      %18 = memref.load %arg4[%3, %6] : memref<32x64xf32>
      %19 = arith.mulf %17, %18 : f32
      memref.store %19, %arg5[%3, %6] : memref<32x64xf32>
      %20 = arith.addi %6, %c1_2 : index
      cf.br ^bb3(%20 : index)
    ^bb5:  // pred: ^bb3
      %21 = arith.addi %3, %c1 : index
      cf.br ^bb1(%21 : index)
    ^bb6:  // pred: ^bb1
      gpu.return
    }
  }
}


