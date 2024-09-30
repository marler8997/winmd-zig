var windows_args_arena = if (builtin.os.tag == .windows)
    std.heap.ArenaAllocator.init(std.heap.page_allocator)
else
    struct {}{};
pub fn cmdlineArgs() [][*:0]u8 {
    if (builtin.os.tag == .windows) {
        const slices = std.process.argsAlloc(windows_args_arena.allocator()) catch |err| switch (err) {
            error.OutOfMemory => oom(error.OutOfMemory),
            //error.InvalidCmdLine => @panic("InvalidCmdLine"),
            error.Overflow => @panic("Overflow while parsing command line"),
        };
        const args = windows_args_arena.allocator().alloc([*:0]u8, slices.len - 1) catch |e| oom(e);
        for (slices[1..], 0..) |slice, i| {
            args[i] = slice.ptr;
        }
        return args;
    }
    return std.os.argv.ptr[1..std.os.argv.len];
}

pub fn main() !void {
    const pos_args = blk: {
        const cmd_args = cmdlineArgs();
        var arg_index: usize = 0;
        var non_option_len: usize = 0;
        while (arg_index < cmd_args.len) : (arg_index += 1) {
            const arg = std.mem.span(cmd_args[arg_index]);
            if (!std.mem.startsWith(u8, arg, "-")) {
                cmd_args[non_option_len] = arg;
                non_option_len += 1;
            } else {
                errExit("unknown cmdline option '{s}'", .{arg});
            }
        }
        break :blk cmd_args[0..non_option_len];
    };

    if (pos_args.len != 1) errExit("expected 1 command-line argument but got {}", .{pos_args.len});
    const filepath = std.mem.span(pos_args[0]);

    var arena_instance = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena_instance.deinit();
    const arena = arena_instance.allocator();

    // TODO: memory map file or read it?
    const winmd_content = blk: {
        var winmd_file = std.fs.cwd().openFile(filepath, .{}) catch |err| errExit(
            "failed to open '{s}' with {s}",
            .{ filepath, @errorName(err) },
        );
        defer winmd_file.close();
        const size_u64 = try winmd_file.getEndPos();
        const size_usize = std.math.cast(usize, size_u64) orelse errExit(
            "winmd file size {} too big (max {})",
            .{ size_u64, std.math.maxInt(usize) },
        );
        var reader = winmd_file.reader(&.{});
        break :blk try reader.interface.readAlloc(arena, size_usize);
    };

    var stdout_buf: [4096]u8 = undefined;
    var stdout = std.fs.File.stdout().writer(&stdout_buf);
    dump(winmd_content, &stdout.interface) catch |err| switch (err) {
        error.WriteFailed => return stdout.err.?,
    };
}

fn dump(winmd_content: []const u8, writer: *std.Io.Writer) error{WriteFailed}!void {
    const metadata_file_offset = blk: {
        var err: winmd.MetadataError = undefined;
        break :blk winmd.locateMetadata(&err, winmd_content) catch errExit("{f}", .{err});
    };
    try writer.print("metadata at file offset {}\n", .{metadata_file_offset});

    const streams = blk: {
        var err: winmd.MetadataError = undefined;
        break :blk winmd.parseStreams(&err, winmd_content, metadata_file_offset) catch errExit("{f}", .{err});
    };
    try writer.print("streams {}\n", .{streams});

    // var arena_instance = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    // defer arena_instance.deinit();
    // const arena = arena_instance.allocator();

    const string_heap: ?[]const u8 = if (streams.strings) |strings| castArray(u8, winmd_content, metadata_file_offset + strings.offset, strings.size) else null;
    const blob_heap: ?[]const u8 = if (streams.blob) |blob| castArray(u8, winmd_content, metadata_file_offset + blob.offset, blob.size) else null;
    const tables_stream = streams.tables orelse errExit("missing the tables stream '#~'", .{});
    const tables = blk: {
        var err: winmd.MetadataError = undefined;
        break :blk winmd.parseTables(&err, winmd_content, metadata_file_offset + tables_stream.offset) catch errExit("{f}", .{err});
    };

    try writer.print("TypeDef count is {}\n", .{tables.row_counts.TypeDef});
    for (0..tables.row_counts.TypeDef) |i| {
        const type_def = tables.row(.TypeDef, i);
        const name = getString(string_heap, type_def.name);
        const namespace = getString(string_heap, type_def.namespace);
        const fields = tables.typeDefRange(@intCast(i), .fields);
        const methods = tables.typeDefRange(@intCast(i), .methods);
        try writer.print("TypeDef[{}] Namespace={s} Name={s} Flags=0x{x} {} Fields {} Methods\n", .{
            i,
            namespace,
            name,
            @as(u32, @bitCast(type_def.attributes)),
            fields.count(),
            methods.count(),
        });
    }

    try writer.print("CustomAttribute count is {}\n", .{tables.row_counts.CustomAttr});
    for (0..tables.row_counts.CustomAttr) |i| {
        const custom_attr = tables.row(.CustomAttr, i);
        const blob = getBlob(blob_heap, custom_attr.value);
        try writer.print(
            "CustomAttribute[{}] Parent={f} Method={f} blob={x}\n",
            .{
                i,
                custom_attr.parent,
                custom_attr.method,
                blob,
            },
        );
    }

    for (0..tables.row_counts.NestedClass) |i| {
        const entry = tables.row(.NestedClass, i);
        const nested_type_def = tables.row(.TypeDef, entry.nested.asIndex().?);
        const enclosing_type_def = tables.row(.TypeDef, entry.enclosing.asIndex().?);
        const nested_namespace = getString(string_heap, nested_type_def.namespace);
        const nested_name = getString(string_heap, nested_type_def.name);
        const enclosing_namespace = getString(string_heap, enclosing_type_def.namespace);
        const enclosing_name = getString(string_heap, enclosing_type_def.name);
        try writer.print(
            "Nested[{}] {}({s}:{s}) nested in {}({s}:{s})\n",
            .{
                i,
                entry.nested.asIndex().?,
                nested_namespace,
                nested_name,
                entry.enclosing.asIndex().?,
                enclosing_namespace,
                enclosing_name,
            },
        );
    }

    try writer.flush();
}

fn castArray(comptime Element: type, winmd_content: []const u8, offset: u64, len: u64) []align(1) const Element {
    const array_size: u64 = len * @sizeOf(Element);
    if (offset + array_size > winmd_content.len) errExit(
        "file truncated, required {}-bytes (array of {s}) at offset {}",
        .{ array_size, @typeName(Element), offset },
    );
    return @as([*]align(1) const Element, @ptrCast(winmd_content.ptr + offset))[0..len];
}

fn getString(heap: ?[]const u8, index: winmd.StringHeapIndex) [:0]const u8 {
    return winmd.getString(heap, index) orelse std.debug.panic(
        "invalid string heap index {}",
        .{index},
    );
}
fn getBlob(heap: ?[]const u8, index: winmd.BlobHeapIndex) []const u8 {
    return winmd.getBlob(heap, index) orelse std.debug.panic(
        "invalid blob heap index {}",
        .{index},
    );
}

fn oom(e: error{OutOfMemory}) noreturn {
    @panic(@errorName(e));
}
fn errExit(comptime fmt: []const u8, args: anytype) noreturn {
    std.log.err(fmt, args);
    std.process.exit(0xff);
}

const builtin = @import("builtin");
const std = @import("std");
const winmd = @import("winmd");
