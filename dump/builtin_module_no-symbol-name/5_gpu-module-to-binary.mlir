// -----// IR Dump After GpuModuleToBinaryPass (gpu-module-to-binary) ('builtin.module' operation) //----- //
module attributes {gpu.container_module} {
  llvm.func @free(!llvm.ptr)
  llvm.func @malloc(i64) -> !llvm.ptr
  llvm.func @linda_program(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: !llvm.ptr, %arg8: !llvm.ptr, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64) {
    %0 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %1 = llvm.insertvalue %arg7, %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %2 = llvm.insertvalue %arg8, %1[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %3 = llvm.insertvalue %arg9, %2[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %4 = llvm.insertvalue %arg10, %3[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %5 = llvm.insertvalue %arg12, %4[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %6 = llvm.insertvalue %arg11, %5[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.insertvalue %arg13, %6[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %9 = llvm.insertvalue %arg0, %8[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.insertvalue %arg1, %9[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.insertvalue %arg2, %10[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.insertvalue %arg3, %11[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = llvm.insertvalue %arg5, %12[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %14 = llvm.insertvalue %arg4, %13[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %15 = llvm.insertvalue %arg6, %14[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %16 = llvm.mlir.constant(4 : index) : i64
    %17 = llvm.mlir.constant(1 : index) : i64
    %18 = llvm.mlir.constant(32 : index) : i64
    %19 = llvm.mlir.constant(64 : index) : i64
    %20 = llvm.mlir.constant(1 : index) : i64
    %21 = llvm.mlir.constant(2048 : index) : i64
    %22 = llvm.mlir.zero : !llvm.ptr
    %23 = llvm.getelementptr %22[%21] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %24 = llvm.ptrtoint %23 : !llvm.ptr to i64
    %25 = llvm.call @malloc(%24) : (i64) -> !llvm.ptr
    %26 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %27 = llvm.insertvalue %25, %26[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %28 = llvm.insertvalue %25, %27[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %29 = llvm.mlir.constant(0 : index) : i64
    %30 = llvm.insertvalue %29, %28[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %31 = llvm.insertvalue %18, %30[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %32 = llvm.insertvalue %19, %31[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %33 = llvm.insertvalue %19, %32[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %34 = llvm.insertvalue %20, %33[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %35 = llvm.mlir.constant(32 : index) : i64
    %36 = llvm.mlir.constant(64 : index) : i64
    %37 = llvm.mlir.constant(1 : index) : i64
    %38 = llvm.mlir.constant(2048 : index) : i64
    %39 = llvm.mlir.zero : !llvm.ptr
    %40 = llvm.getelementptr %39[%38] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %41 = llvm.ptrtoint %40 : !llvm.ptr to i64
    %42 = llvm.call @malloc(%41) : (i64) -> !llvm.ptr
    %43 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %44 = llvm.insertvalue %42, %43[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %45 = llvm.insertvalue %42, %44[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %46 = llvm.mlir.constant(0 : index) : i64
    %47 = llvm.insertvalue %46, %45[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %48 = llvm.insertvalue %35, %47[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %49 = llvm.insertvalue %36, %48[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %50 = llvm.insertvalue %36, %49[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %51 = llvm.insertvalue %37, %50[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %52 = llvm.mlir.constant(32 : index) : i64
    %53 = llvm.mlir.constant(64 : index) : i64
    %54 = llvm.mlir.constant(1 : index) : i64
    %55 = llvm.mlir.constant(2048 : index) : i64
    %56 = llvm.mlir.zero : !llvm.ptr
    %57 = llvm.getelementptr %56[%55] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %58 = llvm.ptrtoint %57 : !llvm.ptr to i64
    %59 = llvm.call @malloc(%58) : (i64) -> !llvm.ptr
    %60 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %61 = llvm.insertvalue %59, %60[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %62 = llvm.insertvalue %59, %61[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %63 = llvm.mlir.constant(0 : index) : i64
    %64 = llvm.insertvalue %63, %62[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %65 = llvm.insertvalue %52, %64[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %66 = llvm.insertvalue %53, %65[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %67 = llvm.insertvalue %53, %66[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %68 = llvm.insertvalue %54, %67[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %69 = llvm.mlir.constant(32 : index) : i64
    %70 = llvm.mlir.constant(64 : index) : i64
    %71 = llvm.mlir.constant(1 : index) : i64
    %72 = llvm.mlir.constant(2048 : index) : i64
    %73 = llvm.mlir.zero : !llvm.ptr
    %74 = llvm.getelementptr %73[%72] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %75 = llvm.ptrtoint %74 : !llvm.ptr to i64
    %76 = llvm.call @malloc(%75) : (i64) -> !llvm.ptr
    %77 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %78 = llvm.insertvalue %76, %77[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %79 = llvm.insertvalue %76, %78[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %80 = llvm.mlir.constant(0 : index) : i64
    %81 = llvm.insertvalue %80, %79[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %82 = llvm.insertvalue %69, %81[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %83 = llvm.insertvalue %70, %82[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %84 = llvm.insertvalue %70, %83[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %85 = llvm.insertvalue %71, %84[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %86 = llvm.extractvalue %15[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %87 = llvm.extractvalue %15[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %88 = llvm.extractvalue %15[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %89 = llvm.extractvalue %15[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %90 = llvm.extractvalue %15[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %91 = llvm.extractvalue %15[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %92 = llvm.extractvalue %15[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %93 = llvm.extractvalue %7[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %94 = llvm.extractvalue %7[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %95 = llvm.extractvalue %7[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %96 = llvm.extractvalue %7[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %97 = llvm.extractvalue %7[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %98 = llvm.extractvalue %7[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %99 = llvm.extractvalue %7[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %100 = llvm.extractvalue %85[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %101 = llvm.extractvalue %85[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %102 = llvm.extractvalue %85[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %103 = llvm.extractvalue %85[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %104 = llvm.extractvalue %85[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %105 = llvm.extractvalue %85[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %106 = llvm.extractvalue %85[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %107 = llvm.extractvalue %68[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %108 = llvm.extractvalue %68[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %109 = llvm.extractvalue %68[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %110 = llvm.extractvalue %68[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %111 = llvm.extractvalue %68[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %112 = llvm.extractvalue %68[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %113 = llvm.extractvalue %68[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %114 = llvm.extractvalue %51[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %115 = llvm.extractvalue %51[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %116 = llvm.extractvalue %51[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %117 = llvm.extractvalue %51[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %118 = llvm.extractvalue %51[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %119 = llvm.extractvalue %51[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %120 = llvm.extractvalue %51[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %121 = llvm.extractvalue %34[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %122 = llvm.extractvalue %34[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %123 = llvm.extractvalue %34[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %124 = llvm.extractvalue %34[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %125 = llvm.extractvalue %34[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %126 = llvm.extractvalue %34[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %127 = llvm.extractvalue %34[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    gpu.launch_func  @linda_program_kernel::@linda_program_kernel blocks in (%16, %17, %17) threads in (%16, %17, %17) : i64 args(%86 : !llvm.ptr, %87 : !llvm.ptr, %88 : i64, %89 : i64, %90 : i64, %91 : i64, %92 : i64, %93 : !llvm.ptr, %94 : !llvm.ptr, %95 : i64, %96 : i64, %97 : i64, %98 : i64, %99 : i64, %100 : !llvm.ptr, %101 : !llvm.ptr, %102 : i64, %103 : i64, %104 : i64, %105 : i64, %106 : i64, %107 : !llvm.ptr, %108 : !llvm.ptr, %109 : i64, %110 : i64, %111 : i64, %112 : i64, %113 : i64, %114 : !llvm.ptr, %115 : !llvm.ptr, %116 : i64, %117 : i64, %118 : i64, %119 : i64, %120 : i64, %121 : !llvm.ptr, %122 : !llvm.ptr, %123 : i64, %124 : i64, %125 : i64, %126 : i64, %127 : i64)
    %128 = llvm.extractvalue %85[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.call @free(%128) : (!llvm.ptr) -> ()
    %129 = llvm.extractvalue %68[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.call @free(%129) : (!llvm.ptr) -> ()
    %130 = llvm.extractvalue %51[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.call @free(%130) : (!llvm.ptr) -> ()
    %131 = llvm.extractvalue %34[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.call @free(%131) : (!llvm.ptr) -> ()
    llvm.return
  }
  gpu.binary @linda_program_kernel  [#gpu.object<#nvvm.target<chip = "sm_86">, properties = {LLVMIRToISATimeInMs = 5 : i64, O = 2 : i32}, assembly = "//\0A// Generated by LLVM NVPTX Back-End\0A//\0A\0A.version 7.1\0A.target sm_86\0A.address_size 64\0A\0A\09// .globl\09linda_program_kernel\0A\0A.visible .entry linda_program_kernel(\0A\09.param .u64 .ptr .align 1 linda_program_kernel_param_0,\0A\09.param .u64 .ptr .align 1 linda_program_kernel_param_1,\0A\09.param .u64 .ptr .align 1 linda_program_kernel_param_2,\0A\09.param .u64 .ptr .align 1 linda_program_kernel_param_3,\0A\09.param .u64 .ptr .align 1 linda_program_kernel_param_4,\0A\09.param .u64 .ptr .align 1 linda_program_kernel_param_5\0A)\0A.maxntid 4, 1, 1\0A{\0A\09.reg .pred \09%p<3>;\0A\09.reg .b32 \09%r<13>;\0A\09.reg .b64 \09%rd<32>;\0A\0A\09ld.param.b64 \09%rd3, [linda_program_kernel_param_0];\0A\09cvta.to.global.u64 \09%rd4, %rd3;\0A\09ld.param.b64 \09%rd5, [linda_program_kernel_param_1];\0A\09cvta.to.global.u64 \09%rd6, %rd5;\0A\09ld.param.b64 \09%rd7, [linda_program_kernel_param_2];\0A\09cvta.to.global.u64 \09%rd8, %rd7;\0A\09ld.param.b64 \09%rd9, [linda_program_kernel_param_3];\0A\09cvta.to.global.u64 \09%rd10, %rd9;\0A\09ld.param.b64 \09%rd11, [linda_program_kernel_param_4];\0A\09cvta.to.global.u64 \09%rd12, %rd11;\0A\09ld.param.b64 \09%rd13, [linda_program_kernel_param_5];\0A\09cvta.to.global.u64 \09%rd14, %rd13;\0A\09mov.u32 \09%r1, %ctaid.x;\0A\09mov.u32 \09%r2, %tid.x;\0A\09mul.wide.u32 \09%rd30, %r1, 8;\0A\09or.b64 \09%rd1, %rd30, 7;\0A\09mul.wide.u32 \09%rd15, %r1, 2048;\0A\09mul.wide.u32 \09%rd16, %r2, 64;\0A\09or.b64 \09%rd17, %rd15, %rd16;\0A\09add.s64 \09%rd29, %rd4, %rd17;\0A\09add.s64 \09%rd28, %rd6, %rd17;\0A\09add.s64 \09%rd27, %rd8, %rd17;\0A\09add.s64 \09%rd26, %rd10, %rd17;\0A\09add.s64 \09%rd25, %rd12, %rd17;\0A\09add.s64 \09%rd24, %rd14, %rd17;\0A$L__BB0_1:\0A\09mov.b64 \09%rd31, 0;\0A$L__BB0_2:\0A\09add.s64 \09%rd18, %rd29, %rd31;\0A\09ld.global.b32 \09%r3, [%rd18];\0A\09add.s64 \09%rd19, %rd28, %rd31;\0A\09ld.global.b32 \09%r4, [%rd19];\0A\09add.rn.f32 \09%r5, %r3, %r4;\0A\09add.s64 \09%rd20, %rd27, %rd31;\0A\09st.global.b32 \09[%rd20], %r5;\0A\09ld.global.b32 \09%r6, [%rd18];\0A\09add.rn.f32 \09%r7, %r5, %r6;\0A\09add.s64 \09%rd21, %rd26, %rd31;\0A\09st.global.b32 \09[%rd21], %r7;\0A\09ld.global.b32 \09%r8, [%rd20];\0A\09ld.global.b32 \09%r9, [%rd18];\0A\09mul.rn.f32 \09%r10, %r8, %r9;\0A\09add.s64 \09%rd22, %rd25, %rd31;\0A\09st.global.b32 \09[%rd22], %r10;\0A\09ld.global.b32 \09%r11, [%rd21];\0A\09mul.rn.f32 \09%r12, %r10, %r11;\0A\09add.s64 \09%rd23, %rd24, %rd31;\0A\09st.global.b32 \09[%rd23], %r12;\0A\09add.s64 \09%rd31, %rd31, 4;\0A\09setp.ne.b64 \09%p1, %rd31, 64;\0A\09@%p1 bra \09$L__BB0_2;\0A\09add.s64 \09%rd2, %rd30, 1;\0A\09add.s64 \09%rd29, %rd29, 256;\0A\09add.s64 \09%rd28, %rd28, 256;\0A\09add.s64 \09%rd27, %rd27, 256;\0A\09add.s64 \09%rd26, %rd26, 256;\0A\09add.s64 \09%rd25, %rd25, 256;\0A\09add.s64 \09%rd24, %rd24, 256;\0A\09setp.ne.b64 \09%p2, %rd30, %rd1;\0A\09mov.b64 \09%rd30, %rd2;\0A\09@%p2 bra \09$L__BB0_1;\0A\09ret;\0A\0A}\0A">]
}


