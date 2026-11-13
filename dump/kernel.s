	.amdgcn_target "amdgcn-amd-amdhsa--gfx1100"
	.amdhsa_code_object_version 6
	.text
	.globl	kernel
	.p2align	2
	.type	kernel,@function
kernel:
	s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
	s_mov_b32 s0, s33
	s_mov_b32 s33, s32
	s_or_saveexec_b32 s1, -1
	scratch_store_b32 off, v59, s33 offset:44
	s_mov_b32 exec_lo, s1
	v_writelane_b32 v59, s0, 16
	s_add_i32 s32, s32, 64
	s_getpc_b64 s[0:1]
	s_add_u32 s0, s0, malloc@gotpcrel32@lo+4
	s_addc_u32 s1, s1, malloc@gotpcrel32@hi+12
	s_clause 0xa
	scratch_store_b32 off, v40, s33 offset:40
	scratch_store_b32 off, v41, s33 offset:36
	scratch_store_b32 off, v42, s33 offset:32
	scratch_store_b32 off, v43, s33 offset:28
	scratch_store_b32 off, v44, s33 offset:24
	scratch_store_b32 off, v45, s33 offset:20
	scratch_store_b32 off, v46, s33 offset:16
	scratch_store_b32 off, v47, s33 offset:12
	scratch_store_b32 off, v56, s33 offset:8
	scratch_store_b32 off, v57, s33 offset:4
	scratch_store_b32 off, v58, s33
	v_dual_mov_b32 v44, v2 :: v_dual_mov_b32 v1, 0
	v_writelane_b32 v59, s30, 0
	v_mov_b32_e32 v0, 0x2000
	v_dual_mov_b32 v58, v31 :: v_dual_mov_b32 v43, v17
	v_dual_mov_b32 v42, v16 :: v_dual_mov_b32 v45, v3
	v_writelane_b32 v59, s31, 1
	v_writelane_b32 v59, s34, 2
	v_writelane_b32 v59, s35, 3
	s_mov_b64 s[34:35], s[10:11]
	v_writelane_b32 v59, s36, 4
	v_writelane_b32 v59, s37, 5
	s_mov_b64 s[36:37], s[8:9]
	v_writelane_b32 v59, s38, 6
	v_writelane_b32 v59, s39, 7
	s_mov_b64 s[38:39], s[6:7]
	v_writelane_b32 v59, s48, 8
	v_writelane_b32 v59, s49, 9
	s_mov_b64 s[48:49], s[4:5]
	v_writelane_b32 v59, s50, 10
	s_mov_b32 s50, s15
	v_writelane_b32 v59, s51, 11
	s_mov_b32 s51, s14
	v_writelane_b32 v59, s52, 12
	s_mov_b32 s52, s13
	v_writelane_b32 v59, s53, 13
	s_mov_b32 s53, s12
	v_writelane_b32 v59, s54, 14
	v_writelane_b32 v59, s55, 15
	s_load_b64 s[54:55], s[0:1], 0x0
	s_waitcnt lgkmcnt(0)
	s_swappc_b64 s[30:31], s[54:55]
	v_dual_mov_b32 v40, v0 :: v_dual_mov_b32 v41, v1
	v_dual_mov_b32 v31, v58 :: v_dual_mov_b32 v0, 0x2000
	v_mov_b32_e32 v1, 0
	s_mov_b64 s[4:5], s[48:49]
	s_mov_b64 s[6:7], s[38:39]
	s_mov_b64 s[8:9], s[36:37]
	s_mov_b64 s[10:11], s[34:35]
	s_mov_b32 s12, s53
	s_mov_b32 s13, s52
	s_mov_b32 s14, s51
	s_mov_b32 s15, s50
	s_swappc_b64 s[30:31], s[54:55]
	v_dual_mov_b32 v46, v0 :: v_dual_mov_b32 v47, v1
	v_dual_mov_b32 v31, v58 :: v_dual_mov_b32 v0, 0x2000
	v_mov_b32_e32 v1, 0
	s_mov_b64 s[4:5], s[48:49]
	s_mov_b64 s[6:7], s[38:39]
	s_mov_b64 s[8:9], s[36:37]
	s_mov_b64 s[10:11], s[34:35]
	s_mov_b32 s12, s53
	s_mov_b32 s13, s52
	s_mov_b32 s14, s51
	s_mov_b32 s15, s50
	s_swappc_b64 s[30:31], s[54:55]
	v_dual_mov_b32 v56, v0 :: v_dual_mov_b32 v57, v1
	v_dual_mov_b32 v31, v58 :: v_dual_mov_b32 v0, 0x2000
	v_mov_b32_e32 v1, 0
	s_mov_b64 s[4:5], s[48:49]
	s_mov_b64 s[6:7], s[38:39]
	s_mov_b64 s[8:9], s[36:37]
	s_mov_b64 s[10:11], s[34:35]
	s_mov_b32 s12, s53
	s_mov_b32 s13, s52
	s_mov_b32 s14, s51
	s_mov_b32 s15, s50
	s_swappc_b64 s[30:31], s[54:55]
	v_dual_mov_b32 v2, v40 :: v_dual_mov_b32 v3, v41
	v_dual_mov_b32 v4, v46 :: v_dual_mov_b32 v5, v47
	v_dual_mov_b32 v6, v56 :: v_dual_mov_b32 v7, v57
	v_dual_mov_b32 v9, v1 :: v_dual_mov_b32 v8, v0
	s_mov_b64 s[2:3], 0
	s_branch .LBB0_3
