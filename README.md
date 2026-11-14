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

4. **Extracted GPU Binary**

ex. output when targeting sm_120 nvvm MLIR dialect with final `gpu-module-to-binary{format=assembly}` conversion pass

```ptx
//
// Generated by LLVM NVPTX Back-End
//

.version 8.7
.target sm_120
.address_size 64

	// .globl	linda_program_kernel

.visible .entry linda_program_kernel(
	.param .u64 linda_program_kernel_param_0,
	.param .u64 linda_program_kernel_param_1,
	.param .u64 linda_program_kernel_param_2,
	.param .u64 linda_program_kernel_param_3,
	.param .u64 .ptr .align 1 linda_program_kernel_param_4,
	.param .u64 .ptr .align 1 linda_program_kernel_param_5,
	.param .u64 linda_program_kernel_param_6,
	.param .u64 linda_program_kernel_param_7,
	.param .u64 linda_program_kernel_param_8,
	.param .u64 linda_program_kernel_param_9,
	.param .u64 linda_program_kernel_param_10,
	.param .u64 .ptr .align 1 linda_program_kernel_param_11,
	.param .u64 .ptr .align 1 linda_program_kernel_param_12,
	.param .u64 linda_program_kernel_param_13,
	.param .u64 linda_program_kernel_param_14,
	.param .u64 linda_program_kernel_param_15,
	.param .u64 linda_program_kernel_param_16,
	.param .u64 linda_program_kernel_param_17,
	.param .u64 .ptr .align 1 linda_program_kernel_param_18,
	.param .u64 .ptr .align 1 linda_program_kernel_param_19,
	.param .u64 linda_program_kernel_param_20,
	.param .u64 linda_program_kernel_param_21,
	.param .u64 linda_program_kernel_param_22,
	.param .u64 linda_program_kernel_param_23,
	.param .u64 linda_program_kernel_param_24,
	.param .u64 .ptr .align 1 linda_program_kernel_param_25,
	.param .u64 .ptr .align 1 linda_program_kernel_param_26,
	.param .u64 linda_program_kernel_param_27,
	.param .u64 linda_program_kernel_param_28,
	.param .u64 linda_program_kernel_param_29,
	.param .u64 linda_program_kernel_param_30,
	.param .u64 linda_program_kernel_param_31,
	.param .u64 .ptr .align 1 linda_program_kernel_param_32,
	.param .u64 .ptr .align 1 linda_program_kernel_param_33,
	.param .u64 linda_program_kernel_param_34,
	.param .u64 linda_program_kernel_param_35,
	.param .u64 linda_program_kernel_param_36,
	.param .u64 linda_program_kernel_param_37,
	.param .u64 linda_program_kernel_param_38,
	.param .u64 .ptr .align 1 linda_program_kernel_param_39,
	.param .u64 .ptr .align 1 linda_program_kernel_param_40,
	.param .u64 linda_program_kernel_param_41,
	.param .u64 linda_program_kernel_param_42,
	.param .u64 linda_program_kernel_param_43,
	.param .u64 linda_program_kernel_param_44,
	.param .u64 linda_program_kernel_param_45
)
{
	.reg .pred 	%p<5>;
	.reg .b32 	%r<13>;
	.reg .b64 	%rd<39>;

	ld.param.b64 	%rd10, [linda_program_kernel_param_0];
	ld.param.b64 	%rd11, [linda_program_kernel_param_5];
	cvta.to.global.u64 	%rd1, %rd11;
	ld.param.b64 	%rd12, [linda_program_kernel_param_1];
	ld.param.b64 	%rd13, [linda_program_kernel_param_12];
	cvta.to.global.u64 	%rd2, %rd13;
	ld.param.b64 	%rd15, [linda_program_kernel_param_19];
	cvta.to.global.u64 	%rd3, %rd15;
	ld.param.b64 	%rd17, [linda_program_kernel_param_26];
	cvta.to.global.u64 	%rd4, %rd17;
	ld.param.b64 	%rd18, [linda_program_kernel_param_33];
	cvta.to.global.u64 	%rd5, %rd18;
	ld.param.b64 	%rd19, [linda_program_kernel_param_40];
	cvta.to.global.u64 	%rd6, %rd19;
	mov.u32 	%r1, %ctaid.x;
	cvt.u64.u32 	%rd20, %r1;
	mad.lo.s64 	%rd37, %rd10, %rd20, %rd12;
	setp.gt.s64 	%p1, %rd37, 9223372036854775799;
	@%p1 bra 	$L__BB0_6;
	ld.param.b64 	%rd14, [linda_program_kernel_param_2];
	ld.param.b64 	%rd16, [linda_program_kernel_param_3];
	mov.u32 	%r2, %tid.x;
	cvt.u64.u32 	%rd21, %r2;
	mad.lo.s64 	%rd7, %rd14, %rd21, %rd16;
	add.s64 	%rd8, %rd37, 7;
	shl.b64 	%rd22, %rd37, 6;
	add.s64 	%rd23, %rd7, %rd22;
	shl.b64 	%rd24, %rd23, 2;
	add.s64 	%rd36, %rd1, %rd24;
	add.s64 	%rd35, %rd2, %rd24;
	add.s64 	%rd34, %rd3, %rd24;
	add.s64 	%rd33, %rd4, %rd24;
	add.s64 	%rd32, %rd5, %rd24;
	add.s64 	%rd31, %rd6, %rd24;
	setp.gt.s64 	%p2, %rd7, 9223372036854775791;
	bra.uni 	$L__BB0_2;
$L__BB0_5:
	add.s64 	%rd9, %rd37, 1;
	add.s64 	%rd36, %rd36, 256;
	add.s64 	%rd35, %rd35, 256;
	add.s64 	%rd34, %rd34, 256;
	add.s64 	%rd33, %rd33, 256;
	add.s64 	%rd32, %rd32, 256;
	add.s64 	%rd31, %rd31, 256;
	setp.ne.b64 	%p4, %rd37, %rd8;
	mov.b64 	%rd37, %rd9;
	@%p4 bra 	$L__BB0_2;
	bra.uni 	$L__BB0_6;
$L__BB0_2:
	@%p2 bra 	$L__BB0_5;
	mov.b64 	%rd38, 0;
$L__BB0_4:
	add.s64 	%rd25, %rd36, %rd38;
	ld.global.b32 	%r3, [%rd25];
	add.s64 	%rd26, %rd35, %rd38;
	ld.global.b32 	%r4, [%rd26];
	add.rn.f32 	%r5, %r3, %r4;
	add.s64 	%rd27, %rd34, %rd38;
	st.global.b32 	[%rd27], %r5;
	ld.global.b32 	%r6, [%rd25];
	add.rn.f32 	%r7, %r5, %r6;
	add.s64 	%rd28, %rd33, %rd38;
	st.global.b32 	[%rd28], %r7;
	ld.global.b32 	%r8, [%rd27];
	ld.global.b32 	%r9, [%rd25];
	mul.rn.f32 	%r10, %r8, %r9;
	add.s64 	%rd29, %rd32, %rd38;
	st.global.b32 	[%rd29], %r10;
	ld.global.b32 	%r11, [%rd28];
	mul.rn.f32 	%r12, %r10, %r11;
	add.s64 	%rd30, %rd31, %rd38;
	st.global.b32 	[%rd30], %r12;
	add.s64 	%rd38, %rd38, 4;
	setp.ne.b64 	%p3, %rd38, 64;
	@%p3 bra 	$L__BB0_4;
	bra.uni 	$L__BB0_5;
$L__BB0_6:
	ret;

}
```

work in progress...
