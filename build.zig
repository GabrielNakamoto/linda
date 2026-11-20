const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const mod = b.addModule("linda", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    const enable_cuda = b.option(bool, "cuda", "Build the CUDA runtime") orelse false;
    const llvm_path = b.option(std.Build.LazyPath, "llvm_path", "local path to llvm")
      orelse std.Build.LazyPath{ .cwd_relative = "/opt/homebrew/opt/llvm"};

    const options = b.addOptions();
    options.addOption(bool, "cuda", enable_cuda);
    options.addOption([]const u8, "llvm_path", llvm_path.getDisplayName());
    mod.addOptions("build_options", options);

    const exe = b.addExecutable(.{
        .name = "linda",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "linda", .module = mod },
            },
            // .link_libc = true,
            .link_libcpp = true
        }),
    });

    // https://github.com/NaleRaphael/mlir_toy/blob/master/src/Ch2/build.zig
    const lib_lst = [_][]const u8 {
      "Affine", "IR", "Transforms", "Bufferization", "Func", "Target",
      "GPU", "NVVM", "ROCDL", "Conversion", "RegisterEverything",
    };

    exe.root_module.addIncludePath(llvm_path.path(b, "include"));
    exe.root_module.addLibraryPath(llvm_path.path(b, "lib"));

    inline for (lib_lst) |lib| {
      exe.root_module.linkSystemLibrary("MLIRCAPI" ++ lib, .{ .preferred_link_mode = .static });
    }

    exe.root_module.linkSystemLibrary("MLIR", .{ .preferred_link_mode = .dynamic });
    exe.root_module.linkSystemLibrary("LLVM", .{ .preferred_link_mode = .dynamic });

    // custom mlir dialect
    exe.root_module.addIncludePath(b.path("mlir/include"));
    exe.root_module.addObjectFile(b.path("mlir/lib/libMLIRLinda.a"));
    exe.root_module.addObjectFile(b.path("mlir/lib/libMLIRLindaPasses.a"));
    exe.root_module.addObjectFile(b.path("mlir/lib/libMLIRLindaCAPI.a"));

    // setup zig binding cuda runtime dep
    if (enable_cuda) {
      const cudaz_dep = b.dependency("cudaz", .{});
      const cudaz_module = cudaz_dep.module("cudaz");
      exe.root_module.addImport("cudaz", cudaz_module);

      exe.root_module.linkSystemLibrary("cuda", .{});
      exe.root_module.linkSystemLibrary("nvrtc", .{});
    }

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });

    const run_mod_tests = b.addRunArtifact(mod_tests);

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);
}
