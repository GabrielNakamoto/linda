const std = @import("std");
const mlir = @import("mlir.zig");
const tensor = @import("tensor.zig");

// TODO: custom zig-c interop MlirStringCallback for runtime print string memory allocation
// interface: (MlirStringRef, void* userData) -> ?
// TODO: github actions CI for tests

pub fn main() !void {
  var gpa = std.heap.DebugAllocator(.{}).init;
  defer _ = gpa.deinit();

  var tctx = tensor.TensorCtx.init(gpa.allocator());
  defer tctx.deinit();

  const a = try tensor.Tensor(f32).ones(&tctx, &.{64, 128});
  const b = try tensor.Tensor(f32).ones(&tctx, &.{64, 128});
  const c = try a.add(b);
  // c.print();

  try c.compile();

  std.debug.print("was that life?\n", .{});
}
