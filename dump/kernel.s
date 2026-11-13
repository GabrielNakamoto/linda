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
	scratch_store_b32 off, v63, s33 offset:68
	s_mov_b32 exec_lo, s1
	v_writelane_b32 v63, s0, 16
	s_addk_i32 s32, 0x50
	s_getpc_b64 s[0:1]
	s_add_u32 s0, s0, malloc@gotpcrel32@lo+4
	s_addc_u32 s1, s1, malloc@gotpcrel32@hi+12
	s_clause 0x10
	scratch_store_b32 off, v40, s33 offset:64
	scratch_store_b32 off, v41, s33 offset:60
	scratch_store_b32 off, v42, s33 offset:56
	scratch_store_b32 off, v43, s33 offset:52
	scratch_store_b32 off, v44, s33 offset:48
	scratch_store_b32 off, v45, s33 offset:44
	scratch_store_b32 off, v46, s33 offset:40
	scratch_store_b32 off, v47, s33 offset:36
	scratch_store_b32 off, v56, s33 offset:32
	scratch_store_b32 off, v57, s33 offset:28
	scratch_store_b32 off, v58, s33 offset:24
	scratch_store_b32 off, v59, s33 offset:20
	scratch_store_b32 off, v60, s33 offset:16
	scratch_store_b32 off, v61, s33 offset:12
	scratch_store_b32 off, v62, s33 offset:8
	scratch_store_b32 off, v72, s33 offset:4
	scratch_store_b32 off, v73, s33
	v_dual_mov_b32 v46, v2 :: v_dual_mov_b32 v1, 0
	v_writelane_b32 v63, s30, 0
	v_mov_b32_e32 v0, 0x2000
	v_dual_mov_b32 v58, v31 :: v_dual_mov_b32 v57, v17
	v_dual_mov_b32 v56, v16 :: v_dual_mov_b32 v47, v3
	v_writelane_b32 v63, s31, 1
	v_writelane_b32 v63, s34, 2
	v_writelane_b32 v63, s35, 3
	s_mov_b64 s[34:35], s[10:11]
	v_writelane_b32 v63, s36, 4
	v_writelane_b32 v63, s37, 5
	s_mov_b64 s[36:37], s[8:9]
	v_writelane_b32 v63, s38, 6
	v_writelane_b32 v63, s39, 7
	s_mov_b64 s[38:39], s[6:7]
	v_writelane_b32 v63, s48, 8
	v_writelane_b32 v63, s49, 9
	s_mov_b64 s[48:49], s[4:5]
	v_writelane_b32 v63, s50, 10
	s_mov_b32 s50, s15
	v_writelane_b32 v63, s51, 11
	s_mov_b32 s51, s14
	v_writelane_b32 v63, s52, 12
	s_mov_b32 s52, s13
	v_writelane_b32 v63, s53, 13
	s_mov_b32 s53, s12
	v_writelane_b32 v63, s54, 14
	v_writelane_b32 v63, s55, 15
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
	v_dual_mov_b32 v60, v41 :: v_dual_mov_b32 v59, v40
	s_swappc_b64 s[30:31], s[54:55]
	v_dual_mov_b32 v42, v0 :: v_dual_mov_b32 v43, v1
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
	v_dual_mov_b32 v62, v43 :: v_dual_mov_b32 v61, v42
	s_swappc_b64 s[30:31], s[54:55]
	v_dual_mov_b32 v44, v0 :: v_dual_mov_b32 v45, v1
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
	v_dual_mov_b32 v73, v45 :: v_dual_mov_b32 v72, v44
	s_swappc_b64 s[30:31], s[54:55]
	v_dual_mov_b32 v3, v1 :: v_dual_mov_b32 v2, v0
	v_dual_mov_b32 v4, v46 :: v_dual_mov_b32 v5, v47
	v_dual_mov_b32 v7, v1 :: v_dual_mov_b32 v6, v0
	s_mov_b64 s[0:1], 0
	s_branch .LBB0_3
