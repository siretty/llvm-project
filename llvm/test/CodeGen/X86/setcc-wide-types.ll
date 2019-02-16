; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=sse2     | FileCheck %s --check-prefix=ANY --check-prefix=SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=avx      | FileCheck %s --check-prefix=ANY --check-prefix=AVXANY --check-prefix=AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=avx2     | FileCheck %s --check-prefix=ANY --check-prefix=AVXANY --check-prefix=AVX256 --check-prefix=AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=avx512f  | FileCheck %s --check-prefix=ANY --check-prefix=AVXANY --check-prefix=AVX256 --check-prefix=AVX512F
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=avx512bw | FileCheck %s --check-prefix=ANY --check-prefix=AVXANY --check-prefix=AVX256 --check-prefix=AVX512BW

; Equality checks of 128/256-bit values can use PMOVMSK or PTEST to avoid scalarization.

define i32 @ne_i128(<2 x i64> %x, <2 x i64> %y) {
; SSE2-LABEL: ne_i128:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pcmpeqb %xmm1, %xmm0
; SSE2-NEXT:    pmovmskb %xmm0, %ecx
; SSE2-NEXT:    xorl %eax, %eax
; SSE2-NEXT:    cmpl $65535, %ecx # imm = 0xFFFF
; SSE2-NEXT:    setne %al
; SSE2-NEXT:    retq
;
; AVXANY-LABEL: ne_i128:
; AVXANY:       # %bb.0:
; AVXANY-NEXT:    vpcmpeqb %xmm1, %xmm0, %xmm0
; AVXANY-NEXT:    vpmovmskb %xmm0, %ecx
; AVXANY-NEXT:    xorl %eax, %eax
; AVXANY-NEXT:    cmpl $65535, %ecx # imm = 0xFFFF
; AVXANY-NEXT:    setne %al
; AVXANY-NEXT:    retq
  %bcx = bitcast <2 x i64> %x to i128
  %bcy = bitcast <2 x i64> %y to i128
  %cmp = icmp ne i128 %bcx, %bcy
  %zext = zext i1 %cmp to i32
  ret i32 %zext
}

define i32 @eq_i128(<2 x i64> %x, <2 x i64> %y) {
; SSE2-LABEL: eq_i128:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pcmpeqb %xmm1, %xmm0
; SSE2-NEXT:    pmovmskb %xmm0, %ecx
; SSE2-NEXT:    xorl %eax, %eax
; SSE2-NEXT:    cmpl $65535, %ecx # imm = 0xFFFF
; SSE2-NEXT:    sete %al
; SSE2-NEXT:    retq
;
; AVXANY-LABEL: eq_i128:
; AVXANY:       # %bb.0:
; AVXANY-NEXT:    vpcmpeqb %xmm1, %xmm0, %xmm0
; AVXANY-NEXT:    vpmovmskb %xmm0, %ecx
; AVXANY-NEXT:    xorl %eax, %eax
; AVXANY-NEXT:    cmpl $65535, %ecx # imm = 0xFFFF
; AVXANY-NEXT:    sete %al
; AVXANY-NEXT:    retq
  %bcx = bitcast <2 x i64> %x to i128
  %bcy = bitcast <2 x i64> %y to i128
  %cmp = icmp eq i128 %bcx, %bcy
  %zext = zext i1 %cmp to i32
  ret i32 %zext
}

