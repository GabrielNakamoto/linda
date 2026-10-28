const std = @import("std");
const lexer = @import("lexer.zig");
const ast = @import("ast.zig");
const ListType = @import("common.zig").ListType;

pub const Parser = struct {
  stream: lexer.Lexer,

  pub fn init(stream: lexer.Lexer) Parser { return .{ .stream = stream }; }

  pub fn deinit(self: *Parser) void {
    _ = self;
    // deallocate AST?
    // or is that caller responsibility
  }

  // TODO: return ParseError?
  fn getSymbol(self: *Parser) []const u8 {
    std.debug.assert(self.stream.peek() == .Symbol);
    return self.stream.symbol().?;
  }

  fn expectConsume(self: *Parser, tk: lexer.Lexer.Token) void {
    std.debug.assert(self.stream.peek() == tk);
    self.stream.consume();
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
    const id = self.getSymbol();
    self.stream.consume();
    self.expectConsume(.Assign);
    return ast.Decl.init(id, try self.parseExprOrLit());
  }

  fn parseFunc(self: *Parser) !ast.Func {
    self.stream.consume();
    const id = self.getSymbol();
    var params = ListType([]const u8).init();
    var body = ListType(ast.Expr).init();

    self.expectConsume(.LBrack);
    while(self.stream.peek() != .Eof) : (self.expectConsume(.Comma)) {
      try params.insert(self.getSymbol());
      self.stream.consume();

      if (self.stream.peek() != .Comma) break;
    }
    self.expectConsume(.RBrack);

    self.expectConsume(.LBrace);
    while (self.stream.peek() != .Eof) {
      const sym = self.getSymbol();
      if (std.mem.eql(u8, sym, "yield")) {
        try body.insert(self.parseYieldExpr());
      } else {
        try body.insert(self.parseDecl());
      }
    }
    self.expectConsume(.RBrace);

    return ast.Func.init(id, params, body);
  }

  pub fn parse(self: *Parser) !ast.Module {
    var funcs: ListType(ast.Func) = ListType(ast.Func).init();
    while (self.stream.peek()) |tok| : (self.stream.consume()) {
      if (tok == .Eof) break;
      if (tok == .Comment) continue;

      std.debug.assert(std.mem.eql(u8, self.getSymbol(), "fn"));
      try funcs.insert(self.parseFunc());
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
  const module = parser.parse();
  _ = module;
}
