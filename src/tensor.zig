const std = @import("std");
const mlir = @import("mlir.zig");
const backend = @import("backend.zig");
const cuda = @import("cudaz");
const runtime = @import("runtime.zig");
const helpers = @import("helpers.zig");

pub const IROp = enum {
  Buffer,
  Add, Mul,
  Sqrt,
  Reshape
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
  targetArch: backend.Accelerator,
  arena: std.heap.ArenaAllocator,
  compile_arena: std.heap.ArenaAllocator,
  debug: bool,

  pub fn init(backing: std.mem.Allocator, arch: backend.Accelerator, debug: bool) TensorCtx {
    return .{
      .arena = .init(backing),
      .compile_arena = .init(backing),
      .debug = debug,
      .targetArch = arch
    };
  }

  pub fn deinit(self: *TensorCtx) void {
    self.arena.deinit();
    std.debug.print("Was that life? Well then! Once more!\n", .{});
  }
};

pub const Node = struct {
  op: IROp,
  shape: []const u64,
  dtype: DType,
  inputs: []const *const Node = &.{},
  data: ?[]const u8 = null,

  pub fn print(self: Node, comptime T: type) void {
    const data = if (self.data) |bytes| std.mem.bytesAsSlice(T, bytes) else null;
    std.debug.print("Tensor[{s}], dtype={any}, shape={any}, num_inputs={d}\n{any}",
      .{@tagName(self.op), self.dtype, self.shape, self.inputs.len, data});
  }

  pub fn numel(self: Node) u64 { return helpers.numel(self.shape); }

  fn topovisit(self: *const Node, gpa: std.mem.Allocator,
    visited: *std.AutoHashMap(*const Node, void), schedule: *std.ArrayList(*const Node)) !void {
    if (visited.contains(self)) return;

    // we can additionally perform spec verification here, we see every op
    if (self.op == .Buffer) {
      std.debug.assert(self.data != null);
    }

    for (self.inputs) |edge| {
      try edge.topovisit(gpa, visited, schedule);
    }

    try visited.put(self, {});
    try schedule.append(gpa, self);
  }
};

pub fn Tensor(comptime T: type) type {
  _ = dtypeOf(T);

  return struct {
    const Self = @This();
    node: *const Node,
    ctx: *TensorCtx,

    fn shape(self: Self) []const u64 { return self.node.shape; }
    pub fn print(self: Self) void { self.node.print(T); }

    pub fn ones(ctx: *TensorCtx, comptime new_shape: []const u64) !Self {
      const data = try ctx.arena.allocator().alloc(T, helpers.numel(new_shape));
      for (data) |*x| x.* = 1.0;

      const node = try ctx.arena.allocator().create(Node);
      node.* = .{ .op = IROp.Buffer, .shape = new_shape, .data = std.mem.sliceAsBytes(data), .dtype = dtypeOf(T) };
      return .{ .node = node, .ctx = ctx };
    }

    fn unop(self: Self, op: IROp, comptime new_shape: ?[]const u64) !Self {
      var inputs = try self.ctx.arena.allocator().alloc(*const Node, 1);
      inputs[0] = self.node;
      const node = try self.ctx.arena.allocator().create(Node);
      node.* = .{ .op = op, .shape = new_shape orelse self.node.shape, .inputs = inputs, .dtype = self.node.dtype };
      return .{ .node = node, .ctx = self.ctx };
    }

    // TODO: scalar bin exprs?, multiple builders in custom Dialect/Op cpp
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

    pub fn add(self: Self, other: Self) !Self { return try self.binop(other, IROp.Add, true); }
    pub fn mul(self: Self, other: Self) !Self { return try self.binop(other, IROp.Mul, true); }

    pub fn reshape(self: *const Self, comptime new_shape: []const u64) !Self { return try self.unop(IROp.Reshape, new_shape); }
    pub fn sqrt(self: Self) !Self { return try self.unop(IROp.Sqrt, null); }

    pub fn exec(self: *const Self) !Self {
      defer self.ctx.compile_arena.deinit();

      var tensor_schedule: std.ArrayList(*const Node) = .empty;
      var visited: std.AutoHashMap(*const Node, void) = .init(self.ctx.compile_arena.allocator());
      try self.node.topovisit(self.ctx.compile_arena.allocator(), &visited, &tensor_schedule);

      var mlir_gen = mlir.MLIRGenerator.init(self.ctx.compile_arena.allocator(), self.ctx.debug);
      defer mlir_gen.deinit();

      const mlirModule = try mlir_gen.compileTensorSchedule(tensor_schedule);
      const ptx = try backend.compileKernelModule(mlir_gen.ctx, mlirModule, self.ctx.targetArch, self.ctx.debug);

      const hostResult = try runtime.launchCUDAKernel(T, self.ctx.compile_arena.allocator(), ptx, tensor_schedule);

      const new_node = try self.ctx.arena.allocator().create(Node);
      new_node.* = self.node.*;
      new_node.*.data = std.mem.sliceAsBytes(hostResult);
      return .{ .node = new_node, .ctx = self.ctx };
    }
  };
}
