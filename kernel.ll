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

61:                                               ; preds = %85, %14
  %62 = phi i64 [ 0, %14 ], [ %86, %85 ]
  %63 = icmp slt i64 %62, 32
  br i1 %63, label %64, label %87

64:                                               ; preds = %61
  br label %65

65:                                               ; preds = %68, %64
  %66 = phi i64 [ 0, %64 ], [ %84, %68 ]
  %67 = icmp slt i64 %66, 64
  br i1 %67, label %68, label %85

68:                                               ; preds = %65
  %69 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %28, 1
  %70 = mul nuw nsw i64 %62, 64
  %71 = add nuw nsw i64 %70, %66
  %72 = getelementptr inbounds nuw float, ptr %69, i64 %71
  %73 = load float, ptr %72, align 4
  %74 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %21, 1
  %75 = mul nuw nsw i64 %62, 64
  %76 = add nuw nsw i64 %75, %66
  %77 = getelementptr inbounds nuw float, ptr %74, i64 %76
  %78 = load float, ptr %77, align 4
  %79 = fadd float %73, %78
  %80 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %60, 1
  %81 = mul nuw nsw i64 %62, 64
  %82 = add nuw nsw i64 %81, %66
  %83 = getelementptr inbounds nuw float, ptr %80, i64 %82
  store float %79, ptr %83, align 4
  %84 = add i64 %66, 1
  br label %65

85:                                               ; preds = %65
  %86 = add i64 %62, 1
  br label %61

87:                                               ; preds = %61
  br label %88

88:                                               ; preds = %112, %87
  %89 = phi i64 [ 0, %87 ], [ %113, %112 ]
  %90 = icmp slt i64 %89, 32
  br i1 %90, label %91, label %114

91:                                               ; preds = %88
  br label %92

92:                                               ; preds = %95, %91
  %93 = phi i64 [ 0, %91 ], [ %111, %95 ]
  %94 = icmp slt i64 %93, 64
  br i1 %94, label %95, label %112

95:                                               ; preds = %92
  %96 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %28, 1
  %97 = mul nuw nsw i64 %89, 64
  %98 = add nuw nsw i64 %97, %93
  %99 = getelementptr inbounds nuw float, ptr %96, i64 %98
  %100 = load float, ptr %99, align 4
  %101 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %60, 1
  %102 = mul nuw nsw i64 %89, 64
  %103 = add nuw nsw i64 %102, %93
  %104 = getelementptr inbounds nuw float, ptr %101, i64 %103
  %105 = load float, ptr %104, align 4
  %106 = fadd float %100, %105
  %107 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %52, 1
  %108 = mul nuw nsw i64 %89, 64
  %109 = add nuw nsw i64 %108, %93
  %110 = getelementptr inbounds nuw float, ptr %107, i64 %109
  store float %106, ptr %110, align 4
  %111 = add i64 %93, 1
  br label %92

112:                                              ; preds = %92
  %113 = add i64 %89, 1
  br label %88

114:                                              ; preds = %88
  br label %115

115:                                              ; preds = %139, %114
  %116 = phi i64 [ 0, %114 ], [ %140, %139 ]
  %117 = icmp slt i64 %116, 32
  br i1 %117, label %118, label %141

118:                                              ; preds = %115
  br label %119

119:                                              ; preds = %122, %118
  %120 = phi i64 [ 0, %118 ], [ %138, %122 ]
  %121 = icmp slt i64 %120, 64
  br i1 %121, label %122, label %139

122:                                              ; preds = %119
  %123 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %60, 1
  %124 = mul nuw nsw i64 %116, 64
  %125 = add nuw nsw i64 %124, %120
  %126 = getelementptr inbounds nuw float, ptr %123, i64 %125
  %127 = load float, ptr %126, align 4
  %128 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %28, 1
  %129 = mul nuw nsw i64 %116, 64
  %130 = add nuw nsw i64 %129, %120
  %131 = getelementptr inbounds nuw float, ptr %128, i64 %130
  %132 = load float, ptr %131, align 4
  %133 = fmul float %127, %132
  %134 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %44, 1
  %135 = mul nuw nsw i64 %116, 64
  %136 = add nuw nsw i64 %135, %120
  %137 = getelementptr inbounds nuw float, ptr %134, i64 %136
  store float %133, ptr %137, align 4
  %138 = add i64 %120, 1
  br label %119

139:                                              ; preds = %119
  %140 = add i64 %116, 1
  br label %115

141:                                              ; preds = %115
  br label %142

142:                                              ; preds = %166, %141
  %143 = phi i64 [ 0, %141 ], [ %167, %166 ]
  %144 = icmp slt i64 %143, 32
  br i1 %144, label %145, label %168

145:                                              ; preds = %142
  br label %146

146:                                              ; preds = %149, %145
  %147 = phi i64 [ 0, %145 ], [ %165, %149 ]
  %148 = icmp slt i64 %147, 64
  br i1 %148, label %149, label %166

149:                                              ; preds = %146
  %150 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %52, 1
  %151 = mul nuw nsw i64 %143, 64
  %152 = add nuw nsw i64 %151, %147
  %153 = getelementptr inbounds nuw float, ptr %150, i64 %152
  %154 = load float, ptr %153, align 4
  %155 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %44, 1
  %156 = mul nuw nsw i64 %143, 64
  %157 = add nuw nsw i64 %156, %147
  %158 = getelementptr inbounds nuw float, ptr %155, i64 %157
  %159 = load float, ptr %158, align 4
  %160 = fmul float %154, %159
  %161 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %36, 1
  %162 = mul nuw nsw i64 %143, 64
  %163 = add nuw nsw i64 %162, %147
  %164 = getelementptr inbounds nuw float, ptr %161, i64 %163
  store float %160, ptr %164, align 4
  %165 = add i64 %147, 1
  br label %146

166:                                              ; preds = %146
  %167 = add i64 %143, 1
  br label %142

168:                                              ; preds = %142
  %169 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %60, 0
  call void @free(ptr %169)
  %170 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %52, 0
  call void @free(ptr %170)
  %171 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %44, 0
  call void @free(ptr %171)
  %172 = extractvalue { ptr, ptr, i64, [2 x i64], [2 x i64] } %36, 0
  call void @free(ptr %172)
  ret void
}

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
