const std = @import("std");

fn ListType(comptime T: type) type {
  return struct {
    const Self = @This();

    buffer: std.ArrayList(T) = .empty,
    gpa: std.heap.DebugAllocator(.{}),

    pub fn init() Self { return .{ .gpa = std.heap.DebugAllocator(.{}){} }; }
    pub fn slice(self: *const Self) []const T { return self.buffer.items; }
    pub fn insert(self: *Self, item: T) std.mem.Allocator.Error!void {
      return self.buffer.append(self.gpa.allocator(), item);
    }
    pub fn deinit(self: *Self) void {
      self.buffer.deinit(self.gpa.allocator());
    }
  };
}

pub const Literal = union(enum) { string: []const u8, float: f32, int: i32, };
pub const ExprOrLit = union(enum) { expr: *const Expr, lit: Literal };

// module -> <func> <module>?
pub const Module = struct {
  funcs: ListType(Func),

  pub fn init(funcs: ListType(Func)) Module {
    return .{.funcs = funcs};
  }
};

// block_expr -> <decl> | <expr>
pub const BlockExpr = union(enum) {
  expr: *const Expr,
  decl: Decl
};

// func -> fn <id> (<arg_list>) <block>
// block -> { <expression_list> }
// expression_list -> <block_expr> ';' <expression_list>?
pub const Func = struct {
  id: []const u8,
  params: ListType([]const u8),
  body: ListType(BlockExpr),

  pub fn init(id: []const u8, params: ListType([]const u8), body: ListType(BlockExpr)) Func {
    return .{ .id = id, .params = params, .body = body };
  }
};

pub const Expr = union(enum) {
  call: CallExpr,
  binop: BinExpr,
  tdecl: TensorDecl,
  yield: YieldExpr
};

// expr -> "yield" <expr>
pub const YieldExpr = struct {
  val: ExprOrLit,

  pub fn init(val: ExprOrLit) Expr {
    return Expr{ .yield = .{.val = val}};
  }
};

// expr -> <id> '.' <id> '(' <arg_list> ')'
// arg_list -> <id> ',' <arg_list>?
pub const CallExpr = struct {
  id: []const u8,
  // note expressions cant be evaluated in args
  args: ListType(Literal),

  pub fn init(id: []const u8, args: ListType(Literal)) Expr {
    return Expr { .call = .{ .id = id, .args = args } };
  }
};

// expr -> <prim> ('+'|'-'|'*'|'/'|'@') <rhs>
// how to describe this?
pub const BinExpr = struct {
  lhs: ExprOrLit,
  rhs: ExprOrLit
};

// expr -> 'T::' <id> '[' <shape> ']'
// shape_list -> <nat> ',' <shape_list>?
pub const TensorDecl = struct {
  dtype: []const u8, // TODO: enum
  shape: ListType(u32),

  pub fn init(dtype: []const u8, shape: ListType(u32)) Expr {
    return Expr { .tdecl = .{.dtype = dtype, .shape = shape}};
  }
};

// decl -> <id> '=' <expr>
pub const Decl = struct {
  id: []const u8,
  val: ExprOrLit,

  pub fn init(id: []const u8, val: ExprOrLit) Decl {
    return .{ .id = id, .val = val};
  }
};

test "test ast" {
  var shape = ListType(u32).init();
  defer shape.deinit();
  try shape.insert(64);
  try shape.insert(32);

  var args = ListType(Literal).init();
  defer args.deinit();
  try args.insert(Literal{.string = "x"});

  const tdecl = TensorDecl.init("f32", shape);
  const decl = Decl.init("x", .{ .expr = &tdecl});
  const call = CallExpr.init("sparse_categorical_crossentropy", args);
  const yield = YieldExpr.init(.{ .lit = Literal { .string = "x" }});

  var body = ListType(BlockExpr).init();
  defer body.deinit();
  try body.insert(.{ .decl = decl });
  try body.insert(.{ .expr = &call});
  try body.insert(.{ .expr = &yield});

  const main = Func.init("main", ListType([]const u8).init(), body);
  std.debug.print("{}\n", .{body.slice()[0]});

  var funcs = ListType(Func).init();
  defer funcs.deinit();
  try funcs.insert(main);
  const program = Module.init(funcs);
  _ = program;
}
