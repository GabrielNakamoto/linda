const std = @import("std");
const tensor = @import("tensor.zig");
const c = @cImport({
  @cInclude("mlir-c/IR.h");
  @cInclude("mlir-c/BuiltinTypes.h");
  @cInclude("mlir-c/BuiltinAttributes.h");
  @cInclude("linda-c/Dialect.h");
});

fn getOpState(name: [*c]const u8, loc: c.MlirLocation) c.MlirOperationState {
  return c.mlirOperationStateGet(c.mlirStringRefCreateFromCString(name), loc);
}

fn dtypeToMlirType(ctx: c.MlirContext, dtype: tensor.DType) !c.MlirType {
  return switch (dtype) {
    .f32 => c.mlirF32TypeGet(ctx),
    .u32 => c.mlirIntegerTypeUnsignedGet(ctx, 32),
    .i32 => c.mlirIntegerTypeSignedGet(ctx, 32)
  };
}

pub const MLIRGenerator = struct {
  ctx: c.MlirContext,
  allocator: std.mem.Allocator,

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

    return .{ .ctx = ctx, .allocator = allocator };
  }

  pub fn tensorToMlir(self: Self, node: *const tensor.Node) !c.MlirOperation {
    const op_name = switch (node.op) {
      .Add => "linda.add",
      .Mul => "linda.mul",
      else => return error.TensorIRNotInDialect
    };
    const loc = c.mlirLocationUnknownGet(self.ctx);
    var op_state = getOpState(op_name, loc);

    var operands = try self.allocator.alloc(c.MlirType, node.inputs.len);
    defer self.allocator.free(operands);

    for (node.inputs, 0..) |edge, i| {
      const mlir_t = try dtypeToMlirType(self.ctx, node.dtype);

      operands[i] = c.mlirRankedTensorTypeGet(
        @intCast(edge.shape.len),
        @ptrCast(edge.shape.ptr),
        mlir_t,
        c.mlirAttributeGetNull()
      );
    }

    // c.mlirOperationStateAddOperands(@ptrCast(&op_state), @intCast(operands.len), @ptrCast(operands.ptr));

    const op = c.mlirOperationCreate(@ptrCast(&op_state));
    return op;
  }

  pub fn compileTensorSchedule(self: Self, schedule: std.ArrayList(*const tensor.Node)) !c.MlirModule {
    const loc = c.mlirLocationUnknownGet(self.ctx);
    const mod = c.mlirModuleCreateEmpty(loc);

    for (schedule.items) |node| {
      const mlir_op = try self.tensorToMlir(node);
      _ = mlir_op;
    }

    return mod;
  }
};