define i32 @ne_i256(<4 x i64> %x, <4 x i64> %y) {
; SSE2-LABEL: ne_i256:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm0[2,3,0,1]
; SSE2-NEXT:    movq %xmm4, %rax
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm1[2,3,0,1]
; SSE2-NEXT:    movq %xmm4, %rcx
; SSE2-NEXT:    movq %xmm0, %rdx
; SSE2-NEXT:    movq %xmm1, %r8
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm2[2,3,0,1]
; SSE2-NEXT:    movq %xmm0, %rdi
; SSE2-NEXT:    xorq %rax, %rdi
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm3[2,3,0,1]
; SSE2-NEXT:    movq %xmm0, %rsi
; SSE2-NEXT:    xorq %rcx, %rsi
; SSE2-NEXT:    orq %rdi, %rsi
; SSE2-NEXT:    movq %xmm2, %rax
; SSE2-NEXT:    xorq %rdx, %rax
; SSE2-NEXT:    movq %xmm3, %rcx
; SSE2-NEXT:    xorq %r8, %rcx
; SSE2-NEXT:    orq %rax, %rcx
; SSE2-NEXT:    xorl %eax, %eax
; SSE2-NEXT:    orq %rsi, %rcx
; SSE2-NEXT:    setne %al
; SSE2-NEXT:    retq
;
; AVX1-LABEL: ne_i256:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovq %xmm0, %rax
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vmovq %xmm2, %rcx
; AVX1-NEXT:    vpextrq $1, %xmm0, %rdx
; AVX1-NEXT:    vpextrq $1, %xmm2, %r8
; AVX1-NEXT:    vmovq %xmm1, %rdi
; AVX1-NEXT:    xorq %rax, %rdi
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm0
; AVX1-NEXT:    vmovq %xmm0, %rsi
; AVX1-NEXT:    xorq %rcx, %rsi
; AVX1-NEXT:    orq %rdi, %rsi
; AVX1-NEXT:    vpextrq $1, %xmm1, %rax
; AVX1-NEXT:    xorq %rdx, %rax
; AVX1-NEXT:    vpextrq $1, %xmm0, %rcx
; AVX1-NEXT:    xorq %r8, %rcx
; AVX1-NEXT:    orq %rax, %rcx
; AVX1-NEXT:    xorl %eax, %eax
; AVX1-NEXT:    orq %rsi, %rcx
; AVX1-NEXT:    setne %al
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX256-LABEL: ne_i256:
; AVX256:       # %bb.0:
; AVX256-NEXT:    vpcmpeqb %ymm1, %ymm0, %ymm0
; AVX256-NEXT:    vpmovmskb %ymm0, %ecx
; AVX256-NEXT:    xorl %eax, %eax
; AVX256-NEXT:    cmpl $-1, %ecx
; AVX256-NEXT:    setne %al
; AVX256-NEXT:    vzeroupper
; AVX256-NEXT:    retq
  %bcx = bitcast <4 x i64> %x to i256
  %bcy = bitcast <4 x i64> %y to i256
  %cmp = icmp ne i256 %bcx, %bcy
  %zext = zext i1 %cmp to i32
  ret i32 %zext
}

