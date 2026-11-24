const std = @import("std");

const Runtime = opaque {};

extern fn mlrb_runtime_create() ?*Runtime;
extern fn mlrb_runtime_destroy() void;

pub const MetalRuntime = struct {
  const Self = @This();
  handle: *Runtime

  pub fn deinit(self: Self) void {
    mlrb_runtime_destroy(self.handle);
  }

  pub fn init() !Self {
    return .{
      .runtime = mlrb_runtime_create() orelse return error.MetalRuntimeInitFailed;
    }
  }

  pub fn exec(self: Self, gpa: std.mem.Allocator, metallib: []const u8) !void {
  }
}
