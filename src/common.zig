const std = @import("std");

pub fn ListType(comptime T: type) type {
  return struct {
    const Self = @This();

    buffer: std.ArrayList(T) = .empty,
    gpa: std.heap.DebugAllocator(.{}),

    pub fn init() Self { return .{ .gpa = std.heap.DebugAllocator(.{}){} }; }
    pub fn slice(self: *const Self) []const T { return self.buffer.items; }
    pub fn deinit(self: *Self) void { self.buffer.deinit(self.gpa.allocator()); }
    pub fn insert(self: *Self, item: T) std.mem.Allocator.Error!void {
      return self.buffer.append(self.gpa.allocator(), item);
    }
  };
}

pub fn Pair(comptime A: type, comptime B: type) type {
  return struct {
    a: A,
    b: B,

    const Self = @This();

    pub fn init(a: A, b: B) Self { return .{ .a = a, .b = b }; }
  };
}
