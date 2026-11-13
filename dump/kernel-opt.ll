; ModuleID = 'LLVMDialectModule'
source_filename = "LLVMDialectModule"
target datalayout = "e-m:e-p:64:64-p1:64:64-p2:32:32-p3:32:32-p4:64:64-p5:32:32-p6:32:32-p7:160:256:256:32-p8:128:128:128:48-p9:192:256:256:32-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024-v2048:2048-n32:64-S32-A5-G1-ni:7:8:9"
target triple = "amdgcn-amd-amdhsa"

declare void @free(ptr) local_unnamed_addr #0

declare ptr @malloc(i64) local_unnamed_addr #0

define void @kernel(ptr readnone captures(none) %0, ptr readonly captures(none) %1, i64 %2, i64 %3, i64 %4, i64 %5, i64 %6, ptr readnone captures(none) %7, ptr readonly captures(none) %8, i64 %9, i64 %10, i64 %11, i64 %12, i64 %13) local_unnamed_addr #0 {
  %15 = tail call ptr @malloc(i64 8192)
  %16 = tail call ptr @malloc(i64 8192)
  %17 = tail call ptr @malloc(i64 8192)
  %18 = tail call ptr @malloc(i64 8192)
  br label %.preheader

.preheader:                                       ; preds = %14, %623
  %19 = phi i64 [ 0, %14 ], [ %624, %623 ]
  %20 = shl nuw nsw i64 %19, 6
  %21 = shl i64 %19, 6
  %22 = or disjoint i64 %21, 64
  %23 = shl i64 %19, 6
  %24 = or disjoint i64 %23, 128
  %25 = shl i64 %19, 6
  %26 = or disjoint i64 %25, 192
  %27 = shl i64 %19, 6
  %28 = or disjoint i64 %27, 256
  %29 = shl i64 %19, 6
  %30 = or disjoint i64 %29, 320
  %31 = shl i64 %19, 6
  %32 = or disjoint i64 %31, 384
  %33 = shl i64 %19, 6
  %34 = or disjoint i64 %33, 448
  br label %.lr.ph

.lr.ph:                                           ; preds = %.preheader, %._crit_edge
  %indvars.iv = phi i64 [ 16, %.preheader ], [ %indvars.iv.next, %._crit_edge ]
  %35 = phi i64 [ 0, %.preheader ], [ %621, %._crit_edge ]
  br label %36

36:                                               ; preds = %36, %.lr.ph
  %37 = phi i64 [ %35, %.lr.ph ], [ %109, %36 ]
  %38 = add nuw nsw i64 %37, %20
  %39 = getelementptr inbounds nuw float, ptr %1, i64 %38
  %40 = load float, ptr %39, align 4
  %41 = getelementptr inbounds nuw float, ptr %8, i64 %38
  %42 = load float, ptr %41, align 4
  %43 = fadd float %40, %42
  %44 = getelementptr inbounds nuw float, ptr %18, i64 %38
  store float %43, ptr %44, align 4
  %45 = load float, ptr %39, align 4
  %46 = fadd float %43, %45
  %47 = getelementptr inbounds nuw float, ptr %17, i64 %38
  store float %46, ptr %47, align 4
  %48 = load float, ptr %44, align 4
  %49 = load float, ptr %39, align 4
  %50 = fmul float %48, %49
  %51 = getelementptr inbounds nuw float, ptr %16, i64 %38
  store float %50, ptr %51, align 4
  %52 = load float, ptr %47, align 4
  %53 = fmul float %50, %52
  %54 = getelementptr inbounds nuw float, ptr %15, i64 %38
  store float %53, ptr %54, align 4
  %55 = or disjoint i64 %37, 1
  %56 = add nuw nsw i64 %55, %20
  %57 = getelementptr inbounds nuw float, ptr %1, i64 %56
  %58 = load float, ptr %57, align 4
  %59 = getelementptr inbounds nuw float, ptr %8, i64 %56
  %60 = load float, ptr %59, align 4
  %61 = fadd float %58, %60
  %62 = getelementptr inbounds nuw float, ptr %18, i64 %56
  store float %61, ptr %62, align 4
  %63 = load float, ptr %57, align 4
  %64 = fadd float %61, %63
  %65 = getelementptr inbounds nuw float, ptr %17, i64 %56
  store float %64, ptr %65, align 4
  %66 = load float, ptr %62, align 4
  %67 = load float, ptr %57, align 4
  %68 = fmul float %66, %67
  %69 = getelementptr inbounds nuw float, ptr %16, i64 %56
  store float %68, ptr %69, align 4
  %70 = load float, ptr %65, align 4
  %71 = fmul float %68, %70
  %72 = getelementptr inbounds nuw float, ptr %15, i64 %56
  store float %71, ptr %72, align 4
  %73 = or disjoint i64 %37, 2
  %74 = add nuw nsw i64 %73, %20
  %75 = getelementptr inbounds nuw float, ptr %1, i64 %74
  %76 = load float, ptr %75, align 4
  %77 = getelementptr inbounds nuw float, ptr %8, i64 %74
  %78 = load float, ptr %77, align 4
  %79 = fadd float %76, %78
  %80 = getelementptr inbounds nuw float, ptr %18, i64 %74
  store float %79, ptr %80, align 4
  %81 = load float, ptr %75, align 4
  %82 = fadd float %79, %81
  %83 = getelementptr inbounds nuw float, ptr %17, i64 %74
  store float %82, ptr %83, align 4
  %84 = load float, ptr %80, align 4
  %85 = load float, ptr %75, align 4
  %86 = fmul float %84, %85
  %87 = getelementptr inbounds nuw float, ptr %16, i64 %74
  store float %86, ptr %87, align 4
  %88 = load float, ptr %83, align 4
  %89 = fmul float %86, %88
  %90 = getelementptr inbounds nuw float, ptr %15, i64 %74
  store float %89, ptr %90, align 4
  %91 = or disjoint i64 %37, 3
  %92 = add nuw nsw i64 %91, %20
  %93 = getelementptr inbounds nuw float, ptr %1, i64 %92
  %94 = load float, ptr %93, align 4
  %95 = getelementptr inbounds nuw float, ptr %8, i64 %92
  %96 = load float, ptr %95, align 4
  %97 = fadd float %94, %96
  %98 = getelementptr inbounds nuw float, ptr %18, i64 %92
  store float %97, ptr %98, align 4
  %99 = load float, ptr %93, align 4
  %100 = fadd float %97, %99
  %101 = getelementptr inbounds nuw float, ptr %17, i64 %92
  store float %100, ptr %101, align 4
  %102 = load float, ptr %98, align 4
  %103 = load float, ptr %93, align 4
  %104 = fmul float %102, %103
  %105 = getelementptr inbounds nuw float, ptr %16, i64 %92
  store float %104, ptr %105, align 4
  %106 = load float, ptr %101, align 4
  %107 = fmul float %104, %106
  %108 = getelementptr inbounds nuw float, ptr %15, i64 %92
  store float %107, ptr %108, align 4
  %109 = add nuw nsw i64 %37, 4
  %exitcond.not.3 = icmp eq i64 %109, %indvars.iv
  br i1 %exitcond.not.3, label %.preheader12, label %36

