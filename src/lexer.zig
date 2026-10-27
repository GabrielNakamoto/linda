const std = @import("std");

pub const Token = enum {
  LBrace, RBrace,
  LBrack, RBrack,
  LSbrack, RSbrack,
  Add, Mul, Sub, Div,
  Mmul,
  Comment, // #
  Decl, // :=
  Tensor, // ::
  Assign,
  Literal,
  Symbol,
  Comma,
  Call,
  Eof,
};

pub const Literal = union(enum) {
  int: i32,
  float: f32
};

pub const Lexer  = struct {
  buffer: []const u8,
  cur: usize,
  next: usize,
  last_symbol: ?[]const u8,
  last_literal: ?Literal,
  cached: ?Token,

  pub fn init(buffer: []const u8) Lexer {
    return Lexer{
      .buffer = buffer,
      .cur = 0,
      .next = 0,
      .last_symbol = null,
      .last_literal = null,
      .cached = null
    };
  }

  pub fn symbol(self: Lexer) ?[]const u8 {
    return self.last_symbol;
  }

  pub fn literal(self: Lexer) ?Literal {
    return self.last_literal;
  }

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

    const tok: ?Token = switch (self.buffer[self.next]) {
      '#' => {
        while (self.next < self.buffer.len and self.buffer[self.next] != '\n') : (self.next += 1) {}
        return .Comment;
      },
      '(' => .LBrack, ')' => .RBrack,
      '{' => .LBrace, '}' => .RBrace,
      '[' => .LSbrack, ']' => .RSbrack,
      '+' => .Add, '-' => .Sub,
      '/' => .Div, '*' => .Mul,
      '@' => .Mmul,
      ',' => .Comma,
      '.' => .Call,
      ':' => {
        if(self.buffer.len > self.next+1) {
          const cc = self.buffer[self.next+1];
          if (cc == '=' or cc == ':') {
            self.next += 2;
            return .Decl if cc == '=' else .Tensor;
         }
        }
        self.next += 1;
        return .Assign;
      },
      '0'...'9' => {
        self.last_literal = self.readLiteral();
        self.cached = .Literal;
        return .Literal;
      },
      'a'...'z', 'A'...'Z', '_' => {
        self.last_symbol = self.readSymbol();
        self.cached = .Symbol;
        return .Symbol;
      },
      else => {
        std.debug.print("WARNING: cannot tokenize: {c}\n", .{self.buffer[self.next]});
        return null;
      }
    };

    self.next += 1;
    self.cached = tok;
    return tok;
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

  const expected_toks = [_]Token {
    .Symbol, .Symbol, .LSbrack, .Literal, .Comma, .Literal, .RSbrack,       // f32 y[64, 128]
    .Symbol, .Symbol, .LSbrack, .Literal, .Comma, .Literal, .RSbrack,       // i32 z[128, 256]

    .Symbol, .Assign, .Symbol, .Mmul, .Symbol,                              // x := y @ z
    .Symbol, .Assign, .Symbol, .Call, .Symbol, .LBrack, .RBrack,            // l := x.relu()

    .LBrack, .Symbol, .Comma, .Symbol, .RBrack, .Symbol, .Assign, .LBrace,  // (x, y) attn := {
    .Symbol, .Assign, .LBrack, .Symbol, .Call,                              //    x := (x.transpose() * 3.0) - 290.3
    .Symbol, .LBrack, .RBrack, .Mul, .Literal, .RBrack, .Sub, .Literal,
    .Symbol, .Mmul, .Symbol,                                                //    x @ y
    .RBrace                                                                 // }
  };

  const expected_symbols = [_][] const u8 {
    "f32", "y", "i32", "z",
    "x", "y", "z", "l", "x",
    "relu", "x", "y", "attn",
    "x", "x", "transpose", "x", "y"
  };

  const expected_literals = [_] Literal {
    .{ .int = 64 }, .{ .int = 128 },
    .{ .int = 128 }, .{ .int = 256 },
    .{ .float = 3.0 }, .{ .float = 290.3 }
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
