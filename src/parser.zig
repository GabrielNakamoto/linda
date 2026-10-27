const lexer = @import("lexer");

// recursive descent parsing,

// each unit of the AST is represented by formal recursive rules?
// ex. a binary expression is either can be 2 more expressions or an expression and a literal
// top level program gets broken down into blocks, blocks into atomic units and functions, declarations etc..
// interprets structure from a flat stream of tokens

// formal(ish) grammar:
// module := []
// func := [block]
// block := { [expr] ... }
// expr :=
//    var = [expr]
//    [expr] binop [expr]
//    func ( [expr] )
// literal := number

pub const ExprKind = enum {
  BinOp,
  Decl,
  Assign,
  Call,
  Print
};

pub const ASTType {
  Module,
  Expr,
  Block,
};

pub const ASTFunction = struct {
};

pub const AST = struct {
  functions: ASTFunction[]
  alloc: std.mem.Allocator,
};

pub const Parser = struct {
  lexer: *lexer.Lexer,

  pub fn init(lexer: *lexer.Lexer) Parser {
    return .{
      .lexer = lexer
    }
  }

  // what does parser do? converts stream of tokens => structured AST
  pub fn parse() {
  }
};

test "test parse simple program" {
  const io = std.testing.io;
  const gpa = std.testing.allocator;
  const dir = std.Io.Dir.cwd();

  const buf = try dir.readFileAlloc(io, "exmaples/simple.lda", gpa, .unlimited);
  defer gpa.free(buf);

  const parser = Parser.init(Lexer.init(buf));
  parser.parse();
}