.preheader12:                                     ; preds = %36, %.preheader12
  %110 = phi i64 [ %182, %.preheader12 ], [ %35, %36 ]
  %111 = add nuw nsw i64 %110, %22
  %112 = getelementptr inbounds nuw float, ptr %1, i64 %111
  %113 = load float, ptr %112, align 4
  %114 = getelementptr inbounds nuw float, ptr %8, i64 %111
  %115 = load float, ptr %114, align 4
  %116 = fadd float %113, %115
  %117 = getelementptr inbounds nuw float, ptr %18, i64 %111
  store float %116, ptr %117, align 4
  %118 = load float, ptr %112, align 4
  %119 = fadd float %116, %118
  %120 = getelementptr inbounds nuw float, ptr %17, i64 %111
  store float %119, ptr %120, align 4
  %121 = load float, ptr %117, align 4
  %122 = load float, ptr %112, align 4
  %123 = fmul float %121, %122
  %124 = getelementptr inbounds nuw float, ptr %16, i64 %111
  store float %123, ptr %124, align 4
  %125 = load float, ptr %120, align 4
  %126 = fmul float %123, %125
  %127 = getelementptr inbounds nuw float, ptr %15, i64 %111
  store float %126, ptr %127, align 4
  %128 = or disjoint i64 %110, 1
  %129 = add nuw nsw i64 %128, %22
  %130 = getelementptr inbounds nuw float, ptr %1, i64 %129
  %131 = load float, ptr %130, align 4
  %132 = getelementptr inbounds nuw float, ptr %8, i64 %129
  %133 = load float, ptr %132, align 4
  %134 = fadd float %131, %133
  %135 = getelementptr inbounds nuw float, ptr %18, i64 %129
  store float %134, ptr %135, align 4
  %136 = load float, ptr %130, align 4
  %137 = fadd float %134, %136
  %138 = getelementptr inbounds nuw float, ptr %17, i64 %129
  store float %137, ptr %138, align 4
  %139 = load float, ptr %135, align 4
  %140 = load float, ptr %130, align 4
  %141 = fmul float %139, %140
  %142 = getelementptr inbounds nuw float, ptr %16, i64 %129
  store float %141, ptr %142, align 4
  %143 = load float, ptr %138, align 4
  %144 = fmul float %141, %143
  %145 = getelementptr inbounds nuw float, ptr %15, i64 %129
  store float %144, ptr %145, align 4
  %146 = or disjoint i64 %110, 2
  %147 = add nuw nsw i64 %146, %22
  %148 = getelementptr inbounds nuw float, ptr %1, i64 %147
  %149 = load float, ptr %148, align 4
  %150 = getelementptr inbounds nuw float, ptr %8, i64 %147
  %151 = load float, ptr %150, align 4
  %152 = fadd float %149, %151
  %153 = getelementptr inbounds nuw float, ptr %18, i64 %147
  store float %152, ptr %153, align 4
  %154 = load float, ptr %148, align 4
  %155 = fadd float %152, %154
  %156 = getelementptr inbounds nuw float, ptr %17, i64 %147
  store float %155, ptr %156, align 4
  %157 = load float, ptr %153, align 4
  %158 = load float, ptr %148, align 4
  %159 = fmul float %157, %158
  %160 = getelementptr inbounds nuw float, ptr %16, i64 %147
  store float %159, ptr %160, align 4
  %161 = load float, ptr %156, align 4
  %162 = fmul float %159, %161
  %163 = getelementptr inbounds nuw float, ptr %15, i64 %147
  store float %162, ptr %163, align 4
  %164 = or disjoint i64 %110, 3
  %165 = add nuw nsw i64 %164, %22
  %166 = getelementptr inbounds nuw float, ptr %1, i64 %165
  %167 = load float, ptr %166, align 4
  %168 = getelementptr inbounds nuw float, ptr %8, i64 %165
  %169 = load float, ptr %168, align 4
  %170 = fadd float %167, %169
  %171 = getelementptr inbounds nuw float, ptr %18, i64 %165
  store float %170, ptr %171, align 4
  %172 = load float, ptr %166, align 4
  %173 = fadd float %170, %172
  %174 = getelementptr inbounds nuw float, ptr %17, i64 %165
  store float %173, ptr %174, align 4
  %175 = load float, ptr %171, align 4
  %176 = load float, ptr %166, align 4
  %177 = fmul float %175, %176
  %178 = getelementptr inbounds nuw float, ptr %16, i64 %165
  store float %177, ptr %178, align 4
  %179 = load float, ptr %174, align 4
  %180 = fmul float %177, %179
  %181 = getelementptr inbounds nuw float, ptr %15, i64 %165
  store float %180, ptr %181, align 4
  %182 = add nuw nsw i64 %110, 4
  %exitcond.1.not.3 = icmp eq i64 %182, %indvars.iv
  br i1 %exitcond.1.not.3, label %.preheader11, label %.preheader12

