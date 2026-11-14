const std = @import("std");
const mlir = @import("mlir.zig");
const tensor = @import("tensor.zig");
const backend = @import("backend.zig");
const Tensor = tensor.Tensor;

// TODO: github actions CI for tests?
pub fn main() !void {
  var gpa = std.heap.DebugAllocator(.{}).init;
  defer _ = gpa.deinit();

  var ctx = tensor.TensorCtx.init(gpa.allocator(), backend.NVPTX, false);
  defer ctx.deinit();

  const a = try Tensor(f32).ones(&ctx, &.{32, 64});
  const b = try Tensor(f32).ones(&ctx, &.{32, 64});

  const c = try a.add(b); // 2.0
  const d = try c.mul(a); // 2.0
  const z = try a.add(c); // 3.0
  const y = try z.mul(d); // 6.0

  const res = try y.exec();
  res.print();
}
