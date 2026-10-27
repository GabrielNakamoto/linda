const std = @import("std");

const Literal = union {
  string: []const u8,
  float: f32,
  int: i32,
};

// module -> <func> <module>?
pub const Module = struct {
  funcs: []Func
};

pub const BlockExpr = union {
  expr: Expr,
  decl: Decl
};
// func -> fn <id> (<arg_list>) <block>
// block -> { <expression_list> }
// expression_list -> <block_expr> ';' <expression_list>?
// block_expr -> <decl> | <expr>
pub const Func = struct {
  id: []const u8,
  params: [][]const u8,
  body: []BlockExpr
};

pub const Expr = union {
  lit: Literal,
  call: CallExpr,
  binop: BinExpr,
  tdecl: TensorDecl,
  yield: YieldExpr
};

// expr -> "yield" <expr>
pub const YieldExpr = struct {
  val: Expr,
};

// expr -> <id> '.' <id> '(' <arg_list> ')'
// arg_list -> <id> ',' <arg_list>?
pub const CallExpr = struct {
  id: []const u8,
  // note expressions cant be evaluated in args
  args: []Literal
};

// expr -> <prim> ('+'|'-'|'*'|'/'|'@') <rhs>
pub const BinExpr = struct {
  lhs: Expr,
  rhs: Expr
};

// expr -> 'T::' <id> '[' <shape> ']'
// shape_list -> <nat> ',' <shape_list>?
pub const TensorDecl = struct {
  dtype: []const u8, // TODO: enum
  shape: []const u32
};

// decl -> <id> '=' <expr>
pub const Decl = struct {
  id: []const u8,
  val: Expr
};


test "test ast" {
  const main = Func {
    .id = "main",
    .body = [_]BlockExpr {
      Decl{ .id = "x", .val = TensorDecl { .dtype = "f32", .shape = .{ 64, 32 } } },
      CallExpr { .id = "sparse_categorical_crossentropy", .args = .{ "x" } },
      YieldExpr { .val = Literal { "x" } }
    }
  };
  const program: Module = .{ .funcs = .{main} };
  std.debug.print("{}\n", .{program});
}