.preheader11:                                     ; preds = %.preheader12, %.preheader11
  %183 = phi i64 [ %255, %.preheader11 ], [ %35, %.preheader12 ]
  %184 = add nuw nsw i64 %183, %24
  %185 = getelementptr inbounds nuw float, ptr %1, i64 %184
  %186 = load float, ptr %185, align 4
  %187 = getelementptr inbounds nuw float, ptr %8, i64 %184
  %188 = load float, ptr %187, align 4
  %189 = fadd float %186, %188
  %190 = getelementptr inbounds nuw float, ptr %18, i64 %184
  store float %189, ptr %190, align 4
  %191 = load float, ptr %185, align 4
  %192 = fadd float %189, %191
  %193 = getelementptr inbounds nuw float, ptr %17, i64 %184
  store float %192, ptr %193, align 4
  %194 = load float, ptr %190, align 4
  %195 = load float, ptr %185, align 4
  %196 = fmul float %194, %195
  %197 = getelementptr inbounds nuw float, ptr %16, i64 %184
  store float %196, ptr %197, align 4
  %198 = load float, ptr %193, align 4
  %199 = fmul float %196, %198
  %200 = getelementptr inbounds nuw float, ptr %15, i64 %184
  store float %199, ptr %200, align 4
  %201 = or disjoint i64 %183, 1
  %202 = add nuw nsw i64 %201, %24
  %203 = getelementptr inbounds nuw float, ptr %1, i64 %202
  %204 = load float, ptr %203, align 4
  %205 = getelementptr inbounds nuw float, ptr %8, i64 %202
  %206 = load float, ptr %205, align 4
  %207 = fadd float %204, %206
  %208 = getelementptr inbounds nuw float, ptr %18, i64 %202
  store float %207, ptr %208, align 4
  %209 = load float, ptr %203, align 4
  %210 = fadd float %207, %209
  %211 = getelementptr inbounds nuw float, ptr %17, i64 %202
  store float %210, ptr %211, align 4
  %212 = load float, ptr %208, align 4
  %213 = load float, ptr %203, align 4
  %214 = fmul float %212, %213
  %215 = getelementptr inbounds nuw float, ptr %16, i64 %202
  store float %214, ptr %215, align 4
  %216 = load float, ptr %211, align 4
  %217 = fmul float %214, %216
  %218 = getelementptr inbounds nuw float, ptr %15, i64 %202
  store float %217, ptr %218, align 4
  %219 = or disjoint i64 %183, 2
  %220 = add nuw nsw i64 %219, %24
  %221 = getelementptr inbounds nuw float, ptr %1, i64 %220
  %222 = load float, ptr %221, align 4
  %223 = getelementptr inbounds nuw float, ptr %8, i64 %220
  %224 = load float, ptr %223, align 4
  %225 = fadd float %222, %224
  %226 = getelementptr inbounds nuw float, ptr %18, i64 %220
  store float %225, ptr %226, align 4
  %227 = load float, ptr %221, align 4
  %228 = fadd float %225, %227
  %229 = getelementptr inbounds nuw float, ptr %17, i64 %220
  store float %228, ptr %229, align 4
  %230 = load float, ptr %226, align 4
  %231 = load float, ptr %221, align 4
  %232 = fmul float %230, %231
  %233 = getelementptr inbounds nuw float, ptr %16, i64 %220
  store float %232, ptr %233, align 4
  %234 = load float, ptr %229, align 4
  %235 = fmul float %232, %234
  %236 = getelementptr inbounds nuw float, ptr %15, i64 %220
  store float %235, ptr %236, align 4
  %237 = or disjoint i64 %183, 3
  %238 = add nuw nsw i64 %237, %24
  %239 = getelementptr inbounds nuw float, ptr %1, i64 %238
  %240 = load float, ptr %239, align 4
  %241 = getelementptr inbounds nuw float, ptr %8, i64 %238
  %242 = load float, ptr %241, align 4
  %243 = fadd float %240, %242
  %244 = getelementptr inbounds nuw float, ptr %18, i64 %238
  store float %243, ptr %244, align 4
  %245 = load float, ptr %239, align 4
  %246 = fadd float %243, %245
  %247 = getelementptr inbounds nuw float, ptr %17, i64 %238
  store float %246, ptr %247, align 4
  %248 = load float, ptr %244, align 4
  %249 = load float, ptr %239, align 4
  %250 = fmul float %248, %249
  %251 = getelementptr inbounds nuw float, ptr %16, i64 %238
  store float %250, ptr %251, align 4
  %252 = load float, ptr %247, align 4
  %253 = fmul float %250, %252
  %254 = getelementptr inbounds nuw float, ptr %15, i64 %238
  store float %253, ptr %254, align 4
  %255 = add nuw nsw i64 %183, 4
  %exitcond.2.not.3 = icmp eq i64 %255, %indvars.iv
  br i1 %exitcond.2.not.3, label %.preheader10, label %.preheader11