.LBB0_1:
	s_set_inst_prefetch_distance 0x2
	v_add_co_u32 v56, vcc_lo, 0x100, v56
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_add_co_ci_u32_e64 v57, null, 0, v57, vcc_lo
	v_add_co_u32 v6, vcc_lo, 0x100, v6
	v_add_co_ci_u32_e64 v7, null, 0, v7, vcc_lo
	v_add_co_u32 v4, vcc_lo, 0x100, v4
	s_delay_alu instid0(VALU_DEP_1)
	v_add_co_ci_u32_e64 v5, null, 0, v5, vcc_lo
	s_add_u32 s0, s0, 1
	s_addc_u32 s1, s1, 0
	s_mov_b32 s2, 0
.LBB0_2:
	s_delay_alu instid0(SALU_CYCLE_1)
	s_and_b32 vcc_lo, exec_lo, s2
	s_cbranch_vccnz .LBB0_8
.LBB0_3:
	v_cmp_gt_i64_e64 s2, s[0:1], 31
	s_and_b32 vcc_lo, exec_lo, s2
	s_mov_b32 s2, -1
	s_cbranch_vccnz .LBB0_2
	v_dual_mov_b32 v9, v5 :: v_dual_mov_b32 v8, v4
	v_dual_mov_b32 v11, v7 :: v_dual_mov_b32 v10, v6
	v_dual_mov_b32 v12, v56 :: v_dual_mov_b32 v13, v57
	s_mov_b64 s[2:3], 0
	s_set_inst_prefetch_distance 0x1
	s_branch .LBB0_6
	.p2align	6
.LBB0_5:
	s_and_not1_b32 vcc_lo, exec_lo, s4
	s_cbranch_vccz .LBB0_1
.LBB0_6:
	v_cmp_gt_i64_e64 s4, s[2:3], 63
	s_and_b32 vcc_lo, exec_lo, s4
	s_mov_b32 s4, -1
	s_cbranch_vccnz .LBB0_5
	flat_load_b32 v14, v[8:9]
	flat_load_b32 v15, v[12:13]
	v_add_co_u32 v12, vcc_lo, v12, 4
	s_delay_alu instid0(VALU_DEP_1)
	v_add_co_ci_u32_e64 v13, null, 0, v13, vcc_lo
	s_add_u32 s2, s2, 1
	s_addc_u32 s3, s3, 0
	s_mov_b32 s4, 0
	s_waitcnt vmcnt(0) lgkmcnt(0)
	v_add_f32_e32 v14, v14, v15
	flat_store_b32 v[10:11], v14
	v_add_co_u32 v10, vcc_lo, v10, 4
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_add_co_ci_u32_e64 v11, null, 0, v11, vcc_lo
	v_add_co_u32 v8, vcc_lo, v8, 4
	v_add_co_ci_u32_e64 v9, null, 0, v9, vcc_lo
	s_branch .LBB0_5
.LBB0_8:
	v_dual_mov_b32 v4, v46 :: v_dual_mov_b32 v5, v47
	v_dual_mov_b32 v6, v72 :: v_dual_mov_b32 v7, v73
	v_dual_mov_b32 v9, v3 :: v_dual_mov_b32 v8, v2
	s_mov_b64 s[0:1], 0
	s_branch .LBB0_11
.LBB0_9:
	s_set_inst_prefetch_distance 0x2
	v_add_co_u32 v8, vcc_lo, 0x100, v8
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_add_co_ci_u32_e64 v9, null, 0, v9, vcc_lo
	v_add_co_u32 v6, vcc_lo, 0x100, v6
	v_add_co_ci_u32_e64 v7, null, 0, v7, vcc_lo
	v_add_co_u32 v4, vcc_lo, 0x100, v4
	s_delay_alu instid0(VALU_DEP_1)
	v_add_co_ci_u32_e64 v5, null, 0, v5, vcc_lo
	s_add_u32 s0, s0, 1
	s_addc_u32 s1, s1, 0
	s_mov_b32 s2, 0
