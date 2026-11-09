const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const mod = b.addModule("linda", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    const exe = b.addExecutable(.{
        .name = "linda",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "linda", .module = mod },
            },
            .link_libcpp = true
        }),
    });

    // https://github.com/NaleRaphael/mlir_toy/blob/master/src/Ch2/build.zig
    const lib_lst = [_][]const u8 {
      "Affine",
      "IR",
      "Transforms"
    };

    const llvm_prefix = "/opt/homebrew/opt/llvm";

    exe.root_module.addIncludePath(.{ .cwd_relative = llvm_prefix ++ "/include" });
    exe.root_module.addLibraryPath(.{ .cwd_relative = llvm_prefix ++ "/lib" });

    inline for (lib_lst) |lib| {
      exe.root_module.linkSystemLibrary("MLIRCAPI" ++ lib, .{ .preferred_link_mode = .static });
    }

    exe.root_module.linkSystemLibrary("MLIR", .{ .preferred_link_mode = .dynamic });
    exe.root_module.linkSystemLibrary("LLVM", .{ .preferred_link_mode = .dynamic });

    // custom mlir dialect
    exe.root_module.addIncludePath(b.path("mlir/include"));
    exe.root_module.addObjectFile(
      b.path("mlir/lib/libMLIRLinda.a"),
    );

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