.preheader10:                                     ; preds = %.preheader11, %.preheader10
  %256 = phi i64 [ %328, %.preheader10 ], [ %35, %.preheader11 ]
  %257 = add nuw nsw i64 %256, %26
  %258 = getelementptr inbounds nuw float, ptr %1, i64 %257
  %259 = load float, ptr %258, align 4
  %260 = getelementptr inbounds nuw float, ptr %8, i64 %257
  %261 = load float, ptr %260, align 4
  %262 = fadd float %259, %261
  %263 = getelementptr inbounds nuw float, ptr %18, i64 %257
  store float %262, ptr %263, align 4
  %264 = load float, ptr %258, align 4
  %265 = fadd float %262, %264
  %266 = getelementptr inbounds nuw float, ptr %17, i64 %257
  store float %265, ptr %266, align 4
  %267 = load float, ptr %263, align 4
  %268 = load float, ptr %258, align 4
  %269 = fmul float %267, %268
  %270 = getelementptr inbounds nuw float, ptr %16, i64 %257
  store float %269, ptr %270, align 4
  %271 = load float, ptr %266, align 4
  %272 = fmul float %269, %271
  %273 = getelementptr inbounds nuw float, ptr %15, i64 %257
  store float %272, ptr %273, align 4
  %274 = or disjoint i64 %256, 1
  %275 = add nuw nsw i64 %274, %26
  %276 = getelementptr inbounds nuw float, ptr %1, i64 %275
  %277 = load float, ptr %276, align 4
  %278 = getelementptr inbounds nuw float, ptr %8, i64 %275
  %279 = load float, ptr %278, align 4
  %280 = fadd float %277, %279
  %281 = getelementptr inbounds nuw float, ptr %18, i64 %275
  store float %280, ptr %281, align 4
  %282 = load float, ptr %276, align 4
  %283 = fadd float %280, %282
  %284 = getelementptr inbounds nuw float, ptr %17, i64 %275
  store float %283, ptr %284, align 4
  %285 = load float, ptr %281, align 4
  %286 = load float, ptr %276, align 4
  %287 = fmul float %285, %286
  %288 = getelementptr inbounds nuw float, ptr %16, i64 %275
  store float %287, ptr %288, align 4
  %289 = load float, ptr %284, align 4
  %290 = fmul float %287, %289
  %291 = getelementptr inbounds nuw float, ptr %15, i64 %275
  store float %290, ptr %291, align 4
  %292 = or disjoint i64 %256, 2
  %293 = add nuw nsw i64 %292, %26
  %294 = getelementptr inbounds nuw float, ptr %1, i64 %293
  %295 = load float, ptr %294, align 4
  %296 = getelementptr inbounds nuw float, ptr %8, i64 %293
  %297 = load float, ptr %296, align 4
  %298 = fadd float %295, %297
  %299 = getelementptr inbounds nuw float, ptr %18, i64 %293
  store float %298, ptr %299, align 4
  %300 = load float, ptr %294, align 4
  %301 = fadd float %298, %300
  %302 = getelementptr inbounds nuw float, ptr %17, i64 %293
  store float %301, ptr %302, align 4
  %303 = load float, ptr %299, align 4
  %304 = load float, ptr %294, align 4
  %305 = fmul float %303, %304
  %306 = getelementptr inbounds nuw float, ptr %16, i64 %293
  store float %305, ptr %306, align 4
  %307 = load float, ptr %302, align 4
  %308 = fmul float %305, %307
  %309 = getelementptr inbounds nuw float, ptr %15, i64 %293
  store float %308, ptr %309, align 4
  %310 = or disjoint i64 %256, 3
  %311 = add nuw nsw i64 %310, %26
  %312 = getelementptr inbounds nuw float, ptr %1, i64 %311
  %313 = load float, ptr %312, align 4
  %314 = getelementptr inbounds nuw float, ptr %8, i64 %311
  %315 = load float, ptr %314, align 4
  %316 = fadd float %313, %315
  %317 = getelementptr inbounds nuw float, ptr %18, i64 %311
  store float %316, ptr %317, align 4
  %318 = load float, ptr %312, align 4
  %319 = fadd float %316, %318
  %320 = getelementptr inbounds nuw float, ptr %17, i64 %311
  store float %319, ptr %320, align 4
  %321 = load float, ptr %317, align 4
  %322 = load float, ptr %312, align 4
  %323 = fmul float %321, %322
  %324 = getelementptr inbounds nuw float, ptr %16, i64 %311
  store float %323, ptr %324, align 4
  %325 = load float, ptr %320, align 4
  %326 = fmul float %323, %325
  %327 = getelementptr inbounds nuw float, ptr %15, i64 %311
  store float %326, ptr %327, align 4
  %328 = add nuw nsw i64 %256, 4
  %exitcond.3.not.3 = icmp eq i64 %328, %indvars.iv
  br i1 %exitcond.3.not.3, label %.preheader9, label %.preheader10

