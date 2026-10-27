const std = @import("std");
const Io = std.Io;

const linda = @import("linda");
const c = @cImport({
  @cInclude("mlir-c/IR.h");
});

pub fn main() !void {
  // testing
  const ctx = c.mlirContextCreate();
  defer c.mlirContextDestroy(ctx);

  std.debug.print("was that life?\n", .{});
}

