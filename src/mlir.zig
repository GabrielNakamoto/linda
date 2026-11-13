const std = @import("std");
const tensor = @import("tensor.zig");
const c = @import("capi.zig").imports;

// ****** MLIR Wrappers and Conversion *******
fn dtypeToMlirType(ctx: c.MlirContext, dtype: tensor.DType) !c.MlirType {
  return switch (dtype) {
    .f32 => c.mlirF32TypeGet(ctx),
    .u32 => c.mlirIntegerTypeUnsignedGet(ctx, 32),
    .i32 => c.mlirIntegerTypeSignedGet(ctx, 32)
  };
}

fn stringRef(str: []const u8) c.MlirStringRef {
  return c.mlirStringRefCreateFromCString(@ptrCast(str));
}

fn getNamedAttribute(ctx: c.MlirContext, name: []const u8, attr: c.MlirAttribute) c.MlirNamedAttribute {
  return c.mlirNamedAttributeGet(c.mlirIdentifierGet(ctx, stringRef(name)), attr);
}

fn createOp(loc: c.MlirLocation, name: []const u8, operands: ?[]const c.MlirValue, result_t: ?*const c.MlirType,
  attributes: ?[]const c.MlirNamedAttribute, regions: ?[]const c.MlirRegion) c.MlirOperation {
  var op_state = c.mlirOperationStateGet(stringRef(name), loc);
  if (operands) |ops| c.mlirOperationStateAddOperands(@ptrCast(&op_state), @intCast(ops.len), @ptrCast(ops.ptr));
  if (result_t) |tp| c.mlirOperationStateAddResults(@ptrCast(&op_state), 1, @ptrCast(tp));
  if (attributes) |attr| c.mlirOperationStateAddAttributes(@ptrCast(&op_state), @intCast(attr.len), @ptrCast(attr.ptr));
  if (regions) |rs| c.mlirOperationStateAddOwnedRegions(@ptrCast(&op_state), @intCast(rs.len), @ptrCast(rs.ptr));
  return c.mlirOperationCreate(@ptrCast(&op_state));
}

fn tensorToMlirType(gpa: std.mem.Allocator, ctx: c.MlirContext, shape: []const u64, dtype: tensor.DType) !*const c.MlirType {
  const mlir_t = try gpa.create(c.MlirType);
  mlir_t.* = c.mlirRankedTensorTypeGet(
    @intCast(shape.len),
    @ptrCast(shape.ptr),
    try dtypeToMlirType(ctx, dtype),
    c.mlirAttributeGetNull()
  );
  return mlir_t;
}

// yay comptime magic
fn dialectRegisters(comptime dialects: []const []const u8) type {
  return struct {
    pub fn do(ctx: c.MlirContext) void {
      inline for (dialects) |name| {
        const handleFn = @field(c, "mlirGetDialectHandle__" ++ name ++ "__");
        const handle = handleFn();
        c.mlirDialectHandleRegisterDialect(handle, ctx);
        const dialect = c.mlirDialectHandleLoadDialect(handle, ctx);
        std.debug.assert(! c.mlirDialectIsNull(dialect));
      }
    }
  };
}

fn pipelineDiagnostic(msg: c.MlirStringRef, _:?*anyopaque) callconv(.c) void {
  std.debug.print("pass pipeline error: {s}", .{msg.data[0..msg.length]});
}

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
    c.mlirRegisterAllLLVMTranslations(ctx);

    // needed for rewrite IR printing
    if (debug) c.mlirContextEnableMultithreading(ctx, false);

    // register dialects
    const dialects = [_][]const u8 { "linda", "bufferization", "func", "affine" };
    dialectRegisters(dialects[0..]).do(ctx);

    // load passes
    const passManager = c.mlirPassManagerCreate(ctx);
    if (debug) {
      c.mlirPassManagerEnableIRPrinting(
        passManager, true, true, true, false, false, c.mlirOpPrintingFlagsCreate(), stringRef(""));
    }
    c.mlirPassManagerAddOwnedPass(passManager, c.mlirCreateLindaLowerToAffinePass());
    c.mlirRegisterAffinePasses();

    const optPm = c.mlirPassManagerGetNestedUnder(passManager, stringRef("func.func"));
    // TODO: experiment with this more, https://mlir.llvm.org/docs/Passes/#affine-dialect-passes
    const result = c.mlirOpPassManagerAddPipeline(
      optPm, stringRef("affine-loop-fusion, affine-loop-tile{tile-sizes=8,16}"), pipelineDiagnostic, null);
    std.debug.assert(c.mlirLogicalResultIsSuccess(result));

    // final pass to LLVM IR
    c.mlirPassManagerAddOwnedPass(passManager, c.mlirCreateLindaLowerToLLVMPass());

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

    const result_t = try tensorToMlirType(self.gpa, self.ctx, node.shape, node.dtype);
    return createOp(loc, op_name, operands, result_t, null, null);
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
        try dtypeToMlirType(self.ctx, node.dtype),
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
      getNamedAttribute(self.ctx, "sym_name", c.mlirStringAttrGet(self.ctx, stringRef("kernel"))),
      getNamedAttribute(self.ctx, "function_type", c.mlirTypeAttrGet(func_t))
    };
    const regions = [_]c.MlirRegion{kernel_region};
    const kernel_op = createOp(loc, "func.func", null, null, attrs[0..], regions[0..]);

    var pc: u32 = 0;
    for (karg_nodes.items, 0..) |node, i| {
      // cast to tensor
      const buf = c.mlirBlockGetArgument(block, @intCast(i));
      const tensor_type = try tensorToMlirType(self.gpa, self.ctx, node.shape, node.dtype);
      const operand = [_]c.MlirValue{buf};
      const buf_tensor = createOp(loc, "bufferization.to_tensor", operand[0..], tensor_type, null, null);

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

    const ret_op = createOp(loc, "func.return", null, null, null, null);
    c.mlirBlockInsertOwnedOperation(block, @intCast(pc), ret_op);

    const module_block = c.mlirModuleGetBody(module);
    c.mlirBlockAppendOwnedOperation(module_block, kernel_op);

    // (3) progressive graph rewrites to lower to LLVM IR
    // start with built in affine dialect for simple, efficient Tensor loop representation
    const result = c.mlirPassManagerRunOnOp(self.pass_manager, c.mlirModuleGetOperation(module));
    _ = result;
    // std.debug.assert(c.mlirLogicalResultIsSuccess(result));
    return module;
  }
};