.preheader9:                                      ; preds = %.preheader10, %.preheader9
  %329 = phi i64 [ %401, %.preheader9 ], [ %35, %.preheader10 ]
  %330 = add nuw nsw i64 %329, %28
  %331 = getelementptr inbounds nuw float, ptr %1, i64 %330
  %332 = load float, ptr %331, align 4
  %333 = getelementptr inbounds nuw float, ptr %8, i64 %330
  %334 = load float, ptr %333, align 4
  %335 = fadd float %332, %334
  %336 = getelementptr inbounds nuw float, ptr %18, i64 %330
  store float %335, ptr %336, align 4
  %337 = load float, ptr %331, align 4
  %338 = fadd float %335, %337
  %339 = getelementptr inbounds nuw float, ptr %17, i64 %330
  store float %338, ptr %339, align 4
  %340 = load float, ptr %336, align 4
  %341 = load float, ptr %331, align 4
  %342 = fmul float %340, %341
  %343 = getelementptr inbounds nuw float, ptr %16, i64 %330
  store float %342, ptr %343, align 4
  %344 = load float, ptr %339, align 4
  %345 = fmul float %342, %344
  %346 = getelementptr inbounds nuw float, ptr %15, i64 %330
  store float %345, ptr %346, align 4
  %347 = or disjoint i64 %329, 1
  %348 = add nuw nsw i64 %347, %28
  %349 = getelementptr inbounds nuw float, ptr %1, i64 %348
  %350 = load float, ptr %349, align 4
  %351 = getelementptr inbounds nuw float, ptr %8, i64 %348
  %352 = load float, ptr %351, align 4
  %353 = fadd float %350, %352
  %354 = getelementptr inbounds nuw float, ptr %18, i64 %348
  store float %353, ptr %354, align 4
  %355 = load float, ptr %349, align 4
  %356 = fadd float %353, %355
  %357 = getelementptr inbounds nuw float, ptr %17, i64 %348
  store float %356, ptr %357, align 4
  %358 = load float, ptr %354, align 4
  %359 = load float, ptr %349, align 4
  %360 = fmul float %358, %359
  %361 = getelementptr inbounds nuw float, ptr %16, i64 %348
  store float %360, ptr %361, align 4
  %362 = load float, ptr %357, align 4
  %363 = fmul float %360, %362
  %364 = getelementptr inbounds nuw float, ptr %15, i64 %348
  store float %363, ptr %364, align 4
  %365 = or disjoint i64 %329, 2
  %366 = add nuw nsw i64 %365, %28
  %367 = getelementptr inbounds nuw float, ptr %1, i64 %366
  %368 = load float, ptr %367, align 4
  %369 = getelementptr inbounds nuw float, ptr %8, i64 %366
  %370 = load float, ptr %369, align 4
  %371 = fadd float %368, %370
  %372 = getelementptr inbounds nuw float, ptr %18, i64 %366
  store float %371, ptr %372, align 4
  %373 = load float, ptr %367, align 4
  %374 = fadd float %371, %373
  %375 = getelementptr inbounds nuw float, ptr %17, i64 %366
  store float %374, ptr %375, align 4
  %376 = load float, ptr %372, align 4
  %377 = load float, ptr %367, align 4
  %378 = fmul float %376, %377
  %379 = getelementptr inbounds nuw float, ptr %16, i64 %366
  store float %378, ptr %379, align 4
  %380 = load float, ptr %375, align 4
  %381 = fmul float %378, %380
  %382 = getelementptr inbounds nuw float, ptr %15, i64 %366
  store float %381, ptr %382, align 4
  %383 = or disjoint i64 %329, 3
  %384 = add nuw nsw i64 %383, %28
  %385 = getelementptr inbounds nuw float, ptr %1, i64 %384
  %386 = load float, ptr %385, align 4
  %387 = getelementptr inbounds nuw float, ptr %8, i64 %384
  %388 = load float, ptr %387, align 4
  %389 = fadd float %386, %388
  %390 = getelementptr inbounds nuw float, ptr %18, i64 %384
  store float %389, ptr %390, align 4
  %391 = load float, ptr %385, align 4
  %392 = fadd float %389, %391
  %393 = getelementptr inbounds nuw float, ptr %17, i64 %384
  store float %392, ptr %393, align 4
  %394 = load float, ptr %390, align 4
  %395 = load float, ptr %385, align 4
  %396 = fmul float %394, %395
  %397 = getelementptr inbounds nuw float, ptr %16, i64 %384
  store float %396, ptr %397, align 4
  %398 = load float, ptr %393, align 4
  %399 = fmul float %396, %398
  %400 = getelementptr inbounds nuw float, ptr %15, i64 %384
  store float %399, ptr %400, align 4
  %401 = add nuw nsw i64 %329, 4
  %exitcond.4.not.3 = icmp eq i64 %401, %indvars.iv
  br i1 %exitcond.4.not.3, label %.preheader8, label %.preheader9