.LBB0_10:
	s_delay_alu instid0(SALU_CYCLE_1)
	s_and_b32 vcc_lo, exec_lo, s2
	s_cbranch_vccnz .LBB0_16
.LBB0_11:
	v_cmp_gt_i64_e64 s2, s[0:1], 31
	s_and_b32 vcc_lo, exec_lo, s2
	s_mov_b32 s2, -1
	s_cbranch_vccnz .LBB0_10
	v_dual_mov_b32 v11, v5 :: v_dual_mov_b32 v10, v4
	v_dual_mov_b32 v13, v7 :: v_dual_mov_b32 v12, v6
	v_dual_mov_b32 v15, v9 :: v_dual_mov_b32 v14, v8
	s_mov_b64 s[2:3], 0
	s_set_inst_prefetch_distance 0x1
	s_branch .LBB0_14
	.p2align	6
.LBB0_13:
	s_and_not1_b32 vcc_lo, exec_lo, s4
	s_cbranch_vccz .LBB0_9
.LBB0_14:
	v_cmp_gt_i64_e64 s4, s[2:3], 63
	s_and_b32 vcc_lo, exec_lo, s4
	s_mov_b32 s4, -1
	s_cbranch_vccnz .LBB0_13
	flat_load_b32 v16, v[10:11]
	flat_load_b32 v17, v[14:15]
	v_add_co_u32 v14, vcc_lo, v14, 4
	s_delay_alu instid0(VALU_DEP_1)
	v_add_co_ci_u32_e64 v15, null, 0, v15, vcc_lo
	s_add_u32 s2, s2, 1
	s_addc_u32 s3, s3, 0
	s_mov_b32 s4, 0
	s_waitcnt vmcnt(0) lgkmcnt(0)
	v_add_f32_e32 v16, v16, v17
	flat_store_b32 v[12:13], v16
	v_add_co_u32 v12, vcc_lo, v12, 4
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_add_co_ci_u32_e64 v13, null, 0, v13, vcc_lo
	v_add_co_u32 v10, vcc_lo, v10, 4
	v_add_co_ci_u32_e64 v11, null, 0, v11, vcc_lo
	s_branch .LBB0_13
.LBB0_16:
	v_dual_mov_b32 v4, v61 :: v_dual_mov_b32 v5, v62
	s_mov_b64 s[0:1], 0
	s_branch .LBB0_19
.LBB0_17:
	s_set_inst_prefetch_distance 0x2
	v_add_co_u32 v46, vcc_lo, 0x100, v46
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_add_co_ci_u32_e64 v47, null, 0, v47, vcc_lo
	v_add_co_u32 v4, vcc_lo, 0x100, v4
	v_add_co_ci_u32_e64 v5, null, 0, v5, vcc_lo
	v_add_co_u32 v2, vcc_lo, 0x100, v2
	s_delay_alu instid0(VALU_DEP_1)
	v_add_co_ci_u32_e64 v3, null, 0, v3, vcc_lo
	s_add_u32 s0, s0, 1
	s_addc_u32 s1, s1, 0
	s_mov_b32 s2, 0
.LBB0_18:
	s_delay_alu instid0(SALU_CYCLE_1)
	s_and_b32 vcc_lo, exec_lo, s2
	s_cbranch_vccnz .LBB0_24
.LBB0_19:
	v_cmp_gt_i64_e64 s2, s[0:1], 31
	s_and_b32 vcc_lo, exec_lo, s2
	s_mov_b32 s2, -1
	s_cbranch_vccnz .LBB0_18
	v_dual_mov_b32 v7, v3 :: v_dual_mov_b32 v6, v2
	v_dual_mov_b32 v9, v5 :: v_dual_mov_b32 v8, v4
	v_dual_mov_b32 v10, v46 :: v_dual_mov_b32 v11, v47
	s_mov_b64 s[2:3], 0
	s_set_inst_prefetch_distance 0x1
	s_branch .LBB0_22
	.p2align	6