.LBB0_1:
	v_add_co_u32 v42, vcc_lo, 0x800, v42
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_add_co_ci_u32_e64 v43, null, 0, v43, vcc_lo
	v_add_co_u32 v8, vcc_lo, 0x800, v8
	v_add_co_ci_u32_e64 v9, null, 0, v9, vcc_lo
	v_add_co_u32 v6, vcc_lo, 0x800, v6
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_add_co_ci_u32_e64 v7, null, 0, v7, vcc_lo
	v_add_co_u32 v4, vcc_lo, 0x800, v4
	v_add_co_ci_u32_e64 v5, null, 0, v5, vcc_lo
	v_add_co_u32 v2, vcc_lo, 0x800, v2
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_add_co_ci_u32_e64 v3, null, 0, v3, vcc_lo
	v_add_co_u32 v44, vcc_lo, 0x800, v44
	v_add_co_ci_u32_e64 v45, null, 0, v45, vcc_lo
	s_mov_b32 s4, 0
.LBB0_2:
	s_delay_alu instid0(SALU_CYCLE_1)
	s_and_b32 vcc_lo, exec_lo, s4
	s_mov_b64 s[2:3], s[0:1]
	s_cbranch_vccnz .LBB0_15
.LBB0_3:
	v_cmp_gt_i64_e64 s0, s[2:3], 31
	s_mov_b32 s4, -1
	s_and_b32 vcc_lo, exec_lo, s0
	s_cbranch_vccnz .LBB0_2
	v_dual_mov_b32 v10, v44 :: v_dual_mov_b32 v11, v45
	v_dual_mov_b32 v13, v3 :: v_dual_mov_b32 v12, v2
	v_dual_mov_b32 v15, v5 :: v_dual_mov_b32 v14, v4
	v_dual_mov_b32 v17, v7 :: v_dual_mov_b32 v16, v6
	v_dual_mov_b32 v19, v9 :: v_dual_mov_b32 v18, v8
	v_dual_mov_b32 v20, v42 :: v_dual_mov_b32 v21, v43
	s_add_u32 s0, s2, 8
	s_addc_u32 s1, s3, 0
	s_mov_b64 s[6:7], 0
	s_branch .LBB0_7
