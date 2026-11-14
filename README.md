# Linda

Pedagogical MLIR Tensor compiler and runtime.

- Embedded Zig torch-like frontend
- Schedules and splits top level Tensor program into individual kernels
- kernels are lowered through multiple MLIR rewrite passes
- outputted as individual accelerator specific binaries via LLVM IR at the bottom
- Host buffers allocated and managed through zig, passed in as ptr/memrefs to MLIR block arguments

#### Motivating questions:
* How simple/idiomatic is MLIR?
* How easy is it to write a rudimentary deep learning compiler capable of training and running non-trivial machine learning models
* How easy is it to write MLIR optimization passes using builtin dialects? Kernel fusion, folding, affine transformations

#### Under the hood:

Here we follow a very simple example program through the compilation pipeline:

1. **Zig Torch-like API**
```zig
const a = try Tensor(f32).ones(&ctx, &.{32, 64});
const b = try Tensor(f32).ones(&ctx, &.{32, 64});

const c = try a.add(b);
const d = try c.mul(a);
const z = try a.add(c);
const y = try z.mul(d);
try y.compile();
```

**Here is the equivalant DAG:**

<p align="center">
  <img width="450" height="450" alt="tensor_graph" src="https://github.com/user-attachments/assets/ae7506c4-112c-4eef-b7fa-404e4816164e" />
</p>
<br><br>

`tensor.compile()` linearizes the graph via topological sorting before proceeding to MLIR so that tensor operations on incoming edges are always executed first. The exact order matters for performance reasons, and can be further optimized as there are usually many different possible permutations.

3. **Custom MLIR Dialect**
```mlir
module {
  func.func @kernel(%arg0: memref<32x64xf32>, %arg1: memref<32x64xf32>) {
    %0 = bufferization.to_tensor %arg0 : memref<32x64xf32> to tensor<32x64xf32>
    %1 = bufferization.to_tensor %arg1 : memref<32x64xf32> to tensor<32x64xf32>
    %2 = linda.add %0 : tensor<32x64xf32>, %1 : tensor<32x64xf32> : tensor<32x64xf32>
    %3 = linda.add %0 : tensor<32x64xf32>, %2 : tensor<32x64xf32> : tensor<32x64xf32>
    %4 = linda.mul %2 : tensor<32x64xf32>, %0 : tensor<32x64xf32> : tensor<32x64xf32>
    %5 = linda.mul %3 : tensor<32x64xf32>, %4 : tensor<32x64xf32> : tensor<32x64xf32>
    return
  }
}
```

3. **Affine Graph**

Middle stage of compilation/codegen. We have lowered our custom ops to builtin dialects like affine for loop optimization over tensor dimensions, memref to make the memory explicit, and arith operations. Still relatively high level abstraction-wise, no concept of GPU threads or hardware specific abstractions.

```mlir
module {
  func.func @kernel(%arg0: memref<32x64xf32>, %arg1: memref<32x64xf32>) {
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
```

**Example optimization pass: AffineLoopFusion**

```mlir
module {
  func.func @kernel(%arg0: memref<32x64xf32>, %arg1: memref<32x64xf32>) {
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
        %3 = affine.load %arg0[%arg2, %arg3] : memref<32x64xf32>
        %4 = affine.load %alloc_2[%arg2, %arg3] : memref<32x64xf32>
        %5 = arith.addf %3, %4 : f32
        affine.store %5, %alloc_1[%arg2, %arg3] : memref<32x64xf32>
        %6 = affine.load %alloc_2[%arg2, %arg3] : memref<32x64xf32>
        %7 = affine.load %arg0[%arg2, %arg3] : memref<32x64xf32>
        %8 = arith.mulf %6, %7 : f32
        affine.store %8, %alloc_0[%arg2, %arg3] : memref<32x64xf32>
        %9 = affine.load %alloc_1[%arg2, %arg3] : memref<32x64xf32>
        %10 = affine.load %alloc_0[%arg2, %arg3] : memref<32x64xf32>
        %11 = arith.mulf %9, %10 : f32
        affine.store %11, %alloc[%arg2, %arg3] : memref<32x64xf32>
      }
    }
    memref.dealloc %alloc_2 : memref<32x64xf32>
    memref.dealloc %alloc_1 : memref<32x64xf32>
    memref.dealloc %alloc_0 : memref<32x64xf32>
    memref.dealloc %alloc : memref<32x64xf32>
    return
  }
}
```

4. **GPU Graph**

****
```mlir
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
```

4. **LLVM IR kernel binary**

Contains host program with the accelerator GPU binary blog directly embedded, now lowered to assembly.

See [llvmir](./dump/kernel.ll)
and [optimized (O2)](./dump/kernel-opt.ll)

work in progress...
