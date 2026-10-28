const std = @import("std");
const common = @import("common.zig");

// lex entire input buffer in single pass, caching the tokens so its easy
// to arbitrarily look ahead in stream and increment ptr
pub const Lexer  = struct {
  buffer: []const u8,
  tokens: common.ListType(Token),
  next: usize = 0,

  pub const LexerError = error{
    UnexpectedEof,
    SyntaxError
  };

  pub const TokenKind = enum {
    LBrace, RBrace,
    LBrack, RBrack,
    LSbrack, RSbrack,
    Add, Mul, Sub, Div, Mmul,
    Tensor, Assign,
    Literal, Symbol,
    Comma, Call,
    Comment, Endl, Eof,

    pub fn simple(char: u8) ?TokenKind {
      return switch (char) {
        '(' => .LBrack, ')' => .RBrack,
        '{' => .LBrace, '}' => .RBrace,
        '[' => .LSbrack, ']' => .RSbrack,
        ';' => .Endl,
        '+' => .Add, '-' => .Sub,
        '/' => .Div, '*' => .Mul,
        '@' => .Mmul, ',' => .Comma,
        '.' => .Call, '=' => .Assign,
        else => null
      };
    }
  };

  pub const Token = common.Pair(TokenKind, ?Literal);

  pub const Literal = union(enum) { int: i32, float: f32, string: []const u8 };

  pub fn init(buffer: []const u8) Lexer {
    return Lexer{ .buffer = buffer, .tokens = common.ListType(Token).init() };
  }

  pub fn deinit(self: *Lexer) void {
    self.tokens.deinit();
  }

  pub fn consume(self: *Lexer) void {
    std.debug.assert(self.next + 1 < self.tokens.slice().len);
    self.next += 1;
  }

  pub fn peek(self: *Lexer, i: u32) ?Token {
    std.debug.assert(self.next + i < self.tokens.slice().len);
    return self.tokens.slice()[self.next + i];
  }

  fn readSymbol(self: *Lexer) Literal {
    const start: usize = self.next;
    while (std.ascii.isAlphanumeric(self.buffer[self.next])) : (self.next += 1) {}
    return .{ .string = self.buffer[start..self.next]};
  }

  fn readLiteral(self: *Lexer) ?Literal {
    var is_float = false;
    const start = self.next;
    while (std.ascii.isDigit(self.buffer[self.next]) or self.buffer[self.next] == '.') : (self.next += 1) {
      if (self.buffer[self.next] == '.') is_float = true;
    }

    if (is_float) {
      return .{ .float = std.fmt.parseFloat(f32, self.buffer[start..self.next]) catch return null };
    } else {
      return .{ .int = std.fmt.parseInt(i32, self.buffer[start..self.next], 10) catch return null };
    }
  }

  fn complex_tok(self: *Lexer) ?Token {
    return switch (self.buffer[self.next]) {
      '#' => blk: {
        while (self.next < self.buffer.len and self.buffer[self.next] != '\n') : (self.next += 1) {}
        break :blk Token.init(.Comment, null);
      },
      ':' => blk: {
        std.debug.assert(self.buffer.len > self.next+1 and self.buffer[self.next+1] == ':');
        self.next += 2;
        break :blk Token.init(.Tensor, null);
      },
      'a'...'z', 'A'...'Z' => Token.init(.Symbol, self.readSymbol()),
      '0'...'9' => Token.init(.Literal, self.readLiteral()),
      else => null
    };
  }

  pub fn tokenize(self: *Lexer, ignore_comments: bool) !void {
    while (self.next < self.buffer.len) {
      while (self.next < self.buffer.len and std.ascii.isWhitespace(self.buffer[self.next])) : (self.next += 1) {}
      if (self.next == self.buffer.len) break;

      if (TokenKind.simple(self.buffer[self.next])) |kind| {
        try self.tokens.insert(Token.init(kind, null));
        self.next += 1;
      } else if (self.complex_tok()) |tok| {
        if (!ignore_comments or tok.a != .Comment) {
          try self.tokens.insert(tok);
        }
      } else {
        std.debug.print("Syntax error while tokenizing src: {c}\n", .{self.buffer[self.next]});
        return LexerError.SyntaxError;
      }
    }
    try self.tokens.insert(Token.init(.Eof, null));
    self.next = 0;
  }
};