.preheader8:                                      ; preds = %.preheader9, %.preheader8
  %402 = phi i64 [ %474, %.preheader8 ], [ %35, %.preheader9 ]
  %403 = add nuw nsw i64 %402, %30
  %404 = getelementptr inbounds nuw float, ptr %1, i64 %403
  %405 = load float, ptr %404, align 4
  %406 = getelementptr inbounds nuw float, ptr %8, i64 %403
  %407 = load float, ptr %406, align 4
  %408 = fadd float %405, %407
  %409 = getelementptr inbounds nuw float, ptr %18, i64 %403
  store float %408, ptr %409, align 4
  %410 = load float, ptr %404, align 4
  %411 = fadd float %408, %410
  %412 = getelementptr inbounds nuw float, ptr %17, i64 %403
  store float %411, ptr %412, align 4
  %413 = load float, ptr %409, align 4
  %414 = load float, ptr %404, align 4
  %415 = fmul float %413, %414
  %416 = getelementptr inbounds nuw float, ptr %16, i64 %403
  store float %415, ptr %416, align 4
  %417 = load float, ptr %412, align 4
  %418 = fmul float %415, %417
  %419 = getelementptr inbounds nuw float, ptr %15, i64 %403
  store float %418, ptr %419, align 4
  %420 = or disjoint i64 %402, 1
  %421 = add nuw nsw i64 %420, %30
  %422 = getelementptr inbounds nuw float, ptr %1, i64 %421
  %423 = load float, ptr %422, align 4
  %424 = getelementptr inbounds nuw float, ptr %8, i64 %421
  %425 = load float, ptr %424, align 4
  %426 = fadd float %423, %425
  %427 = getelementptr inbounds nuw float, ptr %18, i64 %421
  store float %426, ptr %427, align 4
  %428 = load float, ptr %422, align 4
  %429 = fadd float %426, %428
  %430 = getelementptr inbounds nuw float, ptr %17, i64 %421
  store float %429, ptr %430, align 4
  %431 = load float, ptr %427, align 4
  %432 = load float, ptr %422, align 4
  %433 = fmul float %431, %432
  %434 = getelementptr inbounds nuw float, ptr %16, i64 %421
  store float %433, ptr %434, align 4
  %435 = load float, ptr %430, align 4
  %436 = fmul float %433, %435
  %437 = getelementptr inbounds nuw float, ptr %15, i64 %421
  store float %436, ptr %437, align 4
  %438 = or disjoint i64 %402, 2
  %439 = add nuw nsw i64 %438, %30
  %440 = getelementptr inbounds nuw float, ptr %1, i64 %439
  %441 = load float, ptr %440, align 4
  %442 = getelementptr inbounds nuw float, ptr %8, i64 %439
  %443 = load float, ptr %442, align 4
  %444 = fadd float %441, %443
  %445 = getelementptr inbounds nuw float, ptr %18, i64 %439
  store float %444, ptr %445, align 4
  %446 = load float, ptr %440, align 4
  %447 = fadd float %444, %446
  %448 = getelementptr inbounds nuw float, ptr %17, i64 %439
  store float %447, ptr %448, align 4
  %449 = load float, ptr %445, align 4
  %450 = load float, ptr %440, align 4
  %451 = fmul float %449, %450
  %452 = getelementptr inbounds nuw float, ptr %16, i64 %439
  store float %451, ptr %452, align 4
  %453 = load float, ptr %448, align 4
  %454 = fmul float %451, %453
  %455 = getelementptr inbounds nuw float, ptr %15, i64 %439
  store float %454, ptr %455, align 4
  %456 = or disjoint i64 %402, 3
  %457 = add nuw nsw i64 %456, %30
  %458 = getelementptr inbounds nuw float, ptr %1, i64 %457
  %459 = load float, ptr %458, align 4
  %460 = getelementptr inbounds nuw float, ptr %8, i64 %457
  %461 = load float, ptr %460, align 4
  %462 = fadd float %459, %461
  %463 = getelementptr inbounds nuw float, ptr %18, i64 %457
  store float %462, ptr %463, align 4
  %464 = load float, ptr %458, align 4
  %465 = fadd float %462, %464
  %466 = getelementptr inbounds nuw float, ptr %17, i64 %457
  store float %465, ptr %466, align 4
  %467 = load float, ptr %463, align 4
  %468 = load float, ptr %458, align 4
  %469 = fmul float %467, %468
  %470 = getelementptr inbounds nuw float, ptr %16, i64 %457
  store float %469, ptr %470, align 4
  %471 = load float, ptr %466, align 4
  %472 = fmul float %469, %471
  %473 = getelementptr inbounds nuw float, ptr %15, i64 %457
  store float %472, ptr %473, align 4
  %474 = add nuw nsw i64 %402, 4
  %exitcond.5.not.3 = icmp eq i64 %474, %indvars.iv
  br i1 %exitcond.5.not.3, label %.preheader7, label %.preheader8