.LBB0_5:
	v_add_co_u32 v20, vcc_lo, v20, 64
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_add_co_ci_u32_e64 v21, null, 0, v21, vcc_lo
	v_add_co_u32 v18, vcc_lo, v18, 64
	v_add_co_ci_u32_e64 v19, null, 0, v19, vcc_lo
	v_add_co_u32 v16, vcc_lo, v16, 64
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_add_co_ci_u32_e64 v17, null, 0, v17, vcc_lo
	v_add_co_u32 v14, vcc_lo, v14, 64
	v_add_co_ci_u32_e64 v15, null, 0, v15, vcc_lo
	v_add_co_u32 v12, vcc_lo, v12, 64
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_add_co_ci_u32_e64 v13, null, 0, v13, vcc_lo
	v_add_co_u32 v10, vcc_lo, v10, 64
	v_add_co_ci_u32_e64 v11, null, 0, v11, vcc_lo
	s_mov_b32 s8, 0
.LBB0_6:
	s_delay_alu instid0(SALU_CYCLE_1)
	s_and_b32 vcc_lo, exec_lo, s8
	s_mov_b64 s[6:7], s[4:5]
	s_cbranch_vccnz .LBB0_1
.LBB0_7:
	v_cmp_gt_i64_e64 s4, s[6:7], 63
	s_mov_b32 s8, -1
	s_and_b32 vcc_lo, exec_lo, s4
	s_cbranch_vccnz .LBB0_6
	v_dual_mov_b32 v23, v11 :: v_dual_mov_b32 v22, v10
	v_dual_mov_b32 v25, v13 :: v_dual_mov_b32 v24, v12
	v_dual_mov_b32 v27, v15 :: v_dual_mov_b32 v26, v14
	v_dual_mov_b32 v29, v17 :: v_dual_mov_b32 v28, v16
	v_dual_mov_b32 v31, v19 :: v_dual_mov_b32 v30, v18
	v_dual_mov_b32 v33, v21 :: v_dual_mov_b32 v32, v20
	s_add_u32 s4, s6, 16
	s_addc_u32 s5, s7, 0
	s_mov_b64 s[8:9], s[2:3]
	s_branch .LBB0_11
.LBB0_9:
	v_add_co_u32 v32, vcc_lo, 0x100, v32
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_add_co_ci_u32_e64 v33, null, 0, v33, vcc_lo
	v_add_co_u32 v30, vcc_lo, 0x100, v30
	v_add_co_ci_u32_e64 v31, null, 0, v31, vcc_lo
	v_add_co_u32 v28, vcc_lo, 0x100, v28
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_add_co_ci_u32_e64 v29, null, 0, v29, vcc_lo
	v_add_co_u32 v26, vcc_lo, 0x100, v26
	v_add_co_ci_u32_e64 v27, null, 0, v27, vcc_lo
	v_add_co_u32 v24, vcc_lo, 0x100, v24
	s_delay_alu instid0(VALU_DEP_1)
	v_add_co_ci_u32_e64 v25, null, 0, v25, vcc_lo
	v_add_co_u32 v22, vcc_lo, 0x100, v22
	s_add_u32 s8, s8, 1
	v_add_co_ci_u32_e64 v23, null, 0, v23, vcc_lo
	s_addc_u32 s9, s9, 0
	s_mov_b32 s12, 0
.LBB0_10:
	s_delay_alu instid0(SALU_CYCLE_1)
	s_and_b32 vcc_lo, exec_lo, s12
	s_cbranch_vccnz .LBB0_5
.LBB0_11:
	v_cmp_ge_i64_e64 s10, s[8:9], s[0:1]
	v_dual_mov_b32 v35, v23 :: v_dual_mov_b32 v34, v22
	v_dual_mov_b32 v37, v25 :: v_dual_mov_b32 v36, v24
	v_dual_mov_b32 v39, v27 :: v_dual_mov_b32 v38, v26
	v_dual_mov_b32 v49, v29 :: v_dual_mov_b32 v48, v28
	v_dual_mov_b32 v51, v31 :: v_dual_mov_b32 v50, v30
	v_dual_mov_b32 v53, v33 :: v_dual_mov_b32 v52, v32
	s_mov_b32 s12, -1
	s_and_b32 vcc_lo, exec_lo, s10
	s_mov_b64 s[10:11], s[6:7]
	s_cbranch_vccz .LBB0_13
	s_branch .LBB0_10
