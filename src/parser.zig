const std = @import("std");
const lexer = @import("lexer.zig");
const ast = @import("ast.zig");
const ListType = @import("common.zig").ListType;

pub const Parser = struct {
  stream: lexer.Lexer,

  pub fn init(stream: lexer.Lexer) Parser { return .{ .stream = stream }; }

  // TODO: return ParseError?
  fn getSymbol(self: *Parser) ![]const u8 {
    const next = try self.stream.peek(0);
    std.debug.assert(next.a == .Symbol and next.b != null);
    self.stream.step();
    switch (next.b.?) {
      .string => |val| return val,
      else => return error.ParseError,
    }
  }

  fn expectStep(self: *Parser, kind: lexer.Lexer.TokenKind) !void {
    const next = try self.stream.peek(0);
    if (next.a != kind) return error.ParseError;
    self.stream.step();
  }

  fn parseYieldExpr(self: *Parser) ast.Expr {
    _ = self;
  }

  fn parseExpr(self: *Parser) !ast.Expr {
    _ = self;
    // cases:
    // - call
    // - yield
    // - binop
    // - tensor decl
  }

  fn parseExprOrLit(self: *Parser) !ast.ExprOrLit {
    _ = self;
    // how to identify binary expression without peeking ahead 2?
  }

  fn parseDecl(self: *Parser) !ast.Decl {
    const id = try self.getSymbol();
    self.stream.step();
    try self.expectStep(.Assign);
    return ast.Decl.init(id, try self.parseExprOrLit());
  }

  fn parseFunc(self: *Parser) !ast.Func {
    self.stream.step();
    const id = try self.getSymbol();
    var params = ListType([]const u8).init();
    var body = ListType(ast.Expr).init();

    std.debug.print("parse func: {s}\n", .{id});

    try self.expectStep(.LBrack);
    var tok = try self.stream.peek(0);
    while(tok.a != .Eof) : (tok = try self.stream.peek(0)) {
      try params.insert(try self.getSymbol());

      const next = try self.stream.peek(0);
      if (next.a != .Comma) break;
      self.stream.step();
    }
    try self.expectStep(.RBrack);

    try self.expectStep(.LBrace);
    tok = try self.stream.peek(0);
    while (tok.a != .Eof) : (tok = try self.stream.peek(0)) {
      const sym = try self.getSymbol();
      if (std.mem.eql(u8, sym, "yield")) {
        try body.insert(self.parseYieldExpr());
      } else {
        try body.insert(self.parseDecl());
      }
    }
    try self.expectStep(.RBrace);

    return ast.Func.init(id, params, body);
  }

  pub fn parse(self: *Parser) !ast.Module {
    try self.stream.tokenize(true);
    defer self.stream.deinit();

    var funcs: ListType(ast.Func) = ListType(ast.Func).init();
    var tok = try self.stream.peek(0);
    while (tok.a != .Eof) : (self.stream.step()) {
      if (tok.a == .Comment) continue;

      std.debug.assert(std.mem.eql(u8, try self.getSymbol(), "fn"));
      const func = try self.parseFunc();
      try funcs.insert(func);
      tok = try self.stream.peek(0);
    }
    return ast.Module.init(funcs);
  }
};


test "test parse simple program" {
  const io = std.testing.io;
  const gpa = std.testing.allocator;
  const dir = std.Io.Dir.cwd();

  const buf = try dir.readFileAlloc(io, "examples/simple.lda", gpa, .unlimited);
  defer gpa.free(buf);

  std.debug.print("src program: (s)\n", .{buf});
  var parser = Parser.init(lexer.Lexer.init(buf));
  const module = try parser.parse();
  _ = module;
}
