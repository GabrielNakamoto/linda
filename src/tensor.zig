const std = @import("std");
const mlir = @import("mlir.zig");

pub const IROp = enum {
  Create,
  Add, Mul,
  Reshape, Transpose,
  Dot,
};

pub const DType = enum { f32, u32, i32 };

pub fn dtypeOf(comptime T: type) DType {
  return switch(T) {
    f32 => .f32,
    u32 => .u32,
    i32 => .i32,
    else => @compileError("unsupported tensor dtype: " ++ @typeName(T))
  };
}

pub const TensorCtx = struct {
  arena: std.heap.ArenaAllocator,
  compile_arena: std.heap.ArenaAllocator,

  pub fn init(backing: std.mem.Allocator) TensorCtx {
    return .{
      .arena = .init(backing),
      .compile_arena = .init(backing)
    };
  }

  pub fn deinit(self: *TensorCtx) void { self.arena.deinit(); }
};

pub const Node = struct {
  op: IROp,
  shape: []const u64,
  dtype: DType,
  inputs: []const *const Node = &.{},
  data: ?[]const u8 = null,

  pub fn print(self: Node) void {
    const head = if (self.data) |buf| buf[0..@min(20, buf.len)] else null;
    std.debug.print("Tensor[{s}], dtype={any}, shape={any}, head={any}, inputs={d}\n",
      .{@tagName(self.op), self.dtype, self.shape, head, self.inputs.len});
  }

  fn topovisit(self: *const Node, gpa: std.mem.Allocator, visited: *std.AutoHashMap(*const Node, void), schedule: *std.ArrayList(*const Node)) !void {
    if (visited.contains(self)) return;

    for (self.inputs) |edge| {
      try edge.topovisit(gpa, visited, schedule);
    }

    try visited.put(self, {});
    try schedule.append(gpa, self);
  }
};

fn numel(shape: []const u64) u64 {
  var n: u64 = 1;
  for (shape) |dim| n *= dim;
  return n;
}

pub fn Tensor(comptime T: type) type {
  _ = dtypeOf(T);

  return struct {
    const Self = @This();
    node: *const Node,
    ctx: *TensorCtx,

    fn shape(self: Self) []const u64 { return self.node.shape; }

    pub fn ones(ctx: *TensorCtx, comptime new_shape: []const u64) !Self {
      const data = try ctx.arena.allocator().alloc(T, numel(new_shape));
      @memset(data, 1.0);

      const node = try ctx.arena.allocator().create(Node);
      node.* = .{ .op = IROp.Create, .shape = new_shape, .data = std.mem.sliceAsBytes(data), .dtype = dtypeOf(T) };
      return .{ .node = node, .ctx = ctx };
    }

    fn unop(self: Self, op: IROp, comptime new_shape: ?[]const u64) !Self {
      var inputs = try self.ctx.arena.allocator().alloc(*const Node, 1);
      inputs[0] = self.node;
      const node = try self.ctx.arena.allocator().create(Node);
      node.* = .{ .op = op, .shape = new_shape orelse self.node.shape, .inputs = inputs, .dtype = self.node.dtype };
      return .{ .node = node, .ctx = self.ctx };
    }

    fn binop(self: Self, other: Self, op: IROp, broadcast: bool) !Self {
      const left = self.node;
      const right = other.node;
      _ = broadcast;
      // no broadcasting to start, assert same
      std.debug.assert(left.shape.len == right.shape.len);
      std.debug.assert(left.dtype == right.dtype);
      for (left.shape, right.shape) |a,b| std.debug.assert(a == b);

      const inputs = try self.ctx.arena.allocator().alloc(*const Node, 2);
      inputs[0] = left; inputs[1] = right;

      const node = try self.ctx.arena.allocator().create(Node);
      node.* = .{ .op = op, .shape = left.shape, .inputs = inputs, .dtype = left.dtype };
      return .{ .node = node, .ctx = self.ctx };
    }

    pub fn reshape(self: *const Self, comptime new_shape: []const u64) !Self { return try self.unop(IROp.Reshape, new_shape); }
    pub fn add(self: Self, other: Self) !Self { return try self.binop(other, IROp.Add, true); }
    pub fn mul(self: Self, other: Self) !Self { return try self.binop(other, IROp.Mul, true); }

    pub fn compile(self: *const Self) !void {
      defer self.ctx.compile_arena.deinit();

      var tensor_schedule: std.ArrayList(*const Node) = .empty;
      var visited: std.AutoHashMap(*const Node, void) = .init(self.ctx.compile_arena.allocator());
      try self.node.topovisit(self.ctx.compile_arena.allocator(), &visited, &tensor_schedule);
      // free dict here?, cant: its part of arena

      var mlir_gen = mlir.MLIRGenerator.init(self.ctx.compile_arena.allocator());
      defer mlir_gen.deinit();

      const mod = try mlir_gen.compileTensorSchedule(tensor_schedule);
      _ = mod;
    }
  };
}

test "test tensor" {
  var gpa = std.heap.DebugAllocator(.{}).init;
  defer _ = gpa.deinit();

  var ctx = TensorCtx.init(gpa.allocator());
  defer ctx.deinit();

  const a = try Tensor(f32).ones(&ctx, &.{32, 64});
  const b = try Tensor(f32).ones(&ctx, &.{32, 64});

  const c = try a.add(b);
  const d = try c.mul(a);
  const z = try a.add(c);
  const y = try z.mul(d);
  const x = try y.reshape(&.{128, 16});

  // x.print();

  try x.compile();
}
