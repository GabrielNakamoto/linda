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


  pub const Literal = union(enum) {
    int: i32, float: f32, string: []const u8,

    pub fn print(self: Literal) void {
      switch(self) {
        .int => |val| std.debug.print("int literal: {}\n", .{val}),
        .float => |val| std.debug.print("float literal: {}\n", .{val}),
        .string => |val| std.debug.print("string literal: {s}\n", .{val}),
      }
    }
  };

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
        std.debug.print("got token: {s}\n", .{@tagName(kind)});
        try self.tokens.insert(Token.init(kind, null));
        self.next += 1;
      } else if (self.complex_tok()) |tok| {
        if (!ignore_comments or tok.a != .Comment) {
          std.debug.print("got token: {s}\n", .{@tagName(tok.a)});
          if (tok.b) |lit| {
            lit.print();
          }
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

  std.debug.print("src program: {s}\n", .{buf});

  const expected_toks = [_]Lexer.TokenKind {
    .Symbol, .Symbol, .LBrack, .Symbol, .Comma, .Symbol, .Comma, .Symbol, .RBrack, .LBrace,
    .Symbol, .LBrack, .Symbol, .RBrack,
    .Symbol, .Assign, .LBrack, .Symbol, .Mmul, .Symbol, .RBrack, .Call, .Symbol, .LBrack, .RBrack, .Endl, .Comment,
    .Symbol, .Assign, .Symbol, .Div, .LBrack, .Symbol, .Call, .Symbol, .LBrack, .RBrack, .Add, .Symbol, .Call, .Symbol, .LBrack, .RBrack, .RBrack, .Endl,
    .RBrace, .Symbol, .LBrace,
    .Symbol, .Symbol, .Add, .Literal, .Endl,
    .RBrace,
    .Symbol, .LBrack, .Symbol, .Mul, .LBrack, .Symbol, .Sub, .Literal, .RBrack, .RBrack, .Call, .Symbol, .LBrack, .Literal, .Comma, .Literal, .RBrack, .Endl, .Comment,
    .RBrace,
    .Symbol, .Symbol, .LBrace,
    .Symbol, .Assign, .Symbol, .Tensor, .Symbol, .LSbrack, .Literal, .Comma, .Literal, .RSbrack, .Endl,
    .Symbol, .Assign, .Symbol, .Tensor, .Symbol, .LSbrack, .Literal, .Comma, .Literal, .RSbrack, .Endl,
    .Symbol, .Assign, .Symbol, .Tensor, .Symbol, .LSbrack, .Literal, .Comma, .Literal, .Comma, .Literal, .Comma, .Literal, .RSbrack, .Endl,
    .Symbol, .Assign, .Symbol, .Mmul, .Symbol, .Endl, .Comment,
    .Symbol, .Assign, .Symbol, .LBrack, .Symbol, .Comma, .Symbol, .RBrack, .Call, .Symbol, .LBrack, .RBrack, .Endl,
    .Symbol, .Call, .Symbol, .LBrack, .RBrack, .Endl,
    .RBrace,
    .Eof,
  };

  const expected_symbols = [_][] const u8 {
    "fn", "attn", "x", "q", "v",
    "if", "foo",
    "foo", "q", "v", "T",
    "z", "foo", "v", "exp", "q", "sqrt",
    "fi",
    "yield", "x",
    "yield", "z", "q", "R",
    "fn", "main",
    "x", "T", "i32",
    "y", "T", "f32",
    "z", "T", "f8",
    "foo", "x", "y",
    "z", "attn", "x", "y", "relu",
    "z", "print",
  };

  const expected_literals = [_] Lexer.Literal {
    .{ .float = 27.0 },
    .{ .int = 3 }, .{ .int = 64 }, .{ .int = 32 },
    .{ .int = 64 }, .{ .int = 128 },
    .{ .int = 128 }, .{ .int = 256 },
    .{ .int = 10 }, .{ .int = 20000 }, .{ .int = 39 }, .{ .int = 4 },
  };

  var lexer = Lexer.init(buf);
  defer lexer.deinit();
  try lexer.tokenize(false);

  var i: usize = 0;
  var s: usize = 0;
  var l: usize = 0;

  while (lexer.peek(0)) |tok| : (lexer.consume()) {
    std.debug.print("Token {d}: {s}\n", .{i, @tagName(tok.a)});

    if (tok.b) |lit| {
      lit.print();
      switch (lit) {
        .string => |sym| {
          try std.testing.expectEqualStrings(sym, expected_symbols[s]);
          s += 1;
        },
        else => {
          try std.testing.expectEqual(lit, expected_literals[l]);
          l += 1;
        }
      }
    }

    try std.testing.expectEqual(tok.a, expected_toks[i]);
    i += 1;

    if (tok.a == .Eof) break;
  }
}