.preheader7:                                      ; preds = %.preheader8, %.preheader7
  %475 = phi i64 [ %547, %.preheader7 ], [ %35, %.preheader8 ]
  %476 = add nuw nsw i64 %475, %32
  %477 = getelementptr inbounds nuw float, ptr %1, i64 %476
  %478 = load float, ptr %477, align 4
  %479 = getelementptr inbounds nuw float, ptr %8, i64 %476
  %480 = load float, ptr %479, align 4
  %481 = fadd float %478, %480
  %482 = getelementptr inbounds nuw float, ptr %18, i64 %476
  store float %481, ptr %482, align 4
  %483 = load float, ptr %477, align 4
  %484 = fadd float %481, %483
  %485 = getelementptr inbounds nuw float, ptr %17, i64 %476
  store float %484, ptr %485, align 4
  %486 = load float, ptr %482, align 4
  %487 = load float, ptr %477, align 4
  %488 = fmul float %486, %487
  %489 = getelementptr inbounds nuw float, ptr %16, i64 %476
  store float %488, ptr %489, align 4
  %490 = load float, ptr %485, align 4
  %491 = fmul float %488, %490
  %492 = getelementptr inbounds nuw float, ptr %15, i64 %476
  store float %491, ptr %492, align 4
  %493 = or disjoint i64 %475, 1
  %494 = add nuw nsw i64 %493, %32
  %495 = getelementptr inbounds nuw float, ptr %1, i64 %494
  %496 = load float, ptr %495, align 4
  %497 = getelementptr inbounds nuw float, ptr %8, i64 %494
  %498 = load float, ptr %497, align 4
  %499 = fadd float %496, %498
  %500 = getelementptr inbounds nuw float, ptr %18, i64 %494
  store float %499, ptr %500, align 4
  %501 = load float, ptr %495, align 4
  %502 = fadd float %499, %501
  %503 = getelementptr inbounds nuw float, ptr %17, i64 %494
  store float %502, ptr %503, align 4
  %504 = load float, ptr %500, align 4
  %505 = load float, ptr %495, align 4
  %506 = fmul float %504, %505
  %507 = getelementptr inbounds nuw float, ptr %16, i64 %494
  store float %506, ptr %507, align 4
  %508 = load float, ptr %503, align 4
  %509 = fmul float %506, %508
  %510 = getelementptr inbounds nuw float, ptr %15, i64 %494
  store float %509, ptr %510, align 4
  %511 = or disjoint i64 %475, 2
  %512 = add nuw nsw i64 %511, %32
  %513 = getelementptr inbounds nuw float, ptr %1, i64 %512
  %514 = load float, ptr %513, align 4
  %515 = getelementptr inbounds nuw float, ptr %8, i64 %512
  %516 = load float, ptr %515, align 4
  %517 = fadd float %514, %516
  %518 = getelementptr inbounds nuw float, ptr %18, i64 %512
  store float %517, ptr %518, align 4
  %519 = load float, ptr %513, align 4
  %520 = fadd float %517, %519
  %521 = getelementptr inbounds nuw float, ptr %17, i64 %512
  store float %520, ptr %521, align 4
  %522 = load float, ptr %518, align 4
  %523 = load float, ptr %513, align 4
  %524 = fmul float %522, %523
  %525 = getelementptr inbounds nuw float, ptr %16, i64 %512
  store float %524, ptr %525, align 4
  %526 = load float, ptr %521, align 4
  %527 = fmul float %524, %526
  %528 = getelementptr inbounds nuw float, ptr %15, i64 %512
  store float %527, ptr %528, align 4
  %529 = or disjoint i64 %475, 3
  %530 = add nuw nsw i64 %529, %32
  %531 = getelementptr inbounds nuw float, ptr %1, i64 %530
  %532 = load float, ptr %531, align 4
  %533 = getelementptr inbounds nuw float, ptr %8, i64 %530
  %534 = load float, ptr %533, align 4
  %535 = fadd float %532, %534
  %536 = getelementptr inbounds nuw float, ptr %18, i64 %530
  store float %535, ptr %536, align 4
  %537 = load float, ptr %531, align 4
  %538 = fadd float %535, %537
  %539 = getelementptr inbounds nuw float, ptr %17, i64 %530
  store float %538, ptr %539, align 4
  %540 = load float, ptr %536, align 4
  %541 = load float, ptr %531, align 4
  %542 = fmul float %540, %541
  %543 = getelementptr inbounds nuw float, ptr %16, i64 %530
  store float %542, ptr %543, align 4
  %544 = load float, ptr %539, align 4
  %545 = fmul float %542, %544
  %546 = getelementptr inbounds nuw float, ptr %15, i64 %530
  store float %545, ptr %546, align 4
  %547 = add nuw nsw i64 %475, 4
  %exitcond.6.not.3 = icmp eq i64 %547, %indvars.iv
  br i1 %exitcond.6.not.3, label %.preheader6, label %.preheader7