.LBB0_21:
	s_and_not1_b32 vcc_lo, exec_lo, s4
	s_cbranch_vccz .LBB0_17
.LBB0_22:
	v_cmp_gt_i64_e64 s4, s[2:3], 63
	s_and_b32 vcc_lo, exec_lo, s4
	s_mov_b32 s4, -1
	s_cbranch_vccnz .LBB0_21
	flat_load_b32 v12, v[6:7]
	flat_load_b32 v13, v[10:11]
	v_add_co_u32 v10, vcc_lo, v10, 4
	s_delay_alu instid0(VALU_DEP_1)
	v_add_co_ci_u32_e64 v11, null, 0, v11, vcc_lo
	s_add_u32 s2, s2, 1
	s_addc_u32 s3, s3, 0
	s_mov_b32 s4, 0
	s_waitcnt vmcnt(0) lgkmcnt(0)
	v_mul_f32_e32 v12, v12, v13
	flat_store_b32 v[8:9], v12
	v_add_co_u32 v8, vcc_lo, v8, 4
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_add_co_ci_u32_e64 v9, null, 0, v9, vcc_lo
	v_add_co_u32 v6, vcc_lo, v6, 4
	v_add_co_ci_u32_e64 v7, null, 0, v7, vcc_lo
	s_branch .LBB0_21
.LBB0_24:
	s_mov_b64 s[0:1], 0
	s_branch .LBB0_27
.LBB0_25:
	s_set_inst_prefetch_distance 0x2
	v_add_co_u32 v61, vcc_lo, 0x100, v61
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_add_co_ci_u32_e64 v62, null, 0, v62, vcc_lo
	v_add_co_u32 v59, vcc_lo, 0x100, v59
	v_add_co_ci_u32_e64 v60, null, 0, v60, vcc_lo
	v_add_co_u32 v72, vcc_lo, 0x100, v72
	s_delay_alu instid0(VALU_DEP_1)
	v_add_co_ci_u32_e64 v73, null, 0, v73, vcc_lo
	s_add_u32 s0, s0, 1
	s_addc_u32 s1, s1, 0
	s_mov_b32 s2, 0
.LBB0_26:
	s_delay_alu instid0(SALU_CYCLE_1)
	s_and_b32 vcc_lo, exec_lo, s2
	s_cbranch_vccnz .LBB0_32
.LBB0_27:
	v_cmp_gt_i64_e64 s2, s[0:1], 31
	s_and_b32 vcc_lo, exec_lo, s2
	s_mov_b32 s2, -1
	s_cbranch_vccnz .LBB0_26
	v_dual_mov_b32 v2, v72 :: v_dual_mov_b32 v3, v73
	v_dual_mov_b32 v4, v59 :: v_dual_mov_b32 v5, v60
	v_dual_mov_b32 v6, v61 :: v_dual_mov_b32 v7, v62
	s_mov_b64 s[2:3], 0
	s_set_inst_prefetch_distance 0x1
	s_branch .LBB0_30
	.p2align	6
.LBB0_29:
	s_and_not1_b32 vcc_lo, exec_lo, s4
	s_cbranch_vccz .LBB0_25
