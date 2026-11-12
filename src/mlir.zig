const std = @import("std");
const tensor = @import("tensor.zig");
const c = @cImport({
  @cInclude("mlir-c/IR.h");
  @cInclude("mlir-c/BuiltinTypes.h");
  @cInclude("mlir-c/BuiltinAttributes.h");
  @cInclude("linda-c/Passes.h");
  @cInclude("linda-c/Dialect.h");
});

fn dtypeToMlirType(ctx: c.MlirContext, dtype: tensor.DType) !c.MlirType {
  return switch (dtype) {
    .f32 => c.mlirF32TypeGet(ctx),
    .u32 => c.mlirIntegerTypeUnsignedGet(ctx, 32),
    .i32 => c.mlirIntegerTypeSignedGet(ctx, 32)
  };
}

fn stringRef(str: []const u8) c.MlirStringRef { return c.mlirStringRefCreateFromCString(@ptrCast(str)); }

fn createOp(name: []const u8, operands: ?[]c.MlirValue, result_t: ?c.MlirType) c.MlirOperation {
  var op_state = c.MlirOperationStateGet(stringRef(name));
  if (operands) |ops| c.mlirOperationStateAddOperands(@ptrCast(&op_state), @intCast(ops.len), @ptrCast(ops.ptr))
  if (result_t) |typ| c.mlirOperationStateAddResults(@ptrCast(&op_state), 1, typ);
  return c.mlirOperationCreate(@ptrCast(&op_state));
}

pub const MLIRGenerator = struct {
  ctx: c.MlirContext,
  gpa: std.mem.Allocator,
  symbol_table: std.AutoHashMap(*const tensor.Node, c.MlirValue),

  const Self = @This();

  pub fn deinit(self: Self) void {
    c.mlirContextDestroy(self.ctx);
  }

  pub fn init(allocator: std.mem.Allocator) MLIRGenerator {
    const ctx = c.mlirContextCreate();

    // load custom dialect from CAPI registry
    const handle = c.mlirGetDialectHandle__linda__();
    c.mlirDialectHandleRegisterDialect(handle, ctx);
    const dialect = c.mlirDialectHandleLoadDialect(handle, ctx);
    std.debug.assert(! c.mlirDialectIsNull(dialect));
    std.debug.print("succesfully loaded dialect...\n", .{});

    return .{ .ctx = ctx, .gpa = allocator, .symbol_table = .init(allocator) };
  }

  fn tensorToMlir(self: *Self, node: *const tensor.Node, loc: c.MlirLocation) !c.MlirOperation {
    const op_name = switch (node.op) {
      .Add => "linda.add",
      .Mul => "linda.mul",
      .Reshape => "linda.reshape",
      else => error.UnsupportedTensorIROp
    };

    var operands = try self.gpa.alloc(c.MlirValue, node.inputs.len);
    for (node.inputs, 0..) |edge, i| {
      std.debug.assert(self.symbol_table.contains(edge));
      if (self.symbol_table.get(edge)) |mval| {
        operands[i] = c.mlirOperationGetResult(mval, 0);
      } else {
        return error.TopoFailure;
      }
    }

    const result_t = try self.gpa.create(c.MlirType);
    result_t.* = c.mlirRankedTensorTypeGet(
      @intCast(node.shape.len),
      @ptrCast(node.shape.ptr),
      try dtypeToMlirType(self.ctx, node.dtype),
      c.mlirAttributeGetNull()
    );

    return createOp(op_name, operands, result_t);
  }

  pub fn compileTensorSchedule(self: *Self, schedule: std.ArrayList(*const tensor.Node)) !c.MlirModule {
    const loc = c.mlirLocationUnknownGet(self.ctx);
    const module = c.mlirModuleCreateEmpty(loc);
    const block = c.mlirModuleGetBody(module);

    var karg_nodes: std.ArrayList(const *tensor.Node) = .empty;
    var karg_types: std.ArrayList(c.MlirValue) = .empty;

    // (1) Construct kernel entry region parameterized by Zig allocated root Tensor
    //      buffers as scoped memref typed values. All other Tensor ops reference
    //      previous SSA nodes
    for (schedule.items) |node| {
      if (node.op != .Buffer) continue;

      // root nodes passes as memref arguments to kernel function
      const buf_t = c.mlirMemRefTypeContiguous(
        try dtypeToMlirType(node.dtype),
        node.shape.len,
        &node.shape,
        c.mlirAttributesGetNull()
      );
      try karg_nodes.append(self.gpa, node);
      try karg_types.append(slef.gpa, buf_t);
    }

    var kernel_region = c.mlirRegionCreate();
    var locs = self.gpa.alloc(c.MlirLocation, karg_types.items.len);
    for (&locs) |*l| l.* = loc;

    const entry = c.mlirBlockCreate(karg_types.items.len, &karg_types, &locs);
    c.mlirRegionAppendOwnedBlock(kernel_region, entry);

    for (karg_nodes.items, 0..) |sym, i| {
      self.symbol_table.put(sym, c.mlirBlockGetArgument(entry, i));
    }

    // (2)  Construct SSA list of Tensor operations using Linda dialect
    //      incoming edges are resolved by symbol table, dtypes mapped to MLIR
    var pc = 0;
    for (schedule.items) |node| {
      if (node.op == .Buffer) continue;
      const mlir_op = try self.tensorToMlir(node, loc);
      c.mlirBlockInsertOwnedOperation(block, @intCast(pc), mlir_op);

      const result = c.mlirOperationGetResult(mlir_op);
      try self.symbol_table.put(node, result);
      pc += 1;
    }

    c.mlirOperationDump(c.mlirModuleGetOperation(module));

    // (3) progressive graph rewrites to lower to LLVM IR
    // start with built in affine dialect for simple, efficient Tensor loop representation
    const passManager = c.mlirPassManagerCreate(self.ctx);
    const affinePass = c.mlirCreateLindaLowerToAffinePass();
    c.mlirPassManagerAddOwnedPass(passManager, affinePass);

    const result = c.mlirPassManagerRunOnOp(passManager, c.mlirModuleGetOperation(module));
    std.debug.assert(c.mlirLogicalResultIsSuccess(result));

    c.mlirOperationDump(c.mlirModuleGetOperation(module));

    return module;
  }
};