.LBB0_12:
	s_and_not1_b32 vcc_lo, exec_lo, s12
	s_cbranch_vccz .LBB0_9
.LBB0_13:
	v_cmp_ge_i64_e64 s12, s[10:11], s[4:5]
	s_and_b32 vcc_lo, exec_lo, s12
	s_mov_b32 s12, -1
	s_cbranch_vccnz .LBB0_12
	flat_load_b32 v54, v[34:35]
	flat_load_b32 v55, v[52:53]
	v_add_co_u32 v52, vcc_lo, v52, 4
	s_delay_alu instid0(VALU_DEP_1)
	v_add_co_ci_u32_e64 v53, null, 0, v53, vcc_lo
	s_add_u32 s10, s10, 1
	s_addc_u32 s11, s11, 0
	s_mov_b32 s12, 0
	s_waitcnt vmcnt(0) lgkmcnt(0)
	v_add_f32_e32 v54, v54, v55
	flat_store_b32 v[50:51], v54
	flat_load_b32 v55, v[34:35]
	s_waitcnt vmcnt(0) lgkmcnt(0)
	v_add_f32_e32 v54, v55, v54
	flat_store_b32 v[48:49], v54
	flat_load_b32 v54, v[50:51]
	flat_load_b32 v55, v[34:35]
	v_add_co_u32 v50, vcc_lo, v50, 4
	s_delay_alu instid0(VALU_DEP_1)
	v_add_co_ci_u32_e64 v51, null, 0, v51, vcc_lo
	s_waitcnt vmcnt(0) lgkmcnt(0)
	v_mul_f32_e32 v54, v54, v55
	flat_store_b32 v[38:39], v54
	flat_load_b32 v55, v[48:49]
	v_add_co_u32 v38, vcc_lo, v38, 4
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_add_co_ci_u32_e64 v39, null, 0, v39, vcc_lo
	v_add_co_u32 v48, vcc_lo, v48, 4
	v_add_co_ci_u32_e64 v49, null, 0, v49, vcc_lo
	s_waitcnt vmcnt(0) lgkmcnt(0)
	v_mul_f32_e32 v54, v55, v54
	flat_store_b32 v[36:37], v54
	v_add_co_u32 v36, vcc_lo, v36, 4
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_add_co_ci_u32_e64 v37, null, 0, v37, vcc_lo
	v_add_co_u32 v34, vcc_lo, v34, 4
	v_add_co_ci_u32_e64 v35, null, 0, v35, vcc_lo
	s_branch .LBB0_12
