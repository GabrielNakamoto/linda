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

```mlir
// -----// IR Dump After GpuKernelOutliningPass (gpu-kernel-outlining) ('builtin.module' operation) //----- //
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
  gpu.module @linda_program_kernel {
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
```

4. **Extracted GPU Binary**

ex. output when targeting sm_120 nvvm MLIR dialect with final `gpu-module-to-binary{format=assembly}` conversion pass

```ptx
//
// Generated by LLVM NVPTX Back-End
//

.version 7.1
.target sm_86
.address_size 64

	// .globl	linda_program_kernel

.visible .entry linda_program_kernel(
	.param .u64 .ptr .align 1 linda_program_kernel_param_0,
	.param .u64 .ptr .align 1 linda_program_kernel_param_1,
	.param .u64 .ptr .align 1 linda_program_kernel_param_2,
	.param .u64 .ptr .align 1 linda_program_kernel_param_3,
	.param .u64 .ptr .align 1 linda_program_kernel_param_4,
	.param .u64 .ptr .align 1 linda_program_kernel_param_5
)
.maxntid 4, 1, 1
{
	.reg .pred 	%p<3>;
	.reg .b32 	%r<13>;
	.reg .b64 	%rd<32>;

	ld.param.b64 	%rd3, [linda_program_kernel_param_0];
	cvta.to.global.u64 	%rd4, %rd3;
	ld.param.b64 	%rd5, [linda_program_kernel_param_1];
	cvta.to.global.u64 	%rd6, %rd5;
	ld.param.b64 	%rd7, [linda_program_kernel_param_2];
	cvta.to.global.u64 	%rd8, %rd7;
	ld.param.b64 	%rd9, [linda_program_kernel_param_3];
	cvta.to.global.u64 	%rd10, %rd9;
	ld.param.b64 	%rd11, [linda_program_kernel_param_4];
	cvta.to.global.u64 	%rd12, %rd11;
	ld.param.b64 	%rd13, [linda_program_kernel_param_5];
	cvta.to.global.u64 	%rd14, %rd13;
	mov.u32 	%r1, %ctaid.x;
	mov.u32 	%r2, %tid.x;
	mul.wide.u32 	%rd30, %r1, 8;
	or.b64 	%rd1, %rd30, 7;
	mul.wide.u32 	%rd15, %r1, 2048;
	mul.wide.u32 	%rd16, %r2, 64;
	or.b64 	%rd17, %rd15, %rd16;
	add.s64 	%rd29, %rd4, %rd17;
	add.s64 	%rd28, %rd6, %rd17;
	add.s64 	%rd27, %rd8, %rd17;
	add.s64 	%rd26, %rd10, %rd17;
	add.s64 	%rd25, %rd12, %rd17;
	add.s64 	%rd24, %rd14, %rd17;
$L__BB0_1:
	mov.b64 	%rd31, 0;
$L__BB0_2:
	add.s64 	%rd18, %rd29, %rd31;
	ld.global.b32 	%r3, [%rd18];
	add.s64 	%rd19, %rd28, %rd31;
	ld.global.b32 	%r4, [%rd19];
	add.rn.f32 	%r5, %r3, %r4;
	add.s64 	%rd20, %rd27, %rd31;
	st.global.b32 	[%rd20], %r5;
	ld.global.b32 	%r6, [%rd18];
	add.rn.f32 	%r7, %r5, %r6;
	add.s64 	%rd21, %rd26, %rd31;
	st.global.b32 	[%rd21], %r7;
	ld.global.b32 	%r8, [%rd20];
	ld.global.b32 	%r9, [%rd18];
	mul.rn.f32 	%r10, %r8, %r9;
	add.s64 	%rd22, %rd25, %rd31;
	st.global.b32 	[%rd22], %r10;
	ld.global.b32 	%r11, [%rd21];
	mul.rn.f32 	%r12, %r10, %r11;
	add.s64 	%rd23, %rd24, %rd31;
	st.global.b32 	[%rd23], %r12;
	add.s64 	%rd31, %rd31, 4;
	setp.ne.b64 	%p1, %rd31, 64;
	@%p1 bra 	$L__BB0_2;
	add.s64 	%rd2, %rd30, 1;
	add.s64 	%rd29, %rd29, 256;
	add.s64 	%rd28, %rd28, 256;
	add.s64 	%rd27, %rd27, 256;
	add.s64 	%rd26, %rd26, 256;
	add.s64 	%rd25, %rd25, 256;
	add.s64 	%rd24, %rd24, 256;
	setp.ne.b64 	%p2, %rd30, %rd1;
	mov.b64 	%rd30, %rd2;
	@%p2 bra 	$L__BB0_1;
	ret;

}
```

5. **Allocate device buffers**

Pseudocode:
```
for tensor in program
	if tensor is root
		copy host elements to device
	else
		alloc empty intermediate buffer on device
```

7. **Launch kernel(s)**

work in progress...

9. **Copy back and wrap Tensor result**

```
Tensor[Mul], dtype=.f32, shape={ 32, 64 }, num_inputs=2
{ 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6 }
```
