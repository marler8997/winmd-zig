const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const winmd_mod = b.addModule("winmd", .{
        .root_source_file = b.path("src/winmd.zig"),
    });

    {
        const exe = b.addExecutable(.{
            .name = "dumpwinmd",
            .root_module = b.createModule(.{
                .root_source_file = b.path("src/dumpwinmd.zig"),
                .target = target,
                .optimize = optimize,
                .imports = &.{
                    .{ .name = "winmd", .module = winmd_mod },
                },
            }),
        });
        const install = b.addInstallArtifact(exe, .{});
        b.step("install-dump", "").dependOn(&install.step);
        b.getInstallStep().dependOn(&install.step);

        const run = b.addRunArtifact(exe);
        run.step.dependOn(&install.step);
        if (b.args) |args| {
            run.addArgs(args);
        }
        b.step("dump", "Run dumpwinmd").dependOn(&run.step);
    }
}