// ****** Testing Code *****
test "test lex simple program" {
  const io = std.testing.io;
  const gpa = std.testing.allocator;
  const dir = std.Io.Dir.cwd();

  const buf = try dir.readFileAlloc(io, "examples/simple.lda", gpa, .unlimited);
  defer gpa.free(buf);

  std.debug.print("Source program: {s}\n", .{buf});

  const Token = Lexer.Token;
  const expected_tokens = [_] Token {
    Token.init(.Symbol, .{ .string = "fn" }), Token.init(.Symbol, .{ .string = "attn" }), Token.init(.LBrack, null), Token.init(.Symbol, .{ .string = "x" }),
    Token.init(.Comma, null), Token.init(.Symbol, .{ .string = "q" }), Token.init(.Comma, null), Token.init(.Symbol, .{ .string = "v" }),
    Token.init(.RBrack, null), Token.init(.LBrace, null),
    Token.init(.Symbol, .{ .string = "if" }), Token.init(.LBrack, null), Token.init(.Symbol, .{ .string = "foo" }), Token.init(.RBrack, null),
    Token.init(.Symbol, .{ .string = "foo" }), Token.init(.Assign, null), Token.init(.LBrack, null), Token.init(.Symbol, .{ .string = "q" }),
    Token.init(.Mmul, null), Token.init(.Symbol, .{ .string = "v" }), Token.init(.RBrack, null), Token.init(.Call, null),
    Token.init(.Symbol, .{ .string = "T" }), Token.init(.LBrack, null), Token.init(.RBrack, null), Token.init(.Endl, null),
    Token.init(.Comment, null),
    Token.init(.Symbol, .{ .string = "z" }), Token.init(.Assign, null), Token.init(.Symbol, .{ .string = "foo" }), Token.init(.Div, null),
    Token.init(.LBrack, null), Token.init(.Symbol, .{ .string = "v" }), Token.init(.Call, null), Token.init(.Symbol, .{ .string = "exp" }),
    Token.init(.LBrack, null), Token.init(.RBrack, null), Token.init(.Add, null), Token.init(.Symbol, .{ .string = "q" }),
    Token.init(.Call, null), Token.init(.Symbol, .{ .string = "sqrt" }), Token.init(.LBrack, null), Token.init(.RBrack, null),
    Token.init(.RBrack, null), Token.init(.Endl, null),
    Token.init(.RBrace, null), Token.init(.Symbol, .{ .string = "fi" }), Token.init(.LBrace, null),
    Token.init(.Symbol, .{ .string = "yield" }), Token.init(.Symbol, .{ .string = "x" }), Token.init(.Add, null), Token.init(.Literal, .{ .float = 27.0 }),
    Token.init(.Endl, null),
    Token.init(.RBrace, null),
    Token.init(.Symbol, .{ .string = "yield" }), Token.init(.LBrack, null), Token.init(.Symbol, .{ .string = "z" }), Token.init(.Mul, null),
    Token.init(.LBrack, null), Token.init(.Symbol, .{ .string = "q" }), Token.init(.Sub, null), Token.init(.Literal, .{ .int = 3 }),
    Token.init(.RBrack, null), Token.init(.RBrack, null), Token.init(.Call, null), Token.init(.Symbol, .{ .string = "R" }),
    Token.init(.LBrack, null), Token.init(.Literal, .{ .int = 64 }), Token.init(.Comma, null), Token.init(.Literal, .{ .int = 32 }),
    Token.init(.RBrack, null), Token.init(.Endl, null), Token.init(.Comment, null),
    Token.init(.RBrace, null),
    Token.init(.Symbol, .{ .string = "fn" }), Token.init(.Symbol, .{ .string = "main" }), Token.init(.LBrace, null),
    Token.init(.Symbol, .{ .string = "x" }), Token.init(.Assign, null), Token.init(.Symbol, .{ .string = "T" }), Token.init(.Tensor, null),
    Token.init(.Symbol, .{ .string = "i32" }), Token.init(.LSbrack, null), Token.init(.Literal, .{ .int = 64 }), Token.init(.Comma, null),
    Token.init(.Literal, .{ .int = 128 }), Token.init(.RSbrack, null), Token.init(.Endl, null),
    Token.init(.Symbol, .{ .string = "y" }), Token.init(.Assign, null), Token.init(.Symbol, .{ .string = "T" }), Token.init(.Tensor, null),
    Token.init(.Symbol, .{ .string = "f32" }), Token.init(.LSbrack, null), Token.init(.Literal, .{ .int = 128 }), Token.init(.Comma, null),
    Token.init(.Literal, .{ .int = 256 }), Token.init(.RSbrack, null), Token.init(.Endl, null),
    Token.init(.Symbol, .{ .string = "z" }), Token.init(.Assign, null), Token.init(.Symbol, .{ .string = "T" }), Token.init(.Tensor, null),
    Token.init(.Symbol, .{ .string = "f8" }), Token.init(.LSbrack, null), Token.init(.Literal, .{ .int = 10 }), Token.init(.Comma, null),
    Token.init(.Literal, .{ .int = 20000 }), Token.init(.Comma, null), Token.init(.Literal, .{ .int = 39 }), Token.init(.Comma, null),
    Token.init(.Literal, .{ .int = 4 }), Token.init(.RSbrack, null), Token.init(.Endl, null),
    Token.init(.Symbol, .{ .string = "foo" }), Token.init(.Assign, null), Token.init(.Symbol, .{ .string = "x" }), Token.init(.Mmul, null),
    Token.init(.Symbol, .{ .string = "y" }), Token.init(.Endl, null), Token.init(.Comment, null),
    Token.init(.Symbol, .{ .string = "z" }), Token.init(.Assign, null), Token.init(.Symbol, .{ .string = "attn" }), Token.init(.LBrack, null),
    Token.init(.Symbol, .{ .string = "x" }), Token.init(.Comma, null), Token.init(.Symbol, .{ .string = "y" }), Token.init(.RBrack, null),
    Token.init(.Call, null), Token.init(.Symbol, .{ .string = "relu" }), Token.init(.LBrack, null), Token.init(.RBrack, null),
    Token.init(.Endl, null),
    Token.init(.Symbol, .{ .string = "z" }), Token.init(.Call, null), Token.init(.Symbol, .{ .string = "print" }), Token.init(.LBrack, null),
    Token.init(.RBrack, null), Token.init(.Endl, null),
    Token.init(.RBrace, null),
    Token.init(.Eof, null),
  };

  var lexer = Lexer.init(buf);
  defer lexer.deinit();
  try lexer.tokenize(false);

  for (expected_tokens, 0..) |valid, i| {
    const tok = lexer.peek(0) orelse return error.TestExpectedEqual;

    std.debug.print("[{d}]: {s}\t", .{i, @tagName(tok.a)});
    if (tok.b) |lit| {
      switch (lit) {
        .string => |val| std.debug.print("{s}", .{val}),
        .int => |val| std.debug.print("{}", .{val}),
        .float => |val| std.debug.print("{}", .{val}),
      }
    }
    std.debug.print("\n", .{});

    try expectTokenEqual(valid, tok);

    if (tok.a == .Eof) break;
    lexer.consume();
  }
}

fn expectTokenEqual(expected: Lexer.Token, actual: Lexer.Token) !void {
  try std.testing.expectEqual(expected.a, actual.a);

  if (expected.b) |expected_lit| {
    const actual_lit = actual.b orelse return error.TestExpectedEqual;
    try std.testing.expectEqual(std.meta.activeTag(expected_lit), std.meta.activeTag(actual_lit));
    switch (actual_lit) {
      .string => |sym| try std.testing.expectEqualStrings(expected_lit.string, sym),
      else => try std.testing.expectEqual(expected_lit, actual_lit),
    }
  } else {
    try std.testing.expect(actual.b == null);
  }
}