.preheader6:                                      ; preds = %.preheader7, %.preheader6
  %548 = phi i64 [ %620, %.preheader6 ], [ %35, %.preheader7 ]
  %549 = add nuw nsw i64 %548, %34
  %550 = getelementptr inbounds nuw float, ptr %1, i64 %549
  %551 = load float, ptr %550, align 4
  %552 = getelementptr inbounds nuw float, ptr %8, i64 %549
  %553 = load float, ptr %552, align 4
  %554 = fadd float %551, %553
  %555 = getelementptr inbounds nuw float, ptr %18, i64 %549
  store float %554, ptr %555, align 4
  %556 = load float, ptr %550, align 4
  %557 = fadd float %554, %556
  %558 = getelementptr inbounds nuw float, ptr %17, i64 %549
  store float %557, ptr %558, align 4
  %559 = load float, ptr %555, align 4
  %560 = load float, ptr %550, align 4
  %561 = fmul float %559, %560
  %562 = getelementptr inbounds nuw float, ptr %16, i64 %549
  store float %561, ptr %562, align 4
  %563 = load float, ptr %558, align 4
  %564 = fmul float %561, %563
  %565 = getelementptr inbounds nuw float, ptr %15, i64 %549
  store float %564, ptr %565, align 4
  %566 = or disjoint i64 %548, 1
  %567 = add nuw nsw i64 %566, %34
  %568 = getelementptr inbounds nuw float, ptr %1, i64 %567
  %569 = load float, ptr %568, align 4
  %570 = getelementptr inbounds nuw float, ptr %8, i64 %567
  %571 = load float, ptr %570, align 4
  %572 = fadd float %569, %571
  %573 = getelementptr inbounds nuw float, ptr %18, i64 %567
  store float %572, ptr %573, align 4
  %574 = load float, ptr %568, align 4
  %575 = fadd float %572, %574
  %576 = getelementptr inbounds nuw float, ptr %17, i64 %567
  store float %575, ptr %576, align 4
  %577 = load float, ptr %573, align 4
  %578 = load float, ptr %568, align 4
  %579 = fmul float %577, %578
  %580 = getelementptr inbounds nuw float, ptr %16, i64 %567
  store float %579, ptr %580, align 4
  %581 = load float, ptr %576, align 4
  %582 = fmul float %579, %581
  %583 = getelementptr inbounds nuw float, ptr %15, i64 %567
  store float %582, ptr %583, align 4
  %584 = or disjoint i64 %548, 2
  %585 = add nuw nsw i64 %584, %34
  %586 = getelementptr inbounds nuw float, ptr %1, i64 %585
  %587 = load float, ptr %586, align 4
  %588 = getelementptr inbounds nuw float, ptr %8, i64 %585
  %589 = load float, ptr %588, align 4
  %590 = fadd float %587, %589
  %591 = getelementptr inbounds nuw float, ptr %18, i64 %585
  store float %590, ptr %591, align 4
  %592 = load float, ptr %586, align 4
  %593 = fadd float %590, %592
  %594 = getelementptr inbounds nuw float, ptr %17, i64 %585
  store float %593, ptr %594, align 4
  %595 = load float, ptr %591, align 4
  %596 = load float, ptr %586, align 4
  %597 = fmul float %595, %596
  %598 = getelementptr inbounds nuw float, ptr %16, i64 %585
  store float %597, ptr %598, align 4
  %599 = load float, ptr %594, align 4
  %600 = fmul float %597, %599
  %601 = getelementptr inbounds nuw float, ptr %15, i64 %585
  store float %600, ptr %601, align 4
  %602 = or disjoint i64 %548, 3
  %603 = add nuw nsw i64 %602, %34
  %604 = getelementptr inbounds nuw float, ptr %1, i64 %603
  %605 = load float, ptr %604, align 4
  %606 = getelementptr inbounds nuw float, ptr %8, i64 %603
  %607 = load float, ptr %606, align 4
  %608 = fadd float %605, %607
  %609 = getelementptr inbounds nuw float, ptr %18, i64 %603
  store float %608, ptr %609, align 4
  %610 = load float, ptr %604, align 4
  %611 = fadd float %608, %610
  %612 = getelementptr inbounds nuw float, ptr %17, i64 %603
  store float %611, ptr %612, align 4
  %613 = load float, ptr %609, align 4
  %614 = load float, ptr %604, align 4
  %615 = fmul float %613, %614
  %616 = getelementptr inbounds nuw float, ptr %16, i64 %603
  store float %615, ptr %616, align 4
  %617 = load float, ptr %612, align 4
  %618 = fmul float %615, %617
  %619 = getelementptr inbounds nuw float, ptr %15, i64 %603
  store float %618, ptr %619, align 4
  %620 = add nuw nsw i64 %548, 4
  %exitcond.7.not.3 = icmp eq i64 %620, %indvars.iv
  br i1 %exitcond.7.not.3, label %._crit_edge, label %.preheader6

._crit_edge:                                      ; preds = %.preheader6
  %621 = add nuw nsw i64 %35, 16
  %622 = icmp samesign ult i64 %35, 48
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 16
  br i1 %622, label %.lr.ph, label %623

623:                                              ; preds = %._crit_edge
  %624 = add nuw nsw i64 %19, 8
  %625 = icmp samesign ult i64 %19, 24
  br i1 %625, label %.preheader, label %626

626:                                              ; preds = %623
  tail call void @free(ptr nonnull %18)
  tail call void @free(ptr nonnull %17)
  tail call void @free(ptr nonnull %16)
  tail call void @free(ptr nonnull %15)
  ret void
}

attributes #0 = { "uniform-work-group-size"="false" }

!llvm.module.flags = !{!0}

!0 = !{i32 2, !"Debug Info Version", i32 3}
