const std = @import("std");
const Tensor = @import("tensor.zig").Tensor;
const AnyTensor = @import("tensor.zig").AnyTensor;
const c = @cImport({
  @cInclude("mlir-c/IR.h");
});

// NOTE: could make use the file struct implicitly, probably should
pub const MLIRGenerator = struct {
  ctx: c.MlirContext,
  op_builder: c.MlirOpBuilder,
  allocator: std.mem.Allocator,

  const Self = @This();

  pub fn deinit(self: Self) void {
    c.mlirContextDestroy(self.ctx);
  }

  pub fn init(allocator: std.mem.Allocator) MLIRGenerator {
    const ctx = c.mlirContextCreate();
    return .{
      .ctx = ctx,
      .op_builder = c.mlirOpBuilderCreate(ctx),
      .allocator = allocator,
    };
  }

  fn visit(self: Self, node: Tensor, schedule: std.ArrayList(*const AnyTensor), visited: std.hash_map.AutoHashMap(Tensor, void)) !void {
    if (visited.contains(node)) return;

    for (node.inputs) |child| try visit(child);

    try visited.put(node, void);
    try schedule.append(self.allocator, node);
  }

  // DFS toposort linear time
  fn toposort(self: Self, root: Tensor) !std.ArrayList(*const AnyTensor) {
    var schedule = std.ArrayList(*const AnyTensor).empty;
    var visited = std.hash_map.AutoHashMap(AnyTensor, void).init(self.allocator);

    try schedule.append(self.allocator, root);
    try visit(root, schedule, visited);
    return schedule;
  }

  fn fromTensor(self: Self, block: MlirBlock, tensor: Tensor) !c.MlirLindaOp {
    c.mlirOpBuilderSetInsertionPointToEnd(self.op_builder, block);
    var inputs = try std.ArrayList(c.MlirType).empty;
    for (tensor.inputs) |edge| {
      const mlir_tensor = c.mlirUnrankedTensorTypeGet(c.mlirF32TypeGet(self.ctx));
      try inputs.append(self.allocator, mlir_tensor);
    }
  }

  // https://mlir.llvm.org/doxygen/IR_8cpp.html
  pub fn compileDAG(self: Self, sink: Tensor) !c.MlirModule {
    const loc = c.mlirOpBuilderGetUnknownLoc(self.op_builder);
    var mod = c.mlirModuleCreateEmpty(loc);

    var tensor_schedule = toposort(sink, self.allocator);
    defer tensor_schedule.deinit(self.allocator);

    const block = c.mlirModuleGetBody(mod);
    // what is op_builder? some sort of graph rewriter that is aware of dialect registry
    c.mlirOpBuilderSetInsertionPointToEnd(self.op_builder, block);

    // now that graph is linearized by dependency, convert to custom MLIR dialect Op IR
    for (tensor_schedule) |tir| {
    }
  }
};

test "test module" {
  var ctx = c.mlirContextCreate();
  defer c.mlirContextDestroy(ctx);

  const op_builder = c.mlirOpBuilderCreate(ctx);
  const loc = c.mlirOpBuilderGetUnknownLoc(op_builder);
  var module = c.mlirModuleCreateEmpty(loc);
  const block = c.mlirModuleGetBody(module);
  _ = block;
}

test "test dialect" {
}
