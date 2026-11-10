const std = @import("std");
const mlir = @import("mlir.zig");
const tensor = @import("tensor.zig");
const Tensor = tensor.Tensor;

// TODO: github actions CI for tests?
pub fn main() !void {
  var gpa = std.heap.DebugAllocator(.{}).init;
  defer _ = gpa.deinit();

  var ctx = tensor.TensorCtx.init(gpa.allocator());
  defer ctx.deinit();

  const a = try Tensor(f32).ones(&ctx, &.{32, 64});
  const b = try Tensor(f32).ones(&ctx, &.{32, 64});

  const c = try a.add(b);
  const d = try c.mul(a);
  const z = try a.add(c);
  const y = try z.mul(d);
  const x = try y.reshape(&.{128, 16});

  try x.compile();
}
