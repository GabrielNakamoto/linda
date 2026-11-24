const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const mod = b.addModule("linda", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    // TODO: autodetect from hardware/drivers?
    const enable_cuda = b.option(bool, "cuda", "Build the CUDA runtime") orelse false;
    const enable_metal = b.option(bool, "metal", "Build/link the METAL runtime") orelse false;
    const llvm_path = b.option(std.Build.LazyPath, "llvm_path", "local path to llvm")
      orelse std.Build.LazyPath{ .cwd_relative = "/opt/homebrew/opt/llvm"};

    const options = b.addOptions();
    options.addOption(bool, "cuda", enable_cuda);
    options.addOption(bool, "metal", enable_metal);
    options.addOption([]const u8, "llvm_path", llvm_path.getDisplayName());
    mod.addOptions("build_options", options);

    const cmake_config = b.addSystemCommand(&.{
      "cmake", "-S", "mlir", "-B", "zig-out/cmake-build", "-DCMAKE_BUILD_TYPE=Release"
    });
    const cmake =  b.addSystemCommand(&.{"cmake", "--build", "zig-out/cmake-build", "--parallel"});
    cmake.step.dependOn(&cmake_config.step);

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

    exe.step.dependOn(&cmake.step);

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

    exe.root_module.linkSystemLibrary("MLIR", .{});
    exe.root_module.linkSystemLibrary("LLVM", .{});

    // custom mlir dialect
    exe.root_module.addIncludePath(b.path("mlir/include"));
    exe.root_module.addObjectFile(b.path("zig-out/cmake-build/lib/libMLIRLinda.a"));
    exe.root_module.addObjectFile(b.path("zig-out/cmake-build/lib/libMLIRLindaPasses.a"));
    exe.root_module.addObjectFile(b.path("zig-out/cmake-build/lib/libMLIRLindaCAPI.a"));

    // setup zig binding cuda runtime dep
    if (enable_cuda) {
      const cudaz_dep = b.dependency("cudaz", .{});
      const cudaz_module = cudaz_dep.module("cudaz");
      exe.root_module.addImport("cudaz", cudaz_module);

      exe.root_module.linkSystemLibrary("cuda", .{});
      exe.root_module.linkSystemLibrary("nvrtc", .{});
    }

    // link custom metal runtime bridge
    if (enable_metal) {
      // TODO: rather then fragemented shell scripts fold the swiftc step into here
      exe.root_module.addLibraryPath(b.path("lmrb/build"));
      exe.root_module.linkSystemLibrary("LMRB", .{});
      exe.root_module.addRPath(b.path("lmrb/build"));
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
