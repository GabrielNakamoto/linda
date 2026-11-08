const tensor = @import("tensor.zig");
const c = @cImport({
  @cInclude("mlir-c/IR.h");
});


fn visit(
  node: Tensor,
  visited: std.hash_map.AutoHashMap(Tensor, void),
  schedule: std.arrayList(Tensor),
  allocator: std.mem.Allocator)
!void {
  if (visited.contains(node)) return;

  if (node.left) |nl| try visit(nl);
  if (node.right) |nr| try visit(nr);

  try visited.put(node, void);
  try schedule.append(allocator, node);
}

// DFS toposort linear time
fn toposort(root: Tensor, allocator: std.mem.Allocator) !std.ArrayList(Tensor) {
  var schedule = std.ArrayList(Tensor).empty;
  var visited = std.hash_map.AutoHashMap(Tensor, void).init(allocator);

  try schedule.append(allocator, root);
  try visit(root, visited, schedule);
  return schedule;
}

fn tensorToMLIR(tensor: Tensor, allocator: std.mem.Allocator) !c.MlirLindaOp {
  var inputs = try std.ArrayList(c.MlirType).empty;


  // if (tensor.left) |el| try inputs.append(allocator, el);
  // if (tensor.right) |er| try inputs.append(allocator, er);


}

// https://mlir.llvm.org/doxygen/IR_8cpp.html
pub fn fromDAG(ctx: c.MlirContext, sink: Tensor, allocator: std.mem.Allocator) !c.MlirModule {
  const op_builder = c.mlirOpBuilderCreate(ctx);
  const loc = c.mlirOpBuilderGetUnknownLoc(op_builder);
  var mod = c.mlirModuleCreateEmpty(loc);

  var tensor_schedule = toposort(sink, allocator);

  const block = c.mlirModuleGetBody(mod);
  // what is op_builder? some sort of graph rewriter that is aware of dialect registry
  c.mlirOpBuilderSetInsertionPointToEnd(op_builder, block);

  // now that graph is linearized by dependency, convert to custom MLIR dialect Op IR
  for (tensor_schedule) |tir| {

  }
}