.LBB0_30:
	v_cmp_gt_i64_e64 s4, s[2:3], 63
	s_and_b32 vcc_lo, exec_lo, s4
	s_mov_b32 s4, -1
	s_cbranch_vccnz .LBB0_29
	flat_load_b32 v8, v[2:3]
	flat_load_b32 v9, v[6:7]
	v_add_co_u32 v6, vcc_lo, v6, 4
	s_delay_alu instid0(VALU_DEP_1)
	v_add_co_ci_u32_e64 v7, null, 0, v7, vcc_lo
	s_add_u32 s2, s2, 1
	s_addc_u32 s3, s3, 0
	s_mov_b32 s4, 0
	s_waitcnt vmcnt(0) lgkmcnt(0)
	v_mul_f32_e32 v8, v8, v9
	flat_store_b32 v[4:5], v8
	v_add_co_u32 v4, vcc_lo, v4, 4
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_add_co_ci_u32_e64 v5, null, 0, v5, vcc_lo
	v_add_co_u32 v2, vcc_lo, v2, 4
	v_add_co_ci_u32_e64 v3, null, 0, v3, vcc_lo
	s_branch .LBB0_29
.LBB0_32:
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
	v_dual_mov_b32 v31, v58 :: v_dual_mov_b32 v0, v44
	v_mov_b32_e32 v1, v45
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
	v_dual_mov_b32 v0, v42 :: v_dual_mov_b32 v1, v43
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
	s_clause 0x10
	scratch_load_b32 v73, off, s33
	scratch_load_b32 v72, off, s33 offset:4
	scratch_load_b32 v62, off, s33 offset:8
	scratch_load_b32 v61, off, s33 offset:12
	scratch_load_b32 v60, off, s33 offset:16
	scratch_load_b32 v59, off, s33 offset:20
	scratch_load_b32 v58, off, s33 offset:24
	scratch_load_b32 v57, off, s33 offset:28
	scratch_load_b32 v56, off, s33 offset:32
	scratch_load_b32 v47, off, s33 offset:36
	scratch_load_b32 v46, off, s33 offset:40
	scratch_load_b32 v45, off, s33 offset:44
	scratch_load_b32 v44, off, s33 offset:48
	scratch_load_b32 v43, off, s33 offset:52
	scratch_load_b32 v42, off, s33 offset:56
	scratch_load_b32 v41, off, s33 offset:60
	scratch_load_b32 v40, off, s33 offset:64
	v_readlane_b32 s55, v63, 15
	v_readlane_b32 s54, v63, 14
	v_readlane_b32 s53, v63, 13
	v_readlane_b32 s52, v63, 12
	v_readlane_b32 s51, v63, 11
	v_readlane_b32 s50, v63, 10
	v_readlane_b32 s49, v63, 9
	v_readlane_b32 s48, v63, 8
	v_readlane_b32 s39, v63, 7
	v_readlane_b32 s38, v63, 6
	v_readlane_b32 s37, v63, 5
	v_readlane_b32 s36, v63, 4
	v_readlane_b32 s35, v63, 3
	v_readlane_b32 s34, v63, 2
	v_readlane_b32 s31, v63, 1
	v_readlane_b32 s30, v63, 0
	s_mov_b32 s32, s33
	v_readlane_b32 s0, v63, 16
	s_or_saveexec_b32 s1, -1
	scratch_load_b32 v63, off, s33 offset:68
	s_mov_b32 exec_lo, s1
	s_mov_b32 s33, s0
	s_waitcnt vmcnt(0)
	s_setpc_b64 s[30:31]
.Lfunc_end0:
	.size	kernel, .Lfunc_end0-kernel

	.set kernel.num_vgpr, max(74, amdgpu.max_num_vgpr)
	.set kernel.num_agpr, max(0, amdgpu.max_num_agpr)
	.set kernel.numbered_sgpr, max(56, amdgpu.max_num_sgpr)
	.set kernel.num_named_barrier, max(0, amdgpu.max_num_named_barrier)
	.set kernel.private_seg_size, 80
	.set kernel.uses_vcc, 1
	.set kernel.uses_flat_scratch, 1
	.set kernel.has_dyn_sized_stack, 1
	.set kernel.has_recursion, 1
	.set kernel.has_indirect_call, 1
	.p2alignl 7, 3214868480
	.fill 96, 4, 3214868480
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 74
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
