const std = @import("std");
const tensor = @import("tensor.zig");
const c = @import("capi.zig").imports;
const helpers = @import("helpers.zig");

// ******** Main MLIR Compilation Engine *******
pub const MLIRGenerator = struct {
  ctx: c.MlirContext,
  gpa: std.mem.Allocator,
  symbol_table: std.AutoHashMap(*const tensor.Node, c.MlirValue),
  pass_manager: c.MlirPassManager,
  debug: bool,

  const Self = @This();

  pub fn deinit(self: Self) void {
    c.mlirContextDestroy(self.ctx);
  }

  pub fn init(allocator: std.mem.Allocator, debug: bool) MLIRGenerator {
    const ctx = c.mlirContextCreate();

    // needed for rewrite IR printing
    if (debug) c.mlirContextEnableMultithreading(ctx, false);

    // register dialects
    const registry = c.mlirDialectRegistryCreate();
    c.mlirRegisterAllDialects(registry);
    c.mlirContextAppendDialectRegistry(ctx, registry);
    c.mlirDialectRegistryDestroy(registry);

    const dialects = [_][]const u8 { "linda", "bufferization", "func", "affine", "gpu", "nvvm" };
    helpers.dialectRegisters(&dialects).do(ctx);

    // load passes
    c.mlirRegisterAllLLVMTranslations(ctx);
    c.mlirRegisterAllPasses();

    const passManager = c.mlirPassManagerCreate(ctx);
    c.mlirRegisterAffinePasses();
    c.mlirRegisterGPUPasses();
    c.mlirRegisterAllLLVMTranslations(ctx);
    c.mlirRegisterConversionConvertAffineForToGPUPass();
    c.mlirRegisterConversionConvertGpuOpsToNVVMOps();
    c.mlirRegisterConversionConvertGpuOpsToNVVMOps();
    c.mlirRegisterConversionGpuToLLVMConversionPass();

    if (debug) {
      c.mlirPassManagerEnableIRPrinting(
        passManager, true, true, true, false, false, c.mlirOpPrintingFlagsCreate(), helpers.stringRef("dump/"));
    }

    // TODO: experiment with this more, https://mlir.llvm.org/docs/Passes/#affine-dialect-passes
    // lowering passes from custom dialect to affine, and then GPU module embeded inside host program
    // affine optimizations target control flow. fusion, tiling, unroll
    c.mlirPassManagerAddOwnedPass(passManager, c.mlirCreateLindaLowerToAffinePass());

    const optPm = c.mlirPassManagerGetNestedUnder(passManager, helpers.stringRef("func.func"));
    helpers.mlirAssertGood(c.mlirOpPassManagerAddPipeline(
      optPm, helpers.stringRef(
        \\affine-loop-fusion,
        \\affine-loop-tile{tile-sizes=8,16},
        \\convert-affine-for-to-gpu{gpu-block-dims=1 gpu-thread-dims=1}
        ), helpers.pipelineDiagnostic, null));

    c.mlirPassManagerAddOwnedPass(passManager, c.mlirCreateGPUGpuKernelOutliningPass());

    // TODO: stdout callback and do this
    // if (debug) c.mlirPrintPassPipeline(passManager, , null);

    return .{ .ctx = ctx, .gpa = allocator, .symbol_table = .init(allocator), .debug = debug, .pass_manager = passManager };
  }

  fn tensorToMlir(self: *Self, node: *const tensor.Node, loc: c.MlirLocation) !c.MlirOperation {
    const op_name = switch (node.op) {
      .Add => "linda.add",
      .Mul => "linda.mul",
      .Reshape => "linda.reshape",
      else => return error.UnsupportedTensorIROp
    };

    var operands = try self.gpa.alloc(c.MlirValue, node.inputs.len);
    for (node.inputs, 0..) |edge, i| {
      std.debug.assert(self.symbol_table.contains(edge));
      operands[i] = self.symbol_table.get(edge) orelse return error.TopoFailure;
    }

    const result_t = try helpers.tensorToMlirType(self.gpa, self.ctx, node.shape, node.dtype);
    return helpers.createMlirOp(loc, op_name, operands, result_t, null, null);
  }

  pub fn compileTensorSchedule(self: *Self, schedule: std.ArrayList(*const tensor.Node)) !c.MlirModule {
    const loc = c.mlirLocationUnknownGet(self.ctx);
    const module = c.mlirModuleCreateEmpty(loc);

    var karg_nodes: std.ArrayList(*const tensor.Node) = .empty;
    var karg_types: std.ArrayList(c.MlirType) = .empty;

    // (1) Construct kernel entry region parameterized by Zig allocated root Tensor
    //      buffers as scoped memref typed values. All other Tensor ops reference
    //      previous SSA nodes
    for (schedule.items) |node| {
      if (node.op != .Buffer) continue;

      // root nodes passes as memref arguments to kernel function
      const buf_t = c.mlirMemRefTypeContiguousGet(
        try helpers.dtypeToMlirType(self.ctx, node.dtype),
        @intCast(node.shape.len),
        @ptrCast(node.shape.ptr),
        c.mlirAttributeGetNull()
      );
      try karg_nodes.append(self.gpa, node);
      try karg_types.append(self.gpa, buf_t);
    }

    const kernel_region = c.mlirRegionCreate();
    const locs = try self.gpa.alloc(c.MlirLocation, karg_types.items.len);
    for (locs) |*l| l.* = loc;
    const block = c.mlirBlockCreate(@intCast(karg_types.items.len), @ptrCast(karg_types.items.ptr), @ptrCast(locs.ptr));
    c.mlirRegionAppendOwnedBlock(kernel_region, block);

    const func_t = c.mlirFunctionTypeGet(self.ctx, @intCast(karg_types.items.len), @ptrCast(karg_types.items.ptr), 0, null);
    const attrs = [_]c.MlirNamedAttribute{
      helpers.getNamedAttribute(self.ctx, "sym_name", c.mlirStringAttrGet(self.ctx, helpers.stringRef("linda_program"))),
      helpers.getNamedAttribute(self.ctx, "function_type", c.mlirTypeAttrGet(func_t))
    };
    const regions = [_]c.MlirRegion{kernel_region};
    const kernel_op = helpers.createMlirOp(loc, "func.func", null, null, attrs[0..], regions[0..]);

    var pc: u32 = 0;
    for (karg_nodes.items, 0..) |node, i| {
      // cast to tensor
      const buf = c.mlirBlockGetArgument(block, @intCast(i));
      const tensor_type = try helpers.tensorToMlirType(self.gpa, self.ctx, node.shape, node.dtype);
      const operand = [_]c.MlirValue{buf};
      const buf_tensor = helpers.createMlirOp(loc, "bufferization.to_tensor", operand[0..], tensor_type, null, null);

      c.mlirBlockInsertOwnedOperation(block, @intCast(pc), buf_tensor);
      try self.symbol_table.put(node, c.mlirOperationGetResult(buf_tensor, 0));

      pc += 1;
    }

    // (2)  Construct SSA list of Tensor operations using Linda dialect
    //      incoming edges are resolved by symbol table, dtypes mapped to MLIR
    for (schedule.items) |node| {
      if (node.op == .Buffer) continue;
      const mlir_op = try self.tensorToMlir(node, loc);
      // append to kernel basic block
      c.mlirBlockInsertOwnedOperation(block, @intCast(pc), mlir_op);

      const result = c.mlirOperationGetResult(mlir_op, 0);
      try self.symbol_table.put(node, result);
      pc += 1;
    }

    const ret_op = helpers.createMlirOp(loc, "func.return", null, null, null, null);
    c.mlirBlockInsertOwnedOperation(block, @intCast(pc), ret_op);

    const module_block = c.mlirModuleGetBody(module);
    c.mlirBlockAppendOwnedOperation(module_block, kernel_op);

    // (3) progressive graph rewrites to lower to LLVM IR
    // start with built in affine dialect for simple, efficient Tensor loop representation
    helpers.mlirAssertGood(c.mlirPassManagerRunOnOp(self.pass_manager, c.mlirModuleGetOperation(module)));

    return module;
  }
};
