const std = @import("std");
const tensor = @import("tensor.zig");
const c = @import("capi.zig").imports;

// Generic
pub fn numel(shape: []const u64) u64 {
  var n: u64 = 1;
  for (shape) |dim| n *= dim;
  return n;
}

// ****** MLIR Wrappers and Conversion *******
pub fn mlirAssertGood(result: c.MlirLogicalResult) void {
  std.debug.assert(result.value != 0);
  // std.debug.assert(c.mlirLogicalResultIsSuccess(result));
}

pub fn dtypeToMlirType(ctx: c.MlirContext, dtype: tensor.DType) !c.MlirType {
  return switch (dtype) {
    .f32 => c.mlirF32TypeGet(ctx),
    .u32 => c.mlirIntegerTypeUnsignedGet(ctx, 32),
    .i32 => c.mlirIntegerTypeSignedGet(ctx, 32)
  };
}

pub fn stringRef(str: []const u8) c.MlirStringRef {
  return c.mlirStringRefCreateFromCString(@ptrCast(str));
}

pub fn getNamedAttribute(ctx: c.MlirContext, name: []const u8, attr: c.MlirAttribute) c.MlirNamedAttribute {
  return c.mlirNamedAttributeGet(c.mlirIdentifierGet(ctx, stringRef(name)), attr);
}

pub fn createMlirOp(loc: c.MlirLocation, name: []const u8, operands: ?[]const c.MlirValue, result_t: ?*const c.MlirType,
  attributes: ?[]const c.MlirNamedAttribute, regions: ?[]const c.MlirRegion) c.MlirOperation {
  var op_state = c.mlirOperationStateGet(stringRef(name), loc);
  if (operands) |ops| c.mlirOperationStateAddOperands(@ptrCast(&op_state), @intCast(ops.len), @ptrCast(ops.ptr));
  if (result_t) |tp| c.mlirOperationStateAddResults(@ptrCast(&op_state), 1, @ptrCast(tp));
  if (attributes) |attr| c.mlirOperationStateAddAttributes(@ptrCast(&op_state), @intCast(attr.len), @ptrCast(attr.ptr));
  if (regions) |rs| c.mlirOperationStateAddOwnedRegions(@ptrCast(&op_state), @intCast(rs.len), @ptrCast(rs.ptr));
  return c.mlirOperationCreate(@ptrCast(&op_state));
}

pub fn tensorToMlirType(gpa: std.mem.Allocator, ctx: c.MlirContext, shape: []const u64, dtype: tensor.DType) !*const c.MlirType {
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
pub fn dialectRegisters(comptime dialects: []const []const u8) type {
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

pub fn pipelineDiagnostic(msg: c.MlirStringRef, _:?*anyopaque) callconv(.c) void {
  std.debug.print("pass pipeline error: {s}", .{msg.data[0..msg.length]});
}

