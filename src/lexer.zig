const std = @import("std");

pub const Lexer  = struct {
  buffer: []const u8,
  cur: usize = 0,
  next: usize = 0,
  last_symbol: ?[]const u8 = null,
  last_literal: ?Literal = null,
  cached: ?Token = null,

  pub const Token = enum {
    LBrace, RBrace,
    LBrack, RBrack,
    LSbrack, RSbrack,
    Add, Mul, Sub, Div, Mmul,
    Tensor, Assign,
    Literal, Symbol,
    Comma, Call,
    Comment,
    Endl,
    Eof,
  };

  pub const Literal = union(enum) {
    int: i32,
    float: f32
  };

  pub fn init(buffer: []const u8) Lexer {
    return Lexer{ .buffer = buffer };
  }

  pub fn symbol(self: Lexer) ?[]const u8 { return self.last_symbol; }
  pub fn literal(self: Lexer) ?Literal { return self.last_literal; }

  pub fn consume(self: *Lexer) void {
    std.debug.assert(self.next > self.cur);
    self.cur = self.next;
    self.cached = null;
  }

  pub fn readSymbol(self: *Lexer) []const u8 {
    const start: usize = self.next;
    while (std.ascii.isAlphanumeric(self.buffer[self.next])) : (self.next += 1) {}
    return self.buffer[start..self.next];
  }

  pub fn readLiteral(self: *Lexer) ?Literal {
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

  pub fn peek(self: *Lexer) ?Token {
    if (self.cached) |tk| return tk;
    self.next = self.cur;

    while (self.next < self.buffer.len and std.ascii.isWhitespace(self.buffer[self.next])) : (self.next += 1) {}
    if (self.next == self.buffer.len) return .Eof;

    const simple_tok: ?Token = switch (self.buffer[self.next]) {
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

    if (simple_tok) |tk| {
      self.next += 1;
      self.cached = tk;
      return tk;
    }

    const final_tok: ?Token = switch (self.buffer[self.next]) {
      '#' => blk: {
        while (self.next < self.buffer.len and self.buffer[self.next] != '\n') : (self.next += 1) {}
        break :blk .Comment;
      },
      ':' => blk: {
        std.debug.assert(self.buffer.len > self.next+1);
        std.debug.assert(self.buffer[self.next+1] == ':');
        self.next += 2;
        break :blk .Tensor;
      },
      '0'...'9' => blk: {
        self.last_literal = self.readLiteral();
        break :blk .Literal;
      },
      'a'...'z', 'A'...'Z', '_' => blk: {
        self.last_symbol = self.readSymbol();
        break :blk .Symbol;
      },
      else => null
    };

    if (final_tok) |tk| {
      self.cached = tk;
    } else {
      std.debug.print("WARNING: cannot tokenize: {c}\n", .{self.buffer[self.next]});
    }
    return final_tok;
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

  const expected_toks = [_]Lexer.Token {
    .Symbol, .Symbol, .LBrack, .Symbol, .Comma, .Symbol, .Comma, .Symbol, .RBrack, .LBrace, // fn attn (x, q, v) {
    .Symbol, .LBrack, .Symbol, .RBrack,                            // if (foo)
    .Symbol, .Assign, .LBrack, .Symbol, .Mmul, .Symbol, .RBrack, .Call, .Symbol, .LBrack, .RBrack, .Endl, .Comment, // foo = (q @ v).T() # transpose
    .Symbol, .Assign, .Symbol, .Div, .LBrack, .Symbol, .Call, .Symbol, .LBrack, .RBrack, .Add, .Symbol, .Call, .Symbol, .LBrack, .RBrack, .RBrack, .Endl, // z = foo / (v.exp() + q.sqrt())
    .RBrace, .Symbol, .LBrace,                                     // } fi {
    .Symbol, .Symbol, .Add, .Literal, .Endl,                              // yield x + 27.0
    .RBrace,                                                       // }
    .Symbol, .LBrack, .Symbol, .Mul, .LBrack, .Symbol, .Sub, .Literal, .RBrack, .RBrack, .Call, .Symbol, .LBrack, .Literal, .Comma, .Literal, .RBrack, .Endl, .Comment, // yield (z * (q - 3)).R(64,32) # reshape
    .RBrace,                                                       // }
    .Symbol, .Symbol, .LBrace,                                     // fn main {
    .Symbol, .Assign, .Symbol, .Tensor, .Symbol, .LSbrack, .Literal, .Comma, .Literal, .RSbrack, .Endl, // x := T::i32[64,128]
    .Symbol, .Assign, .Symbol, .Tensor, .Symbol, .LSbrack, .Literal, .Comma, .Literal, .RSbrack, .Endl, // y := T::f32[128, 256]
    .Symbol, .Assign, .Symbol, .Tensor, .Symbol, .LSbrack, .Literal, .Comma, .Literal, .Comma, .Literal, .Comma, .Literal, .RSbrack, .Endl, // z := T::f8[10, 20000, 39, 4]
    .Symbol, .Assign, .Symbol, .Mmul, .Symbol, .Endl, .Comment,           // foo = x @ y # 64,256
    .Symbol, .Assign, .Symbol, .LBrack, .Symbol, .Comma, .Symbol, .RBrack, .Call, .Symbol, .LBrack, .RBrack, .Endl, // z = attn(x,y).relu()
    .Symbol, .Call, .Symbol, .LBrack, .RBrack, .Endl,                     // z.print()
    .RBrace,                                                       // }
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
  var tok = lexer.peek();
  var i: usize = 0;
  var s: usize = 0;
  var l: usize = 0;

  while (tok != .Eof) : (tok = lexer.peek()) {
    try std.testing.expect(tok != null);

    switch (tok.?) {
      .Symbol => {
        const sym = lexer.symbol().?;
        std.debug.print("Symbol string: {s}\n", .{sym});
        try std.testing.expectEqualStrings(sym, expected_symbols[s]);
        s += 1;
      },
      .Literal => {
        const lit = lexer.literal().?;
        switch (lit) {
          .int => |val| std.debug.print("Int literal: {}\n", .{val}),
          .float => |val| std.debug.print("Float literal: {}\n", .{val}),
        }
        try std.testing.expectEqual(lit, expected_literals[l]);
        l += 1;
      },
      else => {
        std.debug.print("Token {d}: {s}\n", .{i, @tagName(tok.?)});
      }
    }

    try std.testing.expectEqual(tok, expected_toks[i]);
    i += 1;
    lexer.consume();
  }
}
