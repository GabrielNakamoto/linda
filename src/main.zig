const std = @import("std");
const Io = std.Io;
const mlir = @import("mlir");

const linda = @import("linda");
const c = @cImport({
  @cInclude("mlir-c/IR.h");
  @cInclude("linda-c/Dialect.h");
});

fn initDialectOp(name: [*c]const u8, loc: c.MlirLocation) c.MlirOperationState {
  return c.mlirOperationStateGet(c.mlirStringRefCreateFromCString(name), loc);
}

// TODO: custom zig-c interop MlirStringCallback for runtime print string memory allocation
// interface: (MlirStringRef, void* userData) -> ?

pub fn main() !void {
  const ctx = c.mlirContextCreate();
  defer c.mlirContextDestroy(ctx);

  const handle = c.mlirGetDialectHandle__linda__();
  c.mlirDialectHandleRegisterDialect(handle, ctx);
  const dialect = c.mlirDialectHandleLoadDialect(handle, ctx);

  std.debug.print("loaded linda dialect: {}\n", .{
    !c.mlirDialectIsNull(dialect),
  });

  const noloc = c.mlirLocationUnknownGet(ctx);
  const op_state = initDialectOp("linda.add", noloc);
  _ = op_state;

  // const op = c.mlirOperationCreate(&op_state);
  // mlirOperationPrint(op, hjhj);

  std.debug.print("was that life?\n", .{});
}
