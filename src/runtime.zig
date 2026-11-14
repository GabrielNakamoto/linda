const std = @import("std");
const cudaz = @import("cudaz");
const tensor = @import("tensor.zig");
const cuda = cudaz.CAPI.cuda;

pub fn launchCUDAKernel( comptime T: type, gpa: std.mem.Allocator, ptx: [:0]const u8,
  schedule: std.ArrayList(*const tensor.Node)) !void {

  const device = try cudaz.Device.default();
  defer device.deinit();

  // allocate buffers on device for every intermediate, input, and output Tensor
  var buffers: std.ArrayList(cudaz.Cudaslice(T)) = .empty;
  var params: std.ArrayList(*anyopaque) = .empty;
  for (schedule.items) |node| {
    if (node.op == .Buffer) {
      // root nodes reside in zig allocated host memory with existing elements,
      // must be copied to device first
      const bytes = node.data orelse return error.EmptyBuffer;
      const hbuf: []const T = @alignCast(std.mem.bytesAsSlice(T, &bytes));

      for (hbuf[0..10]) |x| std.debug.print("{}\n", .{x});

      const dbuf = try device.htodCopy(T, hbuf);
      try buffers.append(gpa, dbuf);
    } else {
      const dbuf = try device.alloc(T, node.numel());
      try buffers.append(gpa, dbuf);
    }
  }

  defer for (buffers.items) |buf| buf.free();

  // these buffers will be passes as kernel params by ptr
  for (buffers.items) |buf| try params.append(gpa, @ptrCast(@constCast(&buf.device_ptr)));

  const module = try cudaz.Device.loadPtxText(ptx);
  const kernel = try module.getFunc("linda_program_kernel");

  // NOTE: bypass zig binding library because of runtime struct constraint
  const res = cuda.cuLaunchKernel(
    kernel.cu_func, 1, 1, 1, 3, 1, 1, 0, null, @ptrCast(params.items.ptr), null);

  if (res != cuda.CUDA_SUCCESS) return error.CudaLaunchFailed;

  // copy result tensor back to host
  var resultTensor = try cudaz.Device.syncReclaim(T, gpa, buffers.items[buffers.items.len-1]);
  defer resultTensor.deinit(gpa);

  for (resultTensor.items[0..20]) |x| {
    std.debug.print("{}\n", .{x});
  }
}
