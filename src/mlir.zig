const std = @import("std");
const tensor = @import("tensor.zig");
const c = @cImport({
  @cInclude("mlir-c/IR.h");
  @cInclude("mlir-c/BuiltinTypes.h");
  @cInclude("mlir-c/BuiltinAttributes.h");
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

pub const MLIRGenerator = struct {
  ctx: c.MlirContext,
  gpa: std.mem.Allocator,
  symbol_table: std.AutoHashMap(*const tensor.Node, c.MlirOperation),

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
      .Create => "linda.create",
      .Add => "linda.add",
      .Mul => "linda.mul",
      .Reshape => "linda.reshape"
    };
    var op_state = c.mlirOperationStateGet(stringRef(op_name), loc);

    var operands = try self.gpa.alloc(c.MlirValue, node.inputs.len);
    for (node.inputs, 0..) |edge, i| {
      std.debug.assert(self.symbol_table.contains(edge));
      if (self.symbol_table.get(edge)) |mval| {
        operands[i] = c.mlirOperationGetResult(mval, 0);
      } else {
        return error.TopoFailure;
      }
    }
    c.mlirOperationStateAddOperands(@ptrCast(&op_state), @intCast(operands.len), @ptrCast(operands.ptr));

    const result_t = try self.gpa.create(c.MlirType);
    result_t.* = c.mlirRankedTensorTypeGet(
      @intCast(node.shape.len),
      @ptrCast(node.shape.ptr),
      try dtypeToMlirType(self.ctx, node.dtype),
      c.mlirAttributeGetNull()
    );
    c.mlirOperationStateAddResults(@ptrCast(&op_state), 1, result_t);

    return c.mlirOperationCreate(@ptrCast(&op_state));
  }

  pub fn compileTensorSchedule(self: *Self, schedule: std.ArrayList(*const tensor.Node)) !c.MlirModule {
    const loc = c.mlirLocationUnknownGet(self.ctx);
    const module = c.mlirModuleCreateEmpty(loc);
    const block = c.mlirModuleGetBody(module);

    for (schedule.items, 0..) |node, pc| {
      const mlir_op = try self.tensorToMlir(node, loc);
      try self.symbol_table.put(node, mlir_op);
      c.mlirBlockInsertOwnedOperation(block, @intCast(pc), mlir_op);
    }

    c.mlirOperationDump(c.mlirModuleGetOperation(module));
    return module;
  }
};
