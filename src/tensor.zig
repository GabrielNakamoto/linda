const std = @import("std");
const mlir = @import("mlir");

pub const IROp = enum {
  Ecce,
  Add,
  Mul,
  Reshape,
  Transpose,
  Dot,
};

pub const TensorCtx = struct {
  arena: std.heap.ArenaAllocator,

  pub fn init(backing: std.mem.Allocator) TensorCtx {
    return .{ .arena = std.heap.ArenaAllocator.init(backing) };
  }

  pub fn deinit(self: *TensorCtx) void { self.arena.deinit(); }
};

fn numel(shape: []const u32) u32 {
  var n: u32 = 1;
  for (shape) |dim| n *= dim;
  return n;
}

pub const AnyTensor = union(enum) {
  float32: Tensor(f32),
  uint: Tensor(u32),
  sint: Tensor(i32)
};

pub fn Tensor(comptime T: type) type {
  return struct {
    const Self = @This();
    op: IROp,
    shape: []const u32,
    ctx: *TensorCtx,
    inputs: []const *const Tensor(T) = &.{},
    data: ?[]const u8 = null,

    pub fn print(self: Self) void {
      const head = if (self.data) |buf| buf[0..@min(20, buf.len)] else null;
      std.debug.print("Tensor[{s}], dtype={}, shape={any}, head={any}, inputs={d}\n",
        .{@tagName(self.op), T, self.shape, head, self.inputs.len});
    }

    pub fn ones(ctx: *TensorCtx, comptime shape: []const u32) !Self {
      const data = try ctx.arena.allocator().alloc(T, numel(shape));
      @memset(data, 1.0);

      return .{ .op = IROp.Ecce, .shape = shape, .data = std.mem.sliceAsBytes(data), .ctx = ctx, };
    }

    fn unop(self: Self, op: IROp, comptime new_shape: ?[]const u32) !Self {
      var inputs = try self.ctx.arena.allocator().alloc(*const Tensor(T), 1);
      inputs[0] = &self;
      return .{ .op = op, .shape = new_shape orelse self.shape, .ctx = self.ctx, .inputs = inputs };
    }

    fn binop(self: Self, other: Self, op: IROp, broadcast: bool) !Self {
      _ = broadcast;
      // no broadcasting to start, assert same
      std.debug.assert(self.shape.len == other.shape.len);
      for (self.shape, other.shape) |a,b| std.debug.assert(a == b);

      const inputs = try self.ctx.arena.allocator().alloc(*const Tensor(T), 2);
      inputs[0] = &self; inputs[1] = &other;

      return .{ .op = op, .shape = self.shape, .ctx = self.ctx, .inputs = inputs };
    }

    pub fn reshape(self: Self, comptime shape: []const u32) !Self { return try self.unop(IROp.Reshape, shape); }
    pub fn add(self: Self, other: Self) !Self { return try self.binop(other, IROp.Add, true); }
    pub fn mul(self: Self, other: Self) !Self { return try self.binop(other, IROp.Mul, true); }

    //pub fn compile(self: Self) !void {
      // do codegen, do we need another class/file for this prolly?
      // what does this return?
    //}
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
  const x = try d.reshape(&.{128, 16});

  x.print();
}