define i32 @eq_i256(<4 x i64> %x, <4 x i64> %y) {
; SSE2-LABEL: eq_i256:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm0[2,3,0,1]
; SSE2-NEXT:    movq %xmm4, %rax
; SSE2-NEXT:    pshufd {{.*#+}} xmm4 = xmm1[2,3,0,1]
; SSE2-NEXT:    movq %xmm4, %rcx
; SSE2-NEXT:    movq %xmm0, %rdx
; SSE2-NEXT:    movq %xmm1, %r8
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm2[2,3,0,1]
; SSE2-NEXT:    movq %xmm0, %rdi
; SSE2-NEXT:    xorq %rax, %rdi
; SSE2-NEXT:    pshufd {{.*#+}} xmm0 = xmm3[2,3,0,1]
; SSE2-NEXT:    movq %xmm0, %rsi
; SSE2-NEXT:    xorq %rcx, %rsi
; SSE2-NEXT:    orq %rdi, %rsi
; SSE2-NEXT:    movq %xmm2, %rax
; SSE2-NEXT:    xorq %rdx, %rax
; SSE2-NEXT:    movq %xmm3, %rcx
; SSE2-NEXT:    xorq %r8, %rcx
; SSE2-NEXT:    orq %rax, %rcx
; SSE2-NEXT:    xorl %eax, %eax
; SSE2-NEXT:    orq %rsi, %rcx
; SSE2-NEXT:    sete %al
; SSE2-NEXT:    retq
;
; AVX1-LABEL: eq_i256:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovq %xmm0, %rax
; AVX1-NEXT:    vextractf128 $1, %ymm0, %xmm2
; AVX1-NEXT:    vmovq %xmm2, %rcx
; AVX1-NEXT:    vpextrq $1, %xmm0, %rdx
; AVX1-NEXT:    vpextrq $1, %xmm2, %r8
; AVX1-NEXT:    vmovq %xmm1, %rdi
; AVX1-NEXT:    xorq %rax, %rdi
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm0
; AVX1-NEXT:    vmovq %xmm0, %rsi
; AVX1-NEXT:    xorq %rcx, %rsi
; AVX1-NEXT:    orq %rdi, %rsi
; AVX1-NEXT:    vpextrq $1, %xmm1, %rax
; AVX1-NEXT:    xorq %rdx, %rax
; AVX1-NEXT:    vpextrq $1, %xmm0, %rcx
; AVX1-NEXT:    xorq %r8, %rcx
; AVX1-NEXT:    orq %rax, %rcx
; AVX1-NEXT:    xorl %eax, %eax
; AVX1-NEXT:    orq %rsi, %rcx
; AVX1-NEXT:    sete %al
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX256-LABEL: eq_i256:
; AVX256:       # %bb.0:
; AVX256-NEXT:    vpcmpeqb %ymm1, %ymm0, %ymm0
; AVX256-NEXT:    vpmovmskb %ymm0, %ecx
; AVX256-NEXT:    xorl %eax, %eax
; AVX256-NEXT:    cmpl $-1, %ecx
; AVX256-NEXT:    sete %al
; AVX256-NEXT:    vzeroupper
; AVX256-NEXT:    retq
  %bcx = bitcast <4 x i64> %x to i256
  %bcy = bitcast <4 x i64> %y to i256
  %cmp = icmp eq i256 %bcx, %bcy
  %zext = zext i1 %cmp to i32
  ret i32 %zext
}

; This test models the expansion of 'memcmp(a, b, 32) != 0'
; if we allowed 2 pairs of 16-byte loads per block.

define i32 @ne_i128_pair(i128* %a, i128* %b) {
; ANY-LABEL: ne_i128_pair:
; ANY:       # %bb.0:
; ANY-NEXT:    movq (%rdi), %rax
; ANY-NEXT:    movq 8(%rdi), %rcx
; ANY-NEXT:    xorq (%rsi), %rax
; ANY-NEXT:    xorq 8(%rsi), %rcx
; ANY-NEXT:    movq 24(%rdi), %rdx
; ANY-NEXT:    movq 16(%rdi), %rdi
; ANY-NEXT:    xorq 16(%rsi), %rdi
; ANY-NEXT:    orq %rax, %rdi
; ANY-NEXT:    xorq 24(%rsi), %rdx
; ANY-NEXT:    orq %rcx, %rdx
; ANY-NEXT:    xorl %eax, %eax
; ANY-NEXT:    orq %rdi, %rdx
; ANY-NEXT:    setne %al
; ANY-NEXT:    retq
  %a0 = load i128, i128* %a
  %b0 = load i128, i128* %b
  %xor1 = xor i128 %a0, %b0
  %ap1 = getelementptr i128, i128* %a, i128 1
  %bp1 = getelementptr i128, i128* %b, i128 1
  %a1 = load i128, i128* %ap1
  %b1 = load i128, i128* %bp1
  %xor2 = xor i128 %a1, %b1
  %or = or i128 %xor1, %xor2
  %cmp = icmp ne i128 %or, 0
  %z = zext i1 %cmp to i32
  ret i32 %z
}

; This test models the expansion of 'memcmp(a, b, 32) == 0'
; if we allowed 2 pairs of 16-byte loads per block.

define i32 @eq_i128_pair(i128* %a, i128* %b) {
; ANY-LABEL: eq_i128_pair:
; ANY:       # %bb.0:
; ANY-NEXT:    movq (%rdi), %rax
; ANY-NEXT:    movq 8(%rdi), %rcx
; ANY-NEXT:    xorq (%rsi), %rax
; ANY-NEXT:    xorq 8(%rsi), %rcx
; ANY-NEXT:    movq 24(%rdi), %rdx
; ANY-NEXT:    movq 16(%rdi), %rdi
; ANY-NEXT:    xorq 16(%rsi), %rdi
; ANY-NEXT:    orq %rax, %rdi
; ANY-NEXT:    xorq 24(%rsi), %rdx
; ANY-NEXT:    orq %rcx, %rdx
; ANY-NEXT:    xorl %eax, %eax
; ANY-NEXT:    orq %rdi, %rdx
; ANY-NEXT:    sete %al
; ANY-NEXT:    retq
  %a0 = load i128, i128* %a
  %b0 = load i128, i128* %b
  %xor1 = xor i128 %a0, %b0
  %ap1 = getelementptr i128, i128* %a, i128 1
  %bp1 = getelementptr i128, i128* %b, i128 1
  %a1 = load i128, i128* %ap1
  %b1 = load i128, i128* %bp1
  %xor2 = xor i128 %a1, %b1
  %or = or i128 %xor1, %xor2
  %cmp = icmp eq i128 %or, 0
  %z = zext i1 %cmp to i32
  ret i32 %z
}

; This test models the expansion of 'memcmp(a, b, 64) != 0'
; if we allowed 2 pairs of 32-byte loads per block.

define i32 @ne_i256_pair(i256* %a, i256* %b) {
; ANY-LABEL: ne_i256_pair:
; ANY:       # %bb.0:
; ANY-NEXT:    movq 16(%rdi), %r9
; ANY-NEXT:    movq 24(%rdi), %r11
; ANY-NEXT:    movq (%rdi), %r8
; ANY-NEXT:    movq 8(%rdi), %r10
; ANY-NEXT:    xorq 8(%rsi), %r10
; ANY-NEXT:    xorq 24(%rsi), %r11
; ANY-NEXT:    xorq (%rsi), %r8
; ANY-NEXT:    xorq 16(%rsi), %r9
; ANY-NEXT:    movq 48(%rdi), %rdx
; ANY-NEXT:    movq 32(%rdi), %rax
; ANY-NEXT:    movq 56(%rdi), %rcx
; ANY-NEXT:    movq 40(%rdi), %rdi
; ANY-NEXT:    xorq 40(%rsi), %rdi
; ANY-NEXT:    xorq 56(%rsi), %rcx
; ANY-NEXT:    orq %r11, %rcx
; ANY-NEXT:    orq %rdi, %rcx
; ANY-NEXT:    orq %r10, %rcx
; ANY-NEXT:    xorq 32(%rsi), %rax
; ANY-NEXT:    xorq 48(%rsi), %rdx
; ANY-NEXT:    orq %r9, %rdx
; ANY-NEXT:    orq %rax, %rdx
; ANY-NEXT:    orq %r8, %rdx
; ANY-NEXT:    xorl %eax, %eax
; ANY-NEXT:    orq %rcx, %rdx
; ANY-NEXT:    setne %al
; ANY-NEXT:    retq
  %a0 = load i256, i256* %a
  %b0 = load i256, i256* %b
  %xor1 = xor i256 %a0, %b0
  %ap1 = getelementptr i256, i256* %a, i256 1
  %bp1 = getelementptr i256, i256* %b, i256 1
  %a1 = load i256, i256* %ap1
  %b1 = load i256, i256* %bp1
  %xor2 = xor i256 %a1, %b1
  %or = or i256 %xor1, %xor2
  %cmp = icmp ne i256 %or, 0
  %z = zext i1 %cmp to i32
  ret i32 %z
}

; This test models the expansion of 'memcmp(a, b, 64) == 0'
; if we allowed 2 pairs of 32-byte loads per block.

define i32 @eq_i256_pair(i256* %a, i256* %b) {
; ANY-LABEL: eq_i256_pair:
; ANY:       # %bb.0:
; ANY-NEXT:    movq 16(%rdi), %r9
; ANY-NEXT:    movq 24(%rdi), %r11
; ANY-NEXT:    movq (%rdi), %r8
; ANY-NEXT:    movq 8(%rdi), %r10
; ANY-NEXT:    xorq 8(%rsi), %r10
; ANY-NEXT:    xorq 24(%rsi), %r11
; ANY-NEXT:    xorq (%rsi), %r8
; ANY-NEXT:    xorq 16(%rsi), %r9
; ANY-NEXT:    movq 48(%rdi), %rdx
; ANY-NEXT:    movq 32(%rdi), %rax
; ANY-NEXT:    movq 56(%rdi), %rcx
; ANY-NEXT:    movq 40(%rdi), %rdi
; ANY-NEXT:    xorq 40(%rsi), %rdi
; ANY-NEXT:    xorq 56(%rsi), %rcx
; ANY-NEXT:    orq %r11, %rcx
; ANY-NEXT:    orq %rdi, %rcx
; ANY-NEXT:    orq %r10, %rcx
; ANY-NEXT:    xorq 32(%rsi), %rax
; ANY-NEXT:    xorq 48(%rsi), %rdx
; ANY-NEXT:    orq %r9, %rdx
; ANY-NEXT:    orq %rax, %rdx
; ANY-NEXT:    orq %r8, %rdx
; ANY-NEXT:    xorl %eax, %eax
; ANY-NEXT:    orq %rcx, %rdx
; ANY-NEXT:    sete %al
; ANY-NEXT:    retq
  %a0 = load i256, i256* %a
  %b0 = load i256, i256* %b
  %xor1 = xor i256 %a0, %b0
  %ap1 = getelementptr i256, i256* %a, i256 1
  %bp1 = getelementptr i256, i256* %b, i256 1
  %a1 = load i256, i256* %ap1
  %b1 = load i256, i256* %bp1
  %xor2 = xor i256 %a1, %b1
  %or = or i256 %xor1, %xor2
  %cmp = icmp eq i256 %or, 0
  %z = zext i1 %cmp to i32
  ret i32 %z
}

