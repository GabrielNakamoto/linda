// -----// IR Dump After ConvertGpuOpsToNVVMOps (convert-gpu-to-nvvm) ('gpu.module' operation: @linda_program_kernel) //----- //
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
    llvm.func @linda_program_kernel(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: !llvm.ptr, %arg3: !llvm.ptr, %arg4: !llvm.ptr, %arg5: !llvm.ptr) attributes {gpu.kernel, gpu.known_block_size = array<i32: 4, 1, 1>, gpu.known_grid_size = array<i32: 4, 1, 1>, nvvm.kernel, nvvm.maxntid = array<i32: 4, 1, 1>} {
      %0 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
      %1 = llvm.insertvalue %arg5, %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %2 = llvm.insertvalue %arg5, %1[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %3 = llvm.mlir.constant(0 : index) : i64
      %4 = llvm.insertvalue %3, %2[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %5 = llvm.mlir.constant(32 : index) : i64
      %6 = llvm.insertvalue %5, %4[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %7 = llvm.mlir.constant(64 : index) : i64
      %8 = llvm.insertvalue %7, %6[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %9 = llvm.mlir.constant(64 : index) : i64
      %10 = llvm.insertvalue %9, %8[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %11 = llvm.mlir.constant(1 : index) : i64
      %12 = llvm.insertvalue %11, %10[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %13 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
      %14 = llvm.insertvalue %arg4, %13[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %15 = llvm.insertvalue %arg4, %14[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %16 = llvm.mlir.constant(0 : index) : i64
      %17 = llvm.insertvalue %16, %15[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %18 = llvm.mlir.constant(32 : index) : i64
      %19 = llvm.insertvalue %18, %17[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %20 = llvm.mlir.constant(64 : index) : i64
      %21 = llvm.insertvalue %20, %19[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %22 = llvm.mlir.constant(64 : index) : i64
      %23 = llvm.insertvalue %22, %21[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %24 = llvm.mlir.constant(1 : index) : i64
      %25 = llvm.insertvalue %24, %23[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %26 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
      %27 = llvm.insertvalue %arg3, %26[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %28 = llvm.insertvalue %arg3, %27[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %29 = llvm.mlir.constant(0 : index) : i64
      %30 = llvm.insertvalue %29, %28[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %31 = llvm.mlir.constant(32 : index) : i64
      %32 = llvm.insertvalue %31, %30[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %33 = llvm.mlir.constant(64 : index) : i64
      %34 = llvm.insertvalue %33, %32[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %35 = llvm.mlir.constant(64 : index) : i64
      %36 = llvm.insertvalue %35, %34[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %37 = llvm.mlir.constant(1 : index) : i64
      %38 = llvm.insertvalue %37, %36[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %39 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
      %40 = llvm.insertvalue %arg2, %39[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %41 = llvm.insertvalue %arg2, %40[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %42 = llvm.mlir.constant(0 : index) : i64
      %43 = llvm.insertvalue %42, %41[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %44 = llvm.mlir.constant(32 : index) : i64
      %45 = llvm.insertvalue %44, %43[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %46 = llvm.mlir.constant(64 : index) : i64
      %47 = llvm.insertvalue %46, %45[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %48 = llvm.mlir.constant(64 : index) : i64
      %49 = llvm.insertvalue %48, %47[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %50 = llvm.mlir.constant(1 : index) : i64
      %51 = llvm.insertvalue %50, %49[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %52 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
      %53 = llvm.insertvalue %arg1, %52[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %54 = llvm.insertvalue %arg1, %53[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %55 = llvm.mlir.constant(0 : index) : i64
      %56 = llvm.insertvalue %55, %54[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %57 = llvm.mlir.constant(32 : index) : i64
      %58 = llvm.insertvalue %57, %56[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %59 = llvm.mlir.constant(64 : index) : i64
      %60 = llvm.insertvalue %59, %58[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %61 = llvm.mlir.constant(64 : index) : i64
      %62 = llvm.insertvalue %61, %60[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %63 = llvm.mlir.constant(1 : index) : i64
      %64 = llvm.insertvalue %63, %62[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %65 = llvm.mlir.poison : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
      %66 = llvm.insertvalue %arg0, %65[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %67 = llvm.insertvalue %arg0, %66[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %68 = llvm.mlir.constant(0 : index) : i64
      %69 = llvm.insertvalue %68, %67[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %70 = llvm.mlir.constant(32 : index) : i64
      %71 = llvm.insertvalue %70, %69[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %72 = llvm.mlir.constant(64 : index) : i64
      %73 = llvm.insertvalue %72, %71[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %74 = llvm.mlir.constant(64 : index) : i64
      %75 = llvm.insertvalue %74, %73[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %76 = llvm.mlir.constant(1 : index) : i64
      %77 = llvm.insertvalue %76, %75[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %78 = llvm.mlir.constant(1 : index) : i64
      %79 = llvm.mlir.constant(16 : index) : i64
      %80 = llvm.mlir.constant(8 : index) : i64
      %81 = nvvm.read.ptx.sreg.ctaid.x range <i32, 0, 4> : i32
      %82 = llvm.sext %81 : i32 to i64
      %83 = nvvm.read.ptx.sreg.tid.x range <i32, 0, 4> : i32
      %84 = llvm.sext %83 : i32 to i64
      %85 = llvm.mul %82, %80 : i64
      %86 = llvm.mul %84, %79 : i64
      %87 = llvm.add %85, %80 : i64
      llvm.br ^bb1(%85 : i64)
    ^bb1(%88: i64):  // 2 preds: ^bb0, ^bb5
      %89 = llvm.icmp "slt" %88, %87 : i64
      llvm.cond_br %89, ^bb2, ^bb6
    ^bb2:  // pred: ^bb1
      %90 = llvm.add %86, %79 : i64
      llvm.br ^bb3(%86 : i64)
    ^bb3(%91: i64):  // 2 preds: ^bb2, ^bb4
      %92 = llvm.icmp "slt" %91, %90 : i64
      llvm.cond_br %92, ^bb4, ^bb5
    ^bb4:  // pred: ^bb3
      %93 = llvm.extractvalue %77[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %94 = llvm.mlir.constant(64 : index) : i64
      %95 = llvm.mul %88, %94 overflow<nsw, nuw> : i64
      %96 = llvm.add %95, %91 overflow<nsw, nuw> : i64
      %97 = llvm.getelementptr inbounds|nuw %93[%96] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %98 = llvm.load %97 : !llvm.ptr -> f32
      %99 = llvm.extractvalue %64[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %100 = llvm.mlir.constant(64 : index) : i64
      %101 = llvm.mul %88, %100 overflow<nsw, nuw> : i64
      %102 = llvm.add %101, %91 overflow<nsw, nuw> : i64
      %103 = llvm.getelementptr inbounds|nuw %99[%102] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %104 = llvm.load %103 : !llvm.ptr -> f32
      %105 = llvm.fadd %98, %104 : f32
      %106 = llvm.extractvalue %51[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %107 = llvm.mlir.constant(64 : index) : i64
      %108 = llvm.mul %88, %107 overflow<nsw, nuw> : i64
      %109 = llvm.add %108, %91 overflow<nsw, nuw> : i64
      %110 = llvm.getelementptr inbounds|nuw %106[%109] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      llvm.store %105, %110 : f32, !llvm.ptr
      %111 = llvm.extractvalue %77[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %112 = llvm.mlir.constant(64 : index) : i64
      %113 = llvm.mul %88, %112 overflow<nsw, nuw> : i64
      %114 = llvm.add %113, %91 overflow<nsw, nuw> : i64
      %115 = llvm.getelementptr inbounds|nuw %111[%114] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %116 = llvm.load %115 : !llvm.ptr -> f32
      %117 = llvm.extractvalue %51[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %118 = llvm.mlir.constant(64 : index) : i64
      %119 = llvm.mul %88, %118 overflow<nsw, nuw> : i64
      %120 = llvm.add %119, %91 overflow<nsw, nuw> : i64
      %121 = llvm.getelementptr inbounds|nuw %117[%120] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %122 = llvm.load %121 : !llvm.ptr -> f32
      %123 = llvm.fadd %116, %122 : f32
      %124 = llvm.extractvalue %38[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %125 = llvm.mlir.constant(64 : index) : i64
      %126 = llvm.mul %88, %125 overflow<nsw, nuw> : i64
      %127 = llvm.add %126, %91 overflow<nsw, nuw> : i64
      %128 = llvm.getelementptr inbounds|nuw %124[%127] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      llvm.store %123, %128 : f32, !llvm.ptr
      %129 = llvm.extractvalue %51[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %130 = llvm.mlir.constant(64 : index) : i64
      %131 = llvm.mul %88, %130 overflow<nsw, nuw> : i64
      %132 = llvm.add %131, %91 overflow<nsw, nuw> : i64
      %133 = llvm.getelementptr inbounds|nuw %129[%132] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %134 = llvm.load %133 : !llvm.ptr -> f32
      %135 = llvm.extractvalue %77[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %136 = llvm.mlir.constant(64 : index) : i64
      %137 = llvm.mul %88, %136 overflow<nsw, nuw> : i64
      %138 = llvm.add %137, %91 overflow<nsw, nuw> : i64
      %139 = llvm.getelementptr inbounds|nuw %135[%138] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %140 = llvm.load %139 : !llvm.ptr -> f32
      %141 = llvm.fmul %134, %140 : f32
      %142 = llvm.extractvalue %25[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %143 = llvm.mlir.constant(64 : index) : i64
      %144 = llvm.mul %88, %143 overflow<nsw, nuw> : i64
      %145 = llvm.add %144, %91 overflow<nsw, nuw> : i64
      %146 = llvm.getelementptr inbounds|nuw %142[%145] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      llvm.store %141, %146 : f32, !llvm.ptr
      %147 = llvm.extractvalue %38[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %148 = llvm.mlir.constant(64 : index) : i64
      %149 = llvm.mul %88, %148 overflow<nsw, nuw> : i64
      %150 = llvm.add %149, %91 overflow<nsw, nuw> : i64
      %151 = llvm.getelementptr inbounds|nuw %147[%150] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %152 = llvm.load %151 : !llvm.ptr -> f32
      %153 = llvm.extractvalue %25[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %154 = llvm.mlir.constant(64 : index) : i64
      %155 = llvm.mul %88, %154 overflow<nsw, nuw> : i64
      %156 = llvm.add %155, %91 overflow<nsw, nuw> : i64
      %157 = llvm.getelementptr inbounds|nuw %153[%156] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      %158 = llvm.load %157 : !llvm.ptr -> f32
      %159 = llvm.fmul %152, %158 : f32
      %160 = llvm.extractvalue %12[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
      %161 = llvm.mlir.constant(64 : index) : i64
      %162 = llvm.mul %88, %161 overflow<nsw, nuw> : i64
      %163 = llvm.add %162, %91 overflow<nsw, nuw> : i64
      %164 = llvm.getelementptr inbounds|nuw %160[%163] : (!llvm.ptr, i64) -> !llvm.ptr, f32
      llvm.store %159, %164 : f32, !llvm.ptr
      %165 = llvm.add %91, %78 : i64
      llvm.br ^bb3(%165 : i64)
    ^bb5:  // pred: ^bb3
      %166 = llvm.add %88, %78 : i64
      llvm.br ^bb1(%166 : i64)
    ^bb6:  // pred: ^bb1
      llvm.return
    }
  }
}