.LBB0_15:
	s_getpc_b64 s[0:1]
	s_add_u32 s0, s0, free@gotpcrel32@lo+4
	s_addc_u32 s1, s1, free@gotpcrel32@hi+12
	v_mov_b32_e32 v31, v58
	s_load_b64 s[54:55], s[0:1], 0x0
	s_mov_b64 s[4:5], s[48:49]
	s_mov_b64 s[6:7], s[38:39]
	s_mov_b64 s[8:9], s[36:37]
	s_mov_b64 s[10:11], s[34:35]
	s_mov_b32 s12, s53
	s_mov_b32 s13, s52
	s_mov_b32 s14, s51
	s_mov_b32 s15, s50
	s_waitcnt lgkmcnt(0)
	s_swappc_b64 s[30:31], s[54:55]
	v_dual_mov_b32 v31, v58 :: v_dual_mov_b32 v0, v56
	v_mov_b32_e32 v1, v57
	s_mov_b64 s[4:5], s[48:49]
	s_mov_b64 s[6:7], s[38:39]
	s_mov_b64 s[8:9], s[36:37]
	s_mov_b64 s[10:11], s[34:35]
	s_mov_b32 s12, s53
	s_mov_b32 s13, s52
	s_mov_b32 s14, s51
	s_mov_b32 s15, s50
	s_swappc_b64 s[30:31], s[54:55]
	v_mov_b32_e32 v31, v58
	v_dual_mov_b32 v0, v46 :: v_dual_mov_b32 v1, v47
	s_mov_b64 s[4:5], s[48:49]
	s_mov_b64 s[6:7], s[38:39]
	s_mov_b64 s[8:9], s[36:37]
	s_mov_b64 s[10:11], s[34:35]
	s_mov_b32 s12, s53
	s_mov_b32 s13, s52
	s_mov_b32 s14, s51
	s_mov_b32 s15, s50
	s_swappc_b64 s[30:31], s[54:55]
	v_dual_mov_b32 v31, v58 :: v_dual_mov_b32 v0, v40
	v_mov_b32_e32 v1, v41
	s_mov_b64 s[4:5], s[48:49]
	s_mov_b64 s[6:7], s[38:39]
	s_mov_b64 s[8:9], s[36:37]
	s_mov_b64 s[10:11], s[34:35]
	s_mov_b32 s12, s53
	s_mov_b32 s13, s52
	s_mov_b32 s14, s51
	s_mov_b32 s15, s50
	s_swappc_b64 s[30:31], s[54:55]
	s_clause 0xa
	scratch_load_b32 v58, off, s33
	scratch_load_b32 v57, off, s33 offset:4
	scratch_load_b32 v56, off, s33 offset:8
	scratch_load_b32 v47, off, s33 offset:12
	scratch_load_b32 v46, off, s33 offset:16
	scratch_load_b32 v45, off, s33 offset:20
	scratch_load_b32 v44, off, s33 offset:24
	scratch_load_b32 v43, off, s33 offset:28
	scratch_load_b32 v42, off, s33 offset:32
	scratch_load_b32 v41, off, s33 offset:36
	scratch_load_b32 v40, off, s33 offset:40
	v_readlane_b32 s55, v59, 15
	v_readlane_b32 s54, v59, 14
	v_readlane_b32 s53, v59, 13
	v_readlane_b32 s52, v59, 12
	v_readlane_b32 s51, v59, 11
	v_readlane_b32 s50, v59, 10
	v_readlane_b32 s49, v59, 9
	v_readlane_b32 s48, v59, 8
	v_readlane_b32 s39, v59, 7
	v_readlane_b32 s38, v59, 6
	v_readlane_b32 s37, v59, 5
	v_readlane_b32 s36, v59, 4
	v_readlane_b32 s35, v59, 3
	v_readlane_b32 s34, v59, 2
	v_readlane_b32 s31, v59, 1
	v_readlane_b32 s30, v59, 0
	s_mov_b32 s32, s33
	v_readlane_b32 s0, v59, 16
	s_or_saveexec_b32 s1, -1
	scratch_load_b32 v59, off, s33 offset:44
	s_mov_b32 exec_lo, s1
	s_mov_b32 s33, s0
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end0:
	.size	kernel, .Lfunc_end0-kernel

	.set kernel.num_vgpr, max(60, amdgpu.max_num_vgpr)
	.set kernel.num_agpr, max(0, amdgpu.max_num_agpr)
	.set kernel.numbered_sgpr, max(56, amdgpu.max_num_sgpr)
	.set kernel.num_named_barrier, max(0, amdgpu.max_num_named_barrier)
	.set kernel.private_seg_size, 64
	.set kernel.uses_vcc, 1
	.set kernel.uses_flat_scratch, 1
	.set kernel.has_dyn_sized_stack, 1
	.set kernel.has_recursion, 1
	.set kernel.has_indirect_call, 1
	.p2alignl 7, 3214868480
	.fill 96, 4, 3214868480
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 60
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 56
	.set amdgpu.max_num_named_barrier, 0
	.text
	.section	".note.GNU-stack","",@progbits
	.amdgpu_metadata
---
amdhsa.kernels:  []
amdhsa.target:   amdgcn-amd-amdhsa--gfx1100
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
