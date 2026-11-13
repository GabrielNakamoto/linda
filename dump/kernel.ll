; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"

declare void @free(ptr)

declare ptr @malloc(i64)

define void @kernel(ptr %0, ptr %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, ptr %7, ptr %8, i64 %9, i64 %10, i64 %11, i64 %12, i64 %13) {
  %15 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %7, 0
  %16 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %15, ptr %8, 1
  %17 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %16, i64 %9, 2
  %18 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %17, i64 %10, 3, 0
  %19 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %18, i64 %12, 4, 0
  %20 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %19, i64 %11, 3, 1
  %21 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %20, i64 %13, 4, 1
  %22 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %0, 0
  %23 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %22, ptr %1, 1
  %24 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %23, i64 %2, 2
  %25 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %24, i64 %3, 3, 0
  %26 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %25, i64 %5, 4, 0
  %27 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %26, i64 %4, 3, 1
  %28 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %27, i64 %6, 4, 1
  %29 = call ptr @malloc(i64 8192)
  %30 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %29, 0
  %31 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %30, ptr %29, 1
  %32 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %31, i64 0, 2
  %33 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %32, i64 32, 3, 0
  %34 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %33, i64 64, 3, 1
  %35 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %34, i64 64, 4, 0
  %36 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %35, i64 1, 4, 1
  %37 = call ptr @malloc(i64 8192)
  %38 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %37, 0
  %39 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %38, ptr %37, 1
  %40 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %39, i64 0, 2
  %41 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %40, i64 32, 3, 0
  %42 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %41, i64 64, 3, 1
  %43 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %42, i64 64, 4, 0
  %44 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %43, i64 1, 4, 1
  %45 = call ptr @malloc(i64 8192)
  %46 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %45, 0
  %47 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %46, ptr %45, 1
  %48 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %47, i64 0, 2
  %49 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %48, i64 32, 3, 0
  %50 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %49, i64 64, 3, 1
  %51 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %50, i64 64, 4, 0
  %52 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %51, i64 1, 4, 1
  %53 = call ptr @malloc(i64 8192)
  %54 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } poison, ptr %53, 0
  %55 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %54, ptr %53, 1
  %56 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %55, i64 0, 2
  %57 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %56, i64 32, 3, 0
  %58 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %57, i64 64, 3, 1
  %59 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %58, i64 64, 4, 0
  %60 = insertvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %59, i64 1, 4, 1
  br label %61

61:                                               ; preds = %144, %14
  %62 = phi i64 [ 0, %14 ], [ %145, %144 ]
  %63 = icmp slt i64 %62, 32
  br i1 %63, label %64, label %146

64:                                               ; preds = %61
  br label %65

65:                                               ; preds = %142, %64
  %66 = phi i64 [ 0, %64 ], [ %143, %142 ]
  %67 = icmp slt i64 %66, 64
  br i1 %67, label %68, label %144

68:                                               ; preds = %65
  %69 = add i64 %62, 8
  br label %70

70:                                               ; preds = %140, %68
  %71 = phi i64 [ %62, %68 ], [ %141, %140 ]
  %72 = icmp slt i64 %71, %69
  br i1 %72, label %73, label %142

73:                                               ; preds = %70
  %74 = add i64 %66, 16
  br label %75

75:                                               ; preds = %78, %73
  %76 = phi i64 [ %66, %73 ], [ %139, %78 ]
  %77 = icmp slt i64 %76, %74
  br i1 %77, label %78, label %140

78:                                               ; preds = %75
  %79 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %28, 1
  %80 = mul nuw nsw i64 %71, 64
  %81 = add nuw nsw i64 %80, %76
  %82 = getelementptr inbounds nuw float, ptr %79, i64 %81
  %83 = load float, ptr %82, align 4
  %84 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %21, 1
  %85 = mul nuw nsw i64 %71, 64
  %86 = add nuw nsw i64 %85, %76
  %87 = getelementptr inbounds nuw float, ptr %84, i64 %86
  %88 = load float, ptr %87, align 4
  %89 = fadd float %83, %88
  %90 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %60, 1
  %91 = mul nuw nsw i64 %71, 64
  %92 = add nuw nsw i64 %91, %76
  %93 = getelementptr inbounds nuw float, ptr %90, i64 %92
  store float %89, ptr %93, align 4
  %94 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %28, 1
  %95 = mul nuw nsw i64 %71, 64
  %96 = add nuw nsw i64 %95, %76
  %97 = getelementptr inbounds nuw float, ptr %94, i64 %96
  %98 = load float, ptr %97, align 4
  %99 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %60, 1
  %100 = mul nuw nsw i64 %71, 64
  %101 = add nuw nsw i64 %100, %76
  %102 = getelementptr inbounds nuw float, ptr %99, i64 %101
  %103 = load float, ptr %102, align 4
  %104 = fadd float %98, %103
  %105 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %52, 1
  %106 = mul nuw nsw i64 %71, 64
  %107 = add nuw nsw i64 %106, %76
  %108 = getelementptr inbounds nuw float, ptr %105, i64 %107
  store float %104, ptr %108, align 4
  %109 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %60, 1
  %110 = mul nuw nsw i64 %71, 64
  %111 = add nuw nsw i64 %110, %76
  %112 = getelementptr inbounds nuw float, ptr %109, i64 %111
  %113 = load float, ptr %112, align 4
  %114 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %28, 1
  %115 = mul nuw nsw i64 %71, 64
  %116 = add nuw nsw i64 %115, %76
  %117 = getelementptr inbounds nuw float, ptr %114, i64 %116
  %118 = load float, ptr %117, align 4
  %119 = fmul float %113, %118
  %120 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %44, 1
  %121 = mul nuw nsw i64 %71, 64
  %122 = add nuw nsw i64 %121, %76
  %123 = getelementptr inbounds nuw float, ptr %120, i64 %122
  store float %119, ptr %123, align 4
  %124 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %52, 1
  %125 = mul nuw nsw i64 %71, 64
  %126 = add nuw nsw i64 %125, %76
  %127 = getelementptr inbounds nuw float, ptr %124, i64 %126
  %128 = load float, ptr %127, align 4
  %129 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %44, 1
  %130 = mul nuw nsw i64 %71, 64
  %131 = add nuw nsw i64 %130, %76
  %132 = getelementptr inbounds nuw float, ptr %129, i64 %131
  %133 = load float, ptr %132, align 4
  %134 = fmul float %128, %133
  %135 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %36, 1
  %136 = mul nuw nsw i64 %71, 64
  %137 = add nuw nsw i64 %136, %76
  %138 = getelementptr inbounds nuw float, ptr %135, i64 %137
  store float %134, ptr %138, align 4
  %139 = add i64 %76, 1
  br label %75

140:                                              ; preds = %75
  %141 = add i64 %71, 1
  br label %70

142:                                              ; preds = %70
  %143 = add i64 %66, 16
  br label %65

144:                                              ; preds = %65
  %145 = add i64 %62, 8
  br label %61

146:                                              ; preds = %61
  %147 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %60, 0
  call void @free(ptr %147)
  %148 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %52, 0
  call void @free(ptr %148)
  %149 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %44, 0
  call void @free(ptr %149)
  %150 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %36, 0
  call void @free(ptr %150)
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
