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

4. **LLVM IR kernel binary**

See [llvmir module output](./dump/kernel.ll)

5. **Target specific binary/asm image**

See [gfx1100 amd asm output](./dump/kernel.s)
