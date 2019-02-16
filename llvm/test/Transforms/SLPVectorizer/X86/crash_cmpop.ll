; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -basicaa -slp-vectorizer -S | FileCheck %s -check-prefixes=CHECK,SSE
; RUN: opt < %s -basicaa -slp-vectorizer -S -mattr=+avx | FileCheck %s -check-prefixes=CHECK,AVX

target datalayout = "e-m:o-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-apple-macosx10.10.0"

define void @testfunc(float* nocapture %dest, float* nocapture readonly %src) {
; SSE-LABEL: @testfunc(
; SSE-NEXT:  entry:
; SSE-NEXT:    br label [[FOR_BODY:%.*]]
; SSE:       for.body:
; SSE-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[INDVARS_IV_NEXT:%.*]], [[FOR_BODY]] ]
; SSE-NEXT:    [[ACC1_056:%.*]] = phi float [ 0.000000e+00, [[ENTRY]] ], [ [[ADD13:%.*]], [[FOR_BODY]] ]
; SSE-NEXT:    [[S1_055:%.*]] = phi float [ 0.000000e+00, [[ENTRY]] ], [ [[COND_I40:%.*]], [[FOR_BODY]] ]
; SSE-NEXT:    [[S0_054:%.*]] = phi float [ 0.000000e+00, [[ENTRY]] ], [ [[COND_I44:%.*]], [[FOR_BODY]] ]
; SSE-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds float, float* [[SRC:%.*]], i64 [[INDVARS_IV]]
; SSE-NEXT:    [[TMP0:%.*]] = load float, float* [[ARRAYIDX]], align 4
; SSE-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1
; SSE-NEXT:    [[ARRAYIDX2:%.*]] = getelementptr inbounds float, float* [[DEST:%.*]], i64 [[INDVARS_IV]]
; SSE-NEXT:    store float [[ACC1_056]], float* [[ARRAYIDX2]], align 4
; SSE-NEXT:    [[ADD:%.*]] = fadd float [[S0_054]], [[TMP0]]
; SSE-NEXT:    [[ADD3:%.*]] = fadd float [[S1_055]], [[TMP0]]
; SSE-NEXT:    [[MUL:%.*]] = fmul float [[S0_054]], 0.000000e+00
; SSE-NEXT:    [[ADD4:%.*]] = fadd float [[MUL]], [[ADD3]]
; SSE-NEXT:    [[MUL5:%.*]] = fmul float [[S1_055]], 0.000000e+00
; SSE-NEXT:    [[ADD6:%.*]] = fadd float [[MUL5]], [[ADD]]
; SSE-NEXT:    [[CMP_I:%.*]] = fcmp olt float [[ADD6]], 1.000000e+00
; SSE-NEXT:    [[COND_I:%.*]] = select i1 [[CMP_I]], float [[ADD6]], float 1.000000e+00
; SSE-NEXT:    [[CMP_I51:%.*]] = fcmp olt float [[COND_I]], -1.000000e+00
; SSE-NEXT:    [[CMP_I49:%.*]] = fcmp olt float [[ADD4]], 1.000000e+00
; SSE-NEXT:    [[COND_I50:%.*]] = select i1 [[CMP_I49]], float [[ADD4]], float 1.000000e+00
; SSE-NEXT:    [[CMP_I47:%.*]] = fcmp olt float [[COND_I50]], -1.000000e+00
; SSE-NEXT:    [[COND_I_OP:%.*]] = fmul float [[COND_I]], 0.000000e+00
; SSE-NEXT:    [[MUL10:%.*]] = select i1 [[CMP_I51]], float -0.000000e+00, float [[COND_I_OP]]
; SSE-NEXT:    [[COND_I50_OP:%.*]] = fmul float [[COND_I50]], 0.000000e+00
; SSE-NEXT:    [[MUL11:%.*]] = select i1 [[CMP_I47]], float -0.000000e+00, float [[COND_I50_OP]]
; SSE-NEXT:    [[ADD13]] = fadd float [[MUL10]], [[MUL11]]
; SSE-NEXT:    [[CMP_I45:%.*]] = fcmp olt float [[ADD13]], 1.000000e+00
; SSE-NEXT:    [[COND_I46:%.*]] = select i1 [[CMP_I45]], float [[ADD13]], float 1.000000e+00
; SSE-NEXT:    [[CMP_I43:%.*]] = fcmp olt float [[COND_I46]], -1.000000e+00
; SSE-NEXT:    [[COND_I44]] = select i1 [[CMP_I43]], float -1.000000e+00, float [[COND_I46]]
; SSE-NEXT:    [[CMP_I41:%.*]] = fcmp olt float [[MUL11]], 1.000000e+00
; SSE-NEXT:    [[COND_I42:%.*]] = select i1 [[CMP_I41]], float [[MUL11]], float 1.000000e+00
; SSE-NEXT:    [[CMP_I39:%.*]] = fcmp olt float [[COND_I42]], -1.000000e+00
; SSE-NEXT:    [[COND_I40]] = select i1 [[CMP_I39]], float -1.000000e+00, float [[COND_I42]]
; SSE-NEXT:    [[EXITCOND:%.*]] = icmp eq i64 [[INDVARS_IV_NEXT]], 32
; SSE-NEXT:    br i1 [[EXITCOND]], label [[FOR_END:%.*]], label [[FOR_BODY]]
; SSE:       for.end:
; SSE-NEXT:    ret void
;
; AVX-LABEL: @testfunc(
; AVX-NEXT:  entry:
; AVX-NEXT:    br label [[FOR_BODY:%.*]]
; AVX:       for.body:
; AVX-NEXT:    [[INDVARS_IV:%.*]] = phi i64 [ 0, [[ENTRY:%.*]] ], [ [[INDVARS_IV_NEXT:%.*]], [[FOR_BODY]] ]
; AVX-NEXT:    [[ACC1_056:%.*]] = phi float [ 0.000000e+00, [[ENTRY]] ], [ [[ADD13:%.*]], [[FOR_BODY]] ]
; AVX-NEXT:    [[TMP0:%.*]] = phi <2 x float> [ zeroinitializer, [[ENTRY]] ], [ [[TMP19:%.*]], [[FOR_BODY]] ]
; AVX-NEXT:    [[ARRAYIDX:%.*]] = getelementptr inbounds float, float* [[SRC:%.*]], i64 [[INDVARS_IV]]
; AVX-NEXT:    [[TMP1:%.*]] = load float, float* [[ARRAYIDX]], align 4
; AVX-NEXT:    [[INDVARS_IV_NEXT]] = add nuw nsw i64 [[INDVARS_IV]], 1
; AVX-NEXT:    [[ARRAYIDX2:%.*]] = getelementptr inbounds float, float* [[DEST:%.*]], i64 [[INDVARS_IV]]
; AVX-NEXT:    store float [[ACC1_056]], float* [[ARRAYIDX2]], align 4
; AVX-NEXT:    [[REORDER_SHUFFLE:%.*]] = shufflevector <2 x float> [[TMP0]], <2 x float> undef, <2 x i32> <i32 1, i32 0>
; AVX-NEXT:    [[TMP2:%.*]] = insertelement <2 x float> undef, float [[TMP1]], i32 0
; AVX-NEXT:    [[TMP3:%.*]] = insertelement <2 x float> [[TMP2]], float [[TMP1]], i32 1
; AVX-NEXT:    [[TMP4:%.*]] = fadd <2 x float> [[REORDER_SHUFFLE]], [[TMP3]]
; AVX-NEXT:    [[TMP5:%.*]] = fmul <2 x float> zeroinitializer, [[TMP0]]
; AVX-NEXT:    [[TMP6:%.*]] = fadd <2 x float> [[TMP5]], [[TMP4]]
; AVX-NEXT:    [[TMP7:%.*]] = fcmp olt <2 x float> [[TMP6]], <float 1.000000e+00, float 1.000000e+00>
; AVX-NEXT:    [[TMP8:%.*]] = select <2 x i1> [[TMP7]], <2 x float> [[TMP6]], <2 x float> <float 1.000000e+00, float 1.000000e+00>
; AVX-NEXT:    [[TMP9:%.*]] = fcmp olt <2 x float> [[TMP8]], <float -1.000000e+00, float -1.000000e+00>
; AVX-NEXT:    [[TMP10:%.*]] = fmul <2 x float> zeroinitializer, [[TMP8]]
; AVX-NEXT:    [[TMP11:%.*]] = select <2 x i1> [[TMP9]], <2 x float> <float -0.000000e+00, float -0.000000e+00>, <2 x float> [[TMP10]]
; AVX-NEXT:    [[TMP12:%.*]] = extractelement <2 x float> [[TMP11]], i32 0
; AVX-NEXT:    [[TMP13:%.*]] = extractelement <2 x float> [[TMP11]], i32 1
; AVX-NEXT:    [[ADD13]] = fadd float [[TMP12]], [[TMP13]]
; AVX-NEXT:    [[TMP14:%.*]] = insertelement <2 x float> undef, float [[TMP13]], i32 0
; AVX-NEXT:    [[TMP15:%.*]] = insertelement <2 x float> [[TMP14]], float [[ADD13]], i32 1
; AVX-NEXT:    [[TMP16:%.*]] = fcmp olt <2 x float> [[TMP15]], <float 1.000000e+00, float 1.000000e+00>
; AVX-NEXT:    [[TMP17:%.*]] = select <2 x i1> [[TMP16]], <2 x float> [[TMP15]], <2 x float> <float 1.000000e+00, float 1.000000e+00>
; AVX-NEXT:    [[TMP18:%.*]] = fcmp olt <2 x float> [[TMP17]], <float -1.000000e+00, float -1.000000e+00>
; AVX-NEXT:    [[TMP19]] = select <2 x i1> [[TMP18]], <2 x float> <float -1.000000e+00, float -1.000000e+00>, <2 x float> [[TMP17]]
; AVX-NEXT:    [[EXITCOND:%.*]] = icmp eq i64 [[INDVARS_IV_NEXT]], 32
; AVX-NEXT:    br i1 [[EXITCOND]], label [[FOR_END:%.*]], label [[FOR_BODY]]
; AVX:       for.end:
; AVX-NEXT:    ret void
;
entry:
  br label %for.body

for.body:
  %indvars.iv = phi i64 [ 0, %entry ], [ %indvars.iv.next, %for.body ]
  %acc1.056 = phi float [ 0.000000e+00, %entry ], [ %add13, %for.body ]
  %s1.055 = phi float [ 0.000000e+00, %entry ], [ %cond.i40, %for.body ]
  %s0.054 = phi float [ 0.000000e+00, %entry ], [ %cond.i44, %for.body ]
  %arrayidx = getelementptr inbounds float, float* %src, i64 %indvars.iv
  %0 = load float, float* %arrayidx, align 4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  %arrayidx2 = getelementptr inbounds float, float* %dest, i64 %indvars.iv
  store float %acc1.056, float* %arrayidx2, align 4
  %add = fadd float %s0.054, %0
  %add3 = fadd float %s1.055, %0
  %mul = fmul float %s0.054, 0.000000e+00
  %add4 = fadd float %mul, %add3
  %mul5 = fmul float %s1.055, 0.000000e+00
  %add6 = fadd float %mul5, %add
  %cmp.i = fcmp olt float %add6, 1.000000e+00
  %cond.i = select i1 %cmp.i, float %add6, float 1.000000e+00
  %cmp.i51 = fcmp olt float %cond.i, -1.000000e+00
  %cmp.i49 = fcmp olt float %add4, 1.000000e+00
  %cond.i50 = select i1 %cmp.i49, float %add4, float 1.000000e+00
  %cmp.i47 = fcmp olt float %cond.i50, -1.000000e+00
  %cond.i.op = fmul float %cond.i, 0.000000e+00
  %mul10 = select i1 %cmp.i51, float -0.000000e+00, float %cond.i.op
  %cond.i50.op = fmul float %cond.i50, 0.000000e+00
  %mul11 = select i1 %cmp.i47, float -0.000000e+00, float %cond.i50.op
  %add13 = fadd float %mul10, %mul11

  ; The SLPVectorizer crashed in vectorizeChainsInBlock() because it tried
  ; to access the second operand of the following cmp after the cmp itself
  ; was already vectorized and deleted.
  %cmp.i45 = fcmp olt float %add13, 1.000000e+00

  %cond.i46 = select i1 %cmp.i45, float %add13, float 1.000000e+00
  %cmp.i43 = fcmp olt float %cond.i46, -1.000000e+00
  %cond.i44 = select i1 %cmp.i43, float -1.000000e+00, float %cond.i46
  %cmp.i41 = fcmp olt float %mul11, 1.000000e+00
  %cond.i42 = select i1 %cmp.i41, float %mul11, float 1.000000e+00
  %cmp.i39 = fcmp olt float %cond.i42, -1.000000e+00
  %cond.i40 = select i1 %cmp.i39, float -1.000000e+00, float %cond.i42
  %exitcond = icmp eq i64 %indvars.iv.next, 32
  br i1 %exitcond, label %for.end, label %for.body

for.end:
  ret void
}

