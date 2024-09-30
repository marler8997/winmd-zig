const std = @import("std");

pub const FieldAccessBits = enum(u3) {
    private_scope = 0,
    private = 1,
    family_and_assembly = 2,
    assembly = 3,
    family = 4,
    family_or_assembly = 5,
    public = 6,
    invalid = 7,
};

pub const FieldAttributes = packed struct(u32) {
    access: FieldAccessBits,
    reserved3: bool = false,
    static: bool,
    /// true if the field can only be modified within a constructor of the containing type
    init_only: bool = false,
    /// true if field's value is constant known at compile-time
    literal: bool = false,
    /// true if the field does not need to be serialized when the type is remoted
    not_serialized: bool = false,
    has_field_rva: bool = false,
    special_name: bool = false,
    rt_special_name: bool = false,
    reserved_11: bool = false,
    has_field_marshal: bool = false,
    pinvoke_impl: bool = false,
    reserved_14: bool = false,
    has_default: bool = false,
    padding: u16 = 0,
};

pub const PInvokeAttributes = packed struct(u32) {
    no_mangle: bool,
    char_set: enum(u2) {
        not_spec = 0,
        ansi = 1,
        unicode = 2,
        auto = 3,
    },
    reserved_3: bool,
    best_fit: enum(u2) {
        use_assem = 0,
        enabled = 1,
        disabled = 2,
        reserved = 3,
    },
    supports_last_error: bool,
    reserved_7: bool,
    call_conv: enum(u3) {
        platform_api = 0,
        cdecl = 1,
        stdcall = 2,
        thiscall = 3,
        fastcall = 4,
        reserved_5 = 5,
        reserved_6 = 6,
        reserved_7 = 7,
    },
    reserved_11: bool,
    throw_on_unmappable_char: enum(u2) {
        use_assem = 0,
        enabled = 1,
        disabled = 2,
        reserved = 3,
    },
    reserved_14: bool,
    reserved_15: bool,
    padding: u16,
};

pub const image_dos_signature = std.mem.readInt(u16, "MZ", .little);
pub const ImageDosHeader = extern struct {
    e_signature: u16 align(1),
    e_cblp: u16 align(1),
    e_cp: u16 align(1),
    e_crlc: u16 align(1),
    e_cparhdr: u16 align(1),
    e_minalloc: u16 align(1),
    e_maxalloc: u16 align(1),
    e_ss: u16 align(1),
    e_sp: u16 align(1),
    e_csum: u16 align(1),
    e_ip: u16 align(1),
    e_cs: u16 align(1),
    e_lfarlc: u16 align(1),
    e_ovno: u16 align(1),
    e_res0: u16 align(1),
    e_res1: u16 align(1),
    e_res2: u16 align(1),
    e_res3: u16 align(1),
    e_oemid: u16 align(1),
    e_oeminfo: u16 align(1),
    e_res2_0: u16 align(1),
    e_res2_1: u16 align(1),
    e_res2_2: u16 align(1),
    e_res2_3: u16 align(1),
    e_res2_4: u16 align(1),
    e_res2_5: u16 align(1),
    e_res2_6: u16 align(1),
    e_res2_7: u16 align(1),
    e_res2_8: u16 align(1),
    e_res2_9: u16 align(1),
    e_lfanew: u32 align(1),
};

pub const pe_signature = [4]u8{ 'P', 'E', 0, 0 };

pub const PeHeader = extern struct {
    Signature: [4]u8 align(1),
    Machine: std.coff.MachineType align(1),
    NumberOfSections: u16 align(1),
    TimeDateStamp: u32 align(1),
    PointerToSymbolTable: u32 align(1),
    NumberOfSymbols: u32 align(1),
    SizeOfOptionalHeader: u16 align(1),
    Characteristics: u16 align(1),
};

pub const ImageDataDirectory = extern struct {
    virtual_address: u32 align(1),
    size: u32 align(1),
};

pub const ImageOptionalHeader = extern union {
    common: std.coff.OptionalHeader align(1),
    pe32: OptionalHeaderPE32 align(1),
    pe64: std.coff.OptionalHeaderPE64 align(1),
};

pub const OptionalHeaderPE32 = extern struct {
    magic: u16 align(1),
    major_linker_version: u8 align(1),
    minor_linker_version: u8 align(1),
    size_of_code: u32 align(1),
    size_of_initialized_data: u32 align(1),
    size_of_uninitialized_data: u32 align(1),
    address_of_entry_point: u32 align(1),
    base_of_code: u32 align(1),
    base_of_data: u32 align(1),
    image_base: u32 align(1),
    section_alignment: u32 align(1),
    file_alignment: u32 align(1),
    major_operating_system_version: u16 align(1),
    minor_operating_system_version: u16 align(1),
    major_image_version: u16 align(1),
    minor_image_version: u16 align(1),
    major_subsystem_version: u16 align(1),
    minor_subsystem_version: u16 align(1),
    win32_version_value: u32 align(1),
    size_of_image: u32 align(1),
    size_of_headers: u32 align(1),
    checksum: u32 align(1),
    subsystem: std.coff.Subsystem align(1),
    dll_flags: std.coff.DllFlags align(1),
    size_of_stack_reserve: u32 align(1),
    size_of_stack_commit: u32 align(1),
    size_of_heap_reserve: u32 align(1),
    size_of_heap_commit: u32 align(1),
    loader_flags: u32 align(1),
    number_of_rva_and_sizes: u32 align(1),
    data_directory: [16]ImageDataDirectory align(1),
};
pub const OptionalHeaderPE64 = std.coff.OptionalHeaderPE64;

pub const magic_pe32 = 0x10b;
pub const magic_pe32plus = 0x20b;
pub const image_directory_entry_com_descriptor = 14;

pub const ImageCorHeader = extern struct {
    cb: u32 align(1),
    major_runtime_version: u16 align(1),
    minor_runtime_version: u16 align(1),
    metadata: ImageDataDirectory align(1),
    flags: u32 align(1),
    entry_point_token_or_entry_point_rva: u32 align(1),
    resources: ImageDataDirectory align(1),
    strong_name_signature: ImageDataDirectory align(1),
    code_manager_table: ImageDataDirectory align(1),
    vtable_fixups: ImageDataDirectory align(1),
    export_address_table_jumps: ImageDataDirectory align(1),
    managed_native_header: ImageDataDirectory align(1),
};

comptime {
    std.debug.assert(@sizeOf(MetadataRoot) == 16);
}
pub const MetadataRoot = extern struct {
    signature: [4]u8 align(1),
    major_version: u16 align(1),
    minor_version: u16 align(1),
    reserved: u32 align(1),
    version_length: u32 align(1),
};
pub const metadata_root_signature = "BSJB";

pub const Stream = struct {
    offset: u32,
    size: u32,
};
pub const Streams = struct {
    strings: ?Stream = null,
    us: ?Stream = null,
    blob: ?Stream = null,
    guid: ?Stream = null,
    tables: ?Stream = null,
    pub fn getRef(self: *Streams, kind: StreamKind) *?Stream {
        return switch (kind) {
            .strings => &self.strings,
            .us => &self.us,
            .blob => &self.blob,
            .guid => &self.guid,
            .tables => &self.tables,
        };
    }
};
pub const StreamKind = enum { strings, us, blob, guid, tables };
pub const stream_name_map = std.StaticStringMap(StreamKind).initComptime(.{
    .{ "#~", .tables },
    .{ "#Strings", .strings },
    .{ "#US", .us },
    .{ "#GUID", .guid },
    .{ "#Blob", .blob },
});

const HeapSizes = packed struct(u8) {
    strings: u1,
    guid: u1,
    blob: u1,
    reserved: u5,
};

const AssemblyVersion = packed struct(u32) {
    major: u16,
    minor: u16,
};
const AssemblyBuild = packed struct(u32) {
    build: u16,
    revision: u16,
};

pub const TableStreamHeader = extern struct {
    pub const Valid = packed struct(u64) {
        Module: bool,
        TypeRef: bool,
        TypeDef: bool,
        _: u61,
    };

    reserved0: u32 align(1),
    major_version: u8 align(1),
    minor_version: u8 align(1),
    heap_sizes: HeapSizes align(1),
    reserved1: u8 align(1),
    valid: Valid align(1),
    sorted: packed struct(u64) {
        _: u64,
    } align(1),
};

pub const MetadataError = union(enum) {
    truncated: struct {
        what: []const u8,
        start: u64,
        end: u64,
        file_size: u64,
    },
    mismatch: struct {
        what: []const u8,
        file_offset: u64,
        expected: u64,
        actual: u64,
    },
    bad_opt_magic: u16,
    missing_rva: struct {
        rva: u32,
        kind: enum { cor_header, metadata },
    },
    unknown_stream: []const u8,
    duplicate_stream: []const u8,
    pub fn set(err: *MetadataError, val: MetadataError) error{Metadata} {
        err.* = val;
        return error.Metadata;
    }
    pub fn format(err: *const MetadataError, writer: *std.Io.Writer) error{WriteFailed}!void {
        switch (err.*) {
            .truncated => |*t| if (t.start > t.file_size) try writer.print(
                "file truncated, {s} is located at {} past the end of the file at {}",
                .{ t.what, t.start, t.file_size },
            ) else try writer.print(
                "file truncated, {s} located at {} extends to {} past the end of the file at {}",
                .{ t.what, t.start, t.end, t.file_size },
            ),
            .mismatch => |*m| try writer.print(
                "{s} mismatch at offset {}, expected 0x{x} got 0x{x}",
                .{ m.what, m.file_offset, m.expected, m.actual },
            ),
            .bad_opt_magic => |magic| try writer.print(
                "invalid OptionalHeader magic 0x{x}",
                .{magic},
            ),
            .missing_rva => |*m| try writer.print("{s} rva (0x{x}) is missing from the section header", .{
                switch (m.kind) {
                    .cor_header => "COR header",
                    .metadata => "metadata",
                },
                m.rva,
            }),
            .unknown_stream => |name| try writer.print("unknown metadata stream name '{s}'", .{name}),
            .duplicate_stream => |name| try writer.print("duplicate metadata stream name '{s}'", .{name}),
        }
    }
};
pub fn locateMetadata(err: *MetadataError, winmd_content: []const u8) error{Metadata}!u64 {
    const e_lfanew = blk: {
        const dos_header = try castOne(err, ImageDosHeader, winmd_content, 0);
        if (dos_header.e_signature != image_dos_signature) return err.set(.{ .mismatch = .{
            .what = "DOS signature",
            .file_offset = 0,
            .expected = image_dos_signature,
            .actual = dos_header.e_signature,
        } });
        break :blk dos_header.e_lfanew;
    };

    const opt_header_size: u16, const section_count: u16 = blk: {
        const pe_header = try castOne(err, PeHeader, winmd_content, e_lfanew);
        if (!std.mem.eql(u8, &pe_header.Signature, &pe_signature)) return err.set(.{ .mismatch = .{
            .what = "PE header signature",
            .file_offset = @offsetOf(PeHeader, "Signature"),
            .expected = std.mem.readInt(u32, &pe_signature, .little),
            .actual = std.mem.readInt(u32, &pe_header.Signature, .little),
        } });
        break :blk .{ pe_header.SizeOfOptionalHeader, pe_header.NumberOfSections };
    };
    const cor_header_rva: u32 = blk: {
        const opt_header_offset: usize = e_lfanew + @sizeOf(PeHeader);
        const opt_header = try castOne(err, std.coff.OptionalHeader, winmd_content, opt_header_offset);
        switch (opt_header.magic) {
            magic_pe32 => {
                const opt_header32 = try castOne(err, OptionalHeaderPE32, winmd_content, opt_header_offset);
                break :blk opt_header32.data_directory[
                    image_directory_entry_com_descriptor
                ].virtual_address;
            },
            magic_pe32plus => {
                @panic("todo: implement pe32+");
            },
            else => return err.set(.{ .bad_opt_magic = opt_header.magic }),
        }
    };

    const section_size: u64 = @as(u64, section_count) * @sizeOf(std.coff.SectionHeader);
    const section_file_offset: u64 = @as(u64, e_lfanew) + @sizeOf(PeHeader) + opt_header_size;
    if (section_file_offset + section_size > winmd_content.len) return err.set(.{ .truncated = .{
        .what = "PE Section Table",
        .start = section_file_offset,
        .end = section_file_offset + section_size,
        .file_size = winmd_content.len,
    } });
    const sections_ptr: [*]align(1) const std.coff.SectionHeader = @ptrCast(winmd_content.ptr + section_file_offset);
    const sections = sections_ptr[0..section_count];

    const metadata_rva = blk: {
        const cor_header_file_offset = fileOffsetFromRva(sections, cor_header_rva) orelse return err.set(.{
            .missing_rva = .{ .kind = .cor_header, .rva = cor_header_rva },
        });
        const cor_header = try castOne(err, ImageCorHeader, winmd_content, cor_header_file_offset);
        break :blk cor_header.metadata.virtual_address;
    };
    return fileOffsetFromRva(sections, metadata_rva) orelse return err.set(
        .{ .missing_rva = .{ .kind = .metadata, .rva = metadata_rva } },
    );
}

pub fn parseStreams(err: *MetadataError, winmd_content: []const u8, metadata_file_offset: u64) error{Metadata}!Streams {
    const version_len: u32 = blk: {
        const root = try castOne(err, MetadataRoot, winmd_content, metadata_file_offset);
        if (!std.mem.eql(u8, &root.signature, metadata_root_signature)) return err.set(.{ .mismatch = .{
            .what = "Metadata signature",
            .file_offset = metadata_file_offset + @offsetOf(MetadataRoot, "signature"),
            .expected = std.mem.readInt(u32, metadata_root_signature, .little),
            .actual = std.mem.readInt(u32, &root.signature, .little),
        } });
        break :blk root.version_length;
    };

    var streams: Streams = .{};
    var file_offset: usize = metadata_file_offset + @sizeOf(MetadataRoot) + 2 + version_len;
    const stream_count = try readInt(err, u16, winmd_content, &file_offset);
    std.log.info("stream count {}", .{stream_count});
    for (0..stream_count) |stream_index| {
        const stream_offset = try readInt(err, u32, winmd_content, &file_offset);
        const stream_size = try readInt(err, u32, winmd_content, &file_offset);
        const name_start = file_offset;
        while (true) : (file_offset += 1) {
            if (file_offset >= winmd_content.len) return err.set(.{ .truncated = .{
                .what = "a stream name",
                .start = name_start,
                .end = file_offset,
                .file_size = winmd_content.len,
            } });
            if (winmd_content[file_offset] == 0) break;
        }
        const name_end = file_offset;
        const name = winmd_content[name_start..name_end];
        file_offset += 1;
        const str_len = file_offset - name_start;
        const str_len_padded = std.mem.alignForward(usize, str_len, 4);
        file_offset += (str_len_padded - str_len);
        if (file_offset >= winmd_content.len) return err.set(.{ .truncated = .{
            .what = "a stream name",
            .start = name_start,
            .end = file_offset,
            .file_size = winmd_content.len,
        } });
        const kind = stream_name_map.get(name) orelse return err.set(.{ .unknown_stream = name });
        const stream_ref = streams.getRef(kind);
        if (stream_ref.* != null) return err.set(.{ .duplicate_stream = name });
        std.log.info(
            "stream[{}] name='{s}' offset={} size={}",
            .{ stream_index, name, stream_offset, stream_size },
        );
        stream_ref.* = .{
            .offset = stream_offset,
            .size = stream_size,
        };
    }
    return streams;
}

pub const RowRange = struct {
    start: u32,
    limit: u32,

    pub const empty: RowRange = .{ .start = 0, .limit = 0 };
    pub fn count(range: RowRange) u32 {
        std.debug.assert(range.start <= range.limit);
        return range.limit - range.start;
    }
};

pub fn OptionalIndex(comptime T: type) type {
    return packed struct(T) {
        value: T,

        const Self = @This();
        pub const none: Self = .{ .value = 0 };
        pub fn fromIndex(index: T) Self {
            return .{ .value = index + 1 };
        }
        pub fn asIndex(opt_index: Self) ?T {
            return if (opt_index.value == 0) null else (opt_index.value - 1);
        }
        // pub fn format(opt_index: Self, writer: *std.Io.Writer) error{WriteFailed}!void {
        //     try writer.print("{?d}", .{opt_index.asIndex()});
        // }
    };
}

pub const StringHeapIndex = enum(u32) {
    _,
};
pub const GuidHeapIndex = enum(u32) {
    _,
};
pub const BlobHeapIndex = enum(u32) {
    _,
};

pub fn Row(table: Table) type {
    return @field(row, @tagName(table));
}
pub fn columnCount(table: Table) u3 {
    return std.meta.fields(Row(table)).len;
}

const row = struct {
    const Module = struct {
        generation: u32,
        name: StringHeapIndex,
        mvid: GuidHeapIndex,
        enc_id: GuidHeapIndex,
        enc_base_id: GuidHeapIndex,
    };
    const TypeRef = struct {
        resolution_scope: ResolutionScope,
        name: StringHeapIndex,
        namespace: StringHeapIndex,
    };
    const TypeDef = struct {
        attributes: TypeAttributes,
        name: StringHeapIndex,
        namespace: StringHeapIndex,
        extends: Type,
        fields: OptionalIndex(u32), // Field table index
        methods: OptionalIndex(u32), // MethodDef table index
    };
    const Field = struct {
        attributes: FieldAttributes,
        name: StringHeapIndex,
        signature: BlobHeapIndex,
    };
    const MethodDef = struct {
        rva: u32,
        impl_flags: MethodImplAttributes,
        attributes: MethodAttributes,
        name: StringHeapIndex,
        signature: BlobHeapIndex,
        params: OptionalIndex(u32), // Param table index
    };
    const Param = struct {
        attributes: ParamAttributes,
        sequence: u32,
        name: StringHeapIndex,
    };
    const InterfaceImpl = struct {
        class: OptionalIndex(u32), // TypeDef table index
        interface: Type,
    };
    const MemberRef = struct {
        parent: MemberRefParent,
        name: StringHeapIndex,
        signature: BlobHeapIndex,
    };
    const Constant = struct {
        type: u32, // 2-byte value padded
        parent: ConstantParent,
        value: BlobHeapIndex,
    };
    const CustomAttr = struct {
        parent: CustomAttrParent, // HasCustomAttribute coded index
        method: CustomAttrMethod,
        value: BlobHeapIndex,
    };
    const FieldMarshal = struct {
        parent: u32, // HasFieldMarshal coded index
        native_type: BlobHeapIndex,
    };
    const DeclSecurity = struct {
        action: u32,
        parent: u32, // HasDeclSecurity coded index
        permission_set: BlobHeapIndex,
    };
    const ClassLayout = struct {
        packing_size: u32,
        class_size: u32,
        parent: OptionalIndex(u32), // TypeDef table index
    };
    const FieldLayout = struct {
        offset: u32,
        field: OptionalIndex(u32), // Field table index
    };
    const StandAloneSig = struct {
        signature: BlobHeapIndex,
    };
    const EventMap = struct {
        parent: OptionalIndex(u32), // TypeDef table index
        event_list: OptionalIndex(u32), // Event table index
    };
    const Event = struct {
        event_flags: u32,
        name: StringHeapIndex,
        event_type: Type,
    };
    const PropertyMap = struct {
        parent: OptionalIndex(u32), // TypeDef table index
        property_list: OptionalIndex(u32), // Property table index
    };
    const Property = struct {
        flags: u32,
        name: StringHeapIndex,
        type: BlobHeapIndex,
    };
    const MethodSemantics = struct {
        semantics: u32,
        method: OptionalIndex(u32), // MethodDef table index
        association: u32, // HasSemantics coded index
    };
    const MethodImpl = struct {
        class: OptionalIndex(u32), // TypeDef table index
        method_body: u32, // MethodDefOrRef coded index
        method_declaration: u32, // MethodDefOrRef coded index
    };
    const ModuleRef = struct {
        name: StringHeapIndex,
    };
    const TypeSpec = struct {
        signature: BlobHeapIndex,
    };
    const ImplMap = struct {
        flags: PInvokeAttributes,
        member_forwarded: MemberForwarded,
        import_name: StringHeapIndex,
        import_scope: OptionalIndex(u32), // ModuleRef table index
    };
    const FieldRva = struct {
        rva: u32,
        field: OptionalIndex(u32), // Field table index
    };
    const Assembly = struct {
        hash_alg_id: u32,
        version: AssemblyVersion,
        build_rev: AssemblyBuild,
        flags: u32,
        public_key: BlobHeapIndex,
        name: StringHeapIndex,
        culture: StringHeapIndex,
    };
    const AssemblyProcessor = struct {
        processor: u32,
    };
    const AssemblyOs = struct {
        os_platform_id: u32,
        os_major_version: u32,
        os_minor_version: u32,
    };
    const AssemblyRef = struct {
        version: AssemblyVersion,
        build_rev: AssemblyBuild,
        flags: u32,
        public_key_or_token: BlobHeapIndex,
        name: StringHeapIndex,
        culture: StringHeapIndex,
        hash_value: BlobHeapIndex,
    };
    const AssemblyRefProcessor = struct {
        processor: u32,
        assembly_ref: OptionalIndex(u32), // AssemblyRef table index
    };
    const AssemblyRefOs = struct {
        os_platform_id: u32,
        os_major_version: u32,
        os_minor_version: u32,
        assembly_ref: OptionalIndex(u32), // AssemblyRef table index
    };
    const File = struct {
        flags: u32,
        name: StringHeapIndex,
        hash_value: BlobHeapIndex,
    };
    const ExportedType = struct {
        flags: u32,
        type_def_id: u32,
        name: StringHeapIndex,
        namespace: StringHeapIndex,
        implementation: u32, // Implementation coded index
    };
    const ManifestResource = struct {
        offset: u32,
        flags: u32,
        name: StringHeapIndex,
        implementation: u32, // Implementation coded index
    };
    const NestedClass = struct {
        nested: OptionalIndex(u32), // TypeDef table index
        enclosing: OptionalIndex(u32), // TypeDef table index
    };
    const GenericParam = struct {
        number: u32,
        flags: u32,
        owner: u32, // TypeOrMethodDef coded index
        name: StringHeapIndex,
    };
    const MethodSpec = struct {
        method: u32, // MethodDefOrRef coded index
        instantiation: BlobHeapIndex,
    };
    const GenericParamConstraint = struct {
        owner: OptionalIndex(u32), // GenericParam table index
        constraint: Type,
    };
};

pub const Tables = struct {
    mem: []const u8,
    row_counts: ValuePerTable(u32),
    large_columns: LargeColumnsPerTable,
    offsets: TableOffsets,

    pub fn slice(tables: *const Tables, table: Table) []const u8 {
        const start = tables.offsets.val(table);
        const end = if (table.next()) |next_table| tables.offsets.val(next_table) else tables.mem.len;
        return tables.mem[start..end];
    }

    pub fn row(
        tables: *const Tables,
        comptime table: Table,
        row_index: usize,
    ) Row(table) {
        var result: Row(table) = undefined;
        const table_mem = tables.slice(table);
        const large_cols = @field(tables.large_columns, @tagName(table));
        const row_size = large_cols.rowSize(usize);
        var offset: usize = row_index * row_size;
        inline for (std.meta.fields(Row(table)), 0..) |field, i| {
            const value: u32 = blk: {
                if (large_cols.get(i)) {
                    const value: u32 = std.mem.readInt(u32, table_mem[offset..][0..4], .little);
                    offset += 4;
                    break :blk value;
                }
                const value: u32 = std.mem.readInt(u16, table_mem[offset..][0..2], .little);
                offset += 2;
                break :blk value;
            };

            @field(result, field.name) = switch (@typeInfo(@TypeOf(@field(result, field.name)))) {
                .@"enum" => @enumFromInt(value),
                else => @bitCast(value),
            };
        }
        return result;
    }

    pub fn typeDefRange(tables: *const Tables, index: u32, kind: enum { fields, methods }) RowRange {
        std.debug.assert(index < tables.row_counts.TypeDef);

        const first_type_def = tables.row(.TypeDef, index);
        const maybe_start = switch (kind) {
            .fields => first_type_def.fields,
            .methods => first_type_def.methods,
        };
        const start = maybe_start.asIndex() orelse return .{ .start = 0, .limit = 0 };
        const row_count = switch (kind) {
            .fields => tables.row_counts.Field,
            .methods => tables.row_counts.MethodDef,
        };
        std.debug.assert(start <= row_count);

        const limit = blk: {
            if (index + 1 == tables.row_counts.TypeDef) break :blk row_count;
            const next_type_def = tables.row(.TypeDef, index + 1);
            const maybe_next_start = switch (kind) {
                .fields => next_type_def.fields,
                .methods => next_type_def.methods,
            };
            const next_start = maybe_next_start.asIndex() orelse @panic("is this possible?");
            std.debug.assert(next_start >= start);
            break :blk next_start;
        };
        return .{ .start = start, .limit = limit };
    }

    pub fn methodParams(tables: *const Tables, index: u32) RowRange {
        std.debug.assert(index < tables.row_counts.MethodDef);
        const first_method_def = tables.row(.MethodDef, index);
        const start = first_method_def.params.asIndex() orelse return .{ .start = 0, .limit = 0 };
        std.debug.assert(start <= tables.row_counts.Param);

        const limit = blk: {
            if (index + 1 == tables.row_counts.MethodDef) break :blk tables.row_counts.Param;
            const next_method_def = tables.row(.MethodDef, index + 1);
            const next_start = next_method_def.params.asIndex() orelse @panic("is this possible?");
            std.debug.assert(next_start >= start);
            break :blk next_start;
        };
        return .{ .start = start, .limit = limit };
    }
};
pub fn parseTables(
    err: *MetadataError,
    winmd_content: []const u8,
    tables_file_offset: u64,
) error{Metadata}!Tables {
    const table_header = try castOne(err, TableStreamHeader, winmd_content, tables_file_offset);
    std.log.info("table heap sizes {}", .{table_header.heap_sizes});
    std.log.info("table valid {}", .{table_header.valid});

    var included_row_count: u8 = 0;
    var row_counts: ValuePerTable(u32) = undefined;

    const table_data_file_offset = blk: {
        var file_offset: usize = tables_file_offset + @sizeOf(TableStreamHeader);
        for (0..64) |table_index| {
            const maybe_table = Table.fromInt(table_index);
            const bit_flag: u64 = @as(u64, 1) << @intCast(table_index);
            const is_included = 0 != (bit_flag & @as(u64, @bitCast(table_header.valid)));
            const row_count: u32 = if (is_included) try readInt(err, u32, winmd_content, &file_offset) else 0;

            if (maybe_table) |table| {
                const row_count_ref = row_counts.valRef(table);
                row_count_ref.* = row_count;
            }
            if (is_included) {
                included_row_count += 1;
            }
            const name: []const u8 = if (maybe_table) |t| @tagName(t) else "--";
            std.log.info("table {}: {} row(s) ({s})", .{ table_index, row_count, name });
        }
        break :blk file_offset;
    };
    var large_columns: LargeColumnsPerTable = undefined;
    const table_offsets = tableOffsets(table_header.heap_sizes, &row_counts, &large_columns);

    const tables_size: u64 = @as(u64, table_offsets.GenericParamConstraint) +
        @as(u64, large_columns.GenericParamConstraint.rowSize(u32)) *
            @as(u64, row_counts.GenericParamConstraint);

    const table_data_end = table_data_file_offset + tables_size;
    if (table_data_end > winmd_content.len) {
        return err.set(.{ .truncated = .{
            .what = "metadata table data",
            .start = table_data_file_offset,
            .end = table_data_end,
            .file_size = winmd_content.len,
        } });
    }

    return .{
        .mem = winmd_content[table_data_file_offset..][0..@intCast(tables_size)],
        .row_counts = row_counts,
        .large_columns = large_columns,
        .offsets = table_offsets,
    };
}

fn castOne(
    err: *MetadataError,
    comptime T: type,
    winmd_content: []const u8,
    offset: u64,
) error{Metadata}!*align(1) const T {
    if (offset + @sizeOf(T) > winmd_content.len) return err.set(.{ .truncated = .{
        .what = @typeName(T),
        .start = offset,
        .end = offset + @sizeOf(T),
        .file_size = winmd_content.len,
    } });
    return @ptrCast(winmd_content.ptr + offset);
}

fn readInt(
    err: *MetadataError,
    comptime T: type,
    winmd_content: []const u8,
    offset: *usize,
) error{Metadata}!T {
    if (offset.* + @sizeOf(T) > winmd_content.len) return err.set(.{ .truncated = .{
        .what = "an integer",
        .start = offset.*,
        .end = offset.* + @sizeOf(T),
        .file_size = winmd_content.len,
    } });
    const int = std.mem.readInt(T, winmd_content[offset.*..][0..@sizeOf(T)], .little);
    offset.* += @sizeOf(T);
    return int;
}

fn fileOffsetFromRva(
    sections: []align(1) const std.coff.SectionHeader,
    rva: u32,
) ?usize {
    for (sections) |section| {
        const limit = section.virtual_address + section.virtual_size;
        if (rva >= section.virtual_address and rva < limit)
            return @intCast(@as(u64, section.pointer_to_raw_data) + @as(u64, rva - section.virtual_address));
    }
    return null;
}

pub const Table = enum {
    Module,
    TypeRef,
    TypeDef,
    Field,
    MethodDef,
    Param,
    InterfaceImpl,
    MemberRef,
    Constant,
    CustomAttr,
    FieldMarshal,
    DeclSecurity,
    ClassLayout,
    FieldLayout,
    StandAloneSig,
    EventMap,
    Event,
    PropertyMap,
    Property,
    MethodSemantics,
    MethodImpl,
    ModuleRef,
    TypeSpec,
    ImplMap,
    FieldRva,
    Assembly,
    AssemblyProcessor,
    AssemblyOs,
    AssemblyRef,
    AssemblyRefProcessor,
    AssemblyRefOs,
    File,
    ExportedType,
    ManifestResource,
    NestedClass,
    GenericParam,
    MethodSpec,
    GenericParamConstraint,

    pub fn next(table: Table) ?Table {
        const fields = std.meta.fields(Table);
        if (@intFromEnum(table) == fields[fields.len - 1].value) return null;
        return @enumFromInt(@intFromEnum(table) + 1);
    }

    pub fn fromInt(int: anytype) ?Table {
        return switch (int) {
            0 => .Module,
            1 => .TypeRef,
            2 => .TypeDef,
            4 => .Field,
            6 => .MethodDef,
            8 => .Param,
            9 => .InterfaceImpl,
            10 => .MemberRef,
            11 => .Constant,
            12 => .CustomAttr,
            13 => .FieldMarshal,
            14 => .DeclSecurity,
            15 => .ClassLayout,
            16 => .FieldLayout,
            17 => .StandAloneSig,
            18 => .EventMap,
            20 => .Event,
            21 => .PropertyMap,
            23 => .Property,
            24 => .MethodSemantics,
            25 => .MethodImpl,
            26 => .ModuleRef,
            27 => .TypeSpec,
            28 => .ImplMap,
            29 => .FieldRva,
            32 => .Assembly,
            33 => .AssemblyProcessor,
            34 => .AssemblyOs,
            35 => .AssemblyRef,
            36 => .AssemblyRefProcessor,
            37 => .AssemblyRefOs,
            38 => .File,
            39 => .ExportedType,
            40 => .ManifestResource,
            41 => .NestedClass,
            42 => .GenericParam,
            43 => .MethodSpec,
            44 => .GenericParamConstraint,
            else => null,
        };
    }
};
pub fn ValuePerTable(comptime T: type) type {
    return struct {
        Module: T,
        TypeRef: T,
        TypeDef: T,
        Field: T,
        MethodDef: T,
        Param: T,
        InterfaceImpl: T,
        MemberRef: T,
        Constant: T,
        CustomAttr: T,
        FieldMarshal: T,
        DeclSecurity: T,
        ClassLayout: T,
        FieldLayout: T,
        StandAloneSig: T,
        EventMap: T,
        Event: T,
        PropertyMap: T,
        Property: T,
        MethodSemantics: T,
        MethodImpl: T,
        ModuleRef: T,
        TypeSpec: T,
        ImplMap: T,
        FieldRva: T,
        Assembly: T,
        AssemblyProcessor: T,
        AssemblyOs: T,
        AssemblyRef: T,
        AssemblyRefProcessor: T,
        AssemblyRefOs: T,
        File: T,
        ExportedType: T,
        ManifestResource: T,
        NestedClass: T,
        GenericParam: T,
        MethodSpec: T,
        GenericParamConstraint: T,

        const Self = @This();
        pub fn val(self: *const Self, table: Table) T {
            return switch (table) {
                inline else => |tag| @field(self, @tagName(tag)),
            };
        }
        pub fn valRef(self: *Self, table: Table) *T {
            return switch (table) {
                inline else => |tag| &@field(self, @tagName(tag)),
            };
        }
    };
}

fn LargeColumnFlags(comptime count: u8) type {
    return @Type(.{ .int = .{ .bits = count, .signedness = .unsigned } });
}

pub fn LargeColumns(comptime count: u8) type {
    return struct {
        flags: LargeColumnFlags(count),
        pub const Self = @This();
        pub fn init(large_columns: [count]bool) Self {
            var flags: LargeColumnFlags(count) = 0;
            inline for (0..count) |i| {
                if (large_columns[i]) {
                    flags |= 1 << i;
                }
            }
            return .{ .flags = flags };
        }
        pub fn rowSize(self: Self, comptime T: type) T {
            return @as(T, 2) * @as(T, @popCount(self.flags)) + @as(T, 2) * count;
        }
        pub fn get(self: Self, comptime index: anytype) bool {
            if (index >= count) @compileError("index too large");
            return 0 != ((1 << index) & self.flags);
        }
    };
}

pub const LargeColumnsPerTable = struct {
    Module: LargeColumns(columnCount(.Module)),
    TypeRef: LargeColumns(columnCount(.TypeRef)),
    TypeDef: LargeColumns(columnCount(.TypeDef)),
    Field: LargeColumns(columnCount(.Field)),
    MethodDef: LargeColumns(columnCount(.MethodDef)),
    Param: LargeColumns(columnCount(.Param)),
    InterfaceImpl: LargeColumns(columnCount(.InterfaceImpl)),
    MemberRef: LargeColumns(columnCount(.MemberRef)),
    Constant: LargeColumns(columnCount(.Constant)),
    CustomAttr: LargeColumns(columnCount(.CustomAttr)),
    FieldMarshal: LargeColumns(columnCount(.FieldMarshal)),
    DeclSecurity: LargeColumns(columnCount(.DeclSecurity)),
    ClassLayout: LargeColumns(columnCount(.ClassLayout)),
    FieldLayout: LargeColumns(columnCount(.FieldLayout)),
    StandAloneSig: LargeColumns(columnCount(.StandAloneSig)),
    EventMap: LargeColumns(columnCount(.EventMap)),
    Event: LargeColumns(columnCount(.Event)),
    PropertyMap: LargeColumns(columnCount(.PropertyMap)),
    Property: LargeColumns(columnCount(.Property)),
    MethodSemantics: LargeColumns(columnCount(.MethodSemantics)),
    MethodImpl: LargeColumns(columnCount(.MethodImpl)),
    ModuleRef: LargeColumns(columnCount(.ModuleRef)),
    TypeSpec: LargeColumns(columnCount(.TypeSpec)),
    ImplMap: LargeColumns(columnCount(.ImplMap)),
    FieldRva: LargeColumns(columnCount(.FieldRva)),
    Assembly: LargeColumns(columnCount(.Assembly)),
    AssemblyProcessor: LargeColumns(columnCount(.AssemblyProcessor)),
    AssemblyOs: LargeColumns(columnCount(.AssemblyOs)),
    AssemblyRef: LargeColumns(columnCount(.AssemblyRef)),
    AssemblyRefProcessor: LargeColumns(columnCount(.AssemblyRefProcessor)),
    AssemblyRefOs: LargeColumns(columnCount(.AssemblyRefOs)),
    File: LargeColumns(columnCount(.File)),
    ExportedType: LargeColumns(columnCount(.ExportedType)),
    ManifestResource: LargeColumns(columnCount(.ManifestResource)),
    NestedClass: LargeColumns(columnCount(.NestedClass)),
    GenericParam: LargeColumns(columnCount(.GenericParam)),
    MethodSpec: LargeColumns(columnCount(.MethodSpec)),
    GenericParamConstraint: LargeColumns(columnCount(.GenericParamConstraint)),

    pub fn rowSize(large_columns: *const LargeColumnsPerTable, comptime T: type, table: Table) T {
        return switch (table) {
            inline else => |table_ct| @field(large_columns, @tagName(table_ct)).rowSize(T),
        };
    }
};

pub const TableOffsets = ValuePerTable(u32);

pub fn tableOffsets(
    heap_sizes: HeapSizes,
    row_counts: *const ValuePerTable(u32),
    large_columns: *LargeColumnsPerTable,
) TableOffsets {
    // TODO: this will be set to true only if the "#JTD" stream is present
    //       but I'm not currently looking for this stream
    const is_minimal_delta = false;

    const large_field_refs = is_minimal_delta or
        // (row_counts.field_ptr > std.math.maxInt(u16)) or
        (row_counts.Field > std.math.maxInt(u16));
    const large_method_refs = is_minimal_delta or
        // (row_counts.method_ptr > std.math.maxInt(u16)) or
        (row_counts.MethodDef > std.math.maxInt(u16));
    const large_param_refs = is_minimal_delta or
        // (row_counts.param_ptr > std.math.maxInt(u16)) or
        (row_counts.Param > std.math.maxInt(u16));
    const large_event_refs = is_minimal_delta or
        // (row_counts.event_ptr > std.math.maxInt(u16)) or
        (row_counts.Event > std.math.maxInt(u16));
    const large_property_refs = is_minimal_delta or
        // (row_counts.property_ptr > std.math.maxInt(u16)) or
        (row_counts.Property > std.math.maxInt(u16));

    std.log.info(
        "large refs fields={} methods={} params={} events={} properties={}",
        .{
            large_field_refs,
            large_method_refs,
            large_param_refs,
            large_event_refs,
            large_property_refs,
        },
    );

    const large_string_indices = heap_sizes.strings == 1;
    const large_guid_indices = heap_sizes.guid == 1;
    const large_blob_indices = heap_sizes.blob == 1;

    const large_type_def_or_refs = compositeLargeIndices(3, .{
        row_counts.TypeRef,
        row_counts.TypeDef,
        row_counts.TypeSpec,
    });
    const large_member_ref_parent = compositeLargeIndices(5, .{
        row_counts.TypeDef,
        row_counts.TypeRef,
        row_counts.ModuleRef,
        row_counts.MethodDef,
        row_counts.TypeSpec,
    });
    const large_has_custom_attr = compositeLargeIndices(21, .{
        row_counts.MethodDef,
        row_counts.Field,
        row_counts.TypeRef,
        row_counts.TypeDef,
        row_counts.Param,
        row_counts.InterfaceImpl,
        row_counts.MemberRef,
        row_counts.Module,
        row_counts.Property,
        row_counts.Event,
        row_counts.StandAloneSig,
        row_counts.ModuleRef,
        row_counts.TypeSpec,
        row_counts.Assembly,
        row_counts.AssemblyRef,
        row_counts.File,
        row_counts.ExportedType,
        row_counts.ManifestResource,
        row_counts.GenericParam,
        row_counts.GenericParamConstraint,
        row_counts.MethodSpec,
    });
    const large_custom_attr_type = compositeLargeIndices(4, .{
        row_counts.MethodDef,
        row_counts.MemberRef,
        0,
        0,
    });
    const large_resolution_scopes = compositeLargeIndices(4, .{
        row_counts.Module,
        row_counts.ModuleRef,
        row_counts.AssemblyRef,
        row_counts.TypeRef,
    });
    const large_has_field_marshal = compositeLargeIndices(2, .{
        row_counts.Field,
        row_counts.Param,
    });
    const large_has_decl_security = compositeLargeIndices(3, .{
        row_counts.TypeDef,
        row_counts.MethodDef,
        row_counts.Assembly,
    });
    const large_has_semantics = compositeLargeIndices(2, .{
        row_counts.Event,
        row_counts.Property,
    });

    const large_method_def_or_ref = compositeLargeIndices(2, .{
        row_counts.MethodDef,
        row_counts.MemberRef,
    });
    const large_member_forwarded = compositeLargeIndices(2, .{
        row_counts.Field,
        row_counts.MethodDef,
    });
    const large_implementation = compositeLargeIndices(3, .{
        row_counts.File,
        row_counts.AssemblyRef,
        row_counts.ExportedType,
    });
    const large_type_or_method_def = compositeLargeIndices(2, .{
        row_counts.TypeDef,
        row_counts.MethodDef,
    });

    large_columns.* = .{
        .Module = .init(.{
            false, // Generation (2)
            large_string_indices,
            large_guid_indices,
            large_guid_indices,
            large_guid_indices,
        }),
        .TypeRef = .init(.{
            large_resolution_scopes,
            large_string_indices,
            large_string_indices,
        }),
        .TypeDef = .init(.{
            true, // Flags (4)
            large_string_indices,
            large_string_indices,
            large_type_def_or_refs,
            is_minimal_delta or (row_counts.Field > std.math.maxInt(u16)),
            is_minimal_delta or (row_counts.MethodDef > std.math.maxInt(u16)),
        }),
        .Field = .init(.{
            false, // Flags (2)
            large_string_indices,
            large_blob_indices,
        }),
        .MethodDef = .init(.{
            true, // RVA (4)
            false, // ImplFlags (2)
            false, // Flags (2)
            large_string_indices,
            large_blob_indices,
            large_param_refs,
        }),
        .Param = .init(.{
            false, // Flags (2)
            false, // Sequence (2)
            large_string_indices,
        }),
        .InterfaceImpl = .init(.{
            row_counts.TypeDef > std.math.maxInt(u16),
            large_type_def_or_refs,
        }),
        .MemberRef = .init(.{
            large_member_ref_parent,
            large_string_indices,
            large_blob_indices,
        }),
        .Constant = .init(.{
            false, // Type (2, padded)
            compositeLargeIndices(3, .{
                row_counts.Field,
                row_counts.Param,
                row_counts.Property,
            }),
            large_blob_indices,
        }),
        .CustomAttr = .init(.{
            large_has_custom_attr,
            large_custom_attr_type,
            large_blob_indices,
        }),
        .FieldMarshal = .init(.{
            large_has_field_marshal,
            large_blob_indices,
        }),
        .DeclSecurity = .init(.{
            false, // Action (2)
            large_has_decl_security,
            large_blob_indices,
        }),
        .ClassLayout = .init(.{
            false, // PackingSize (2)
            true, // ClassSize (4)
            row_counts.TypeDef > std.math.maxInt(u16),
        }),
        .FieldLayout = .init(.{
            true, // Offset (4)
            large_field_refs,
        }),
        .StandAloneSig = .init(.{
            large_blob_indices,
        }),
        .EventMap = .init(.{
            row_counts.TypeDef > std.math.maxInt(u16),
            large_event_refs,
        }),
        .Event = .init(.{
            false, // EventFlags (2)
            large_string_indices,
            large_type_def_or_refs,
        }),
        .PropertyMap = .init(.{
            row_counts.TypeDef > std.math.maxInt(u16),
            large_property_refs,
        }),
        .Property = .init(.{
            false, // Flags (2)
            large_string_indices,
            large_blob_indices,
        }),
        .MethodSemantics = .init(.{
            false, // Semantics (2)
            large_method_refs,
            large_has_semantics,
        }),
        .MethodImpl = .init(.{
            row_counts.TypeDef > std.math.maxInt(u16),
            large_method_def_or_ref,
            large_method_def_or_ref,
        }),
        .ModuleRef = .init(.{
            large_string_indices,
        }),
        .TypeSpec = .init(.{
            large_blob_indices,
        }),
        .ImplMap = .init(.{
            false, // MappingFlags (2)
            large_member_forwarded,
            large_string_indices,
            row_counts.ModuleRef > std.math.maxInt(u16),
        }),
        .FieldRva = .init(.{
            true, // RVA (4)
            large_field_refs,
        }),
        .Assembly = .init(.{
            true, // HashAlgId (4)
            true, // AssemblyVersion (4)
            true, // AssemblyBuild (4)
            true, // Flags (4)
            large_blob_indices,
            large_string_indices,
            large_string_indices,
        }),
        .AssemblyProcessor = .init(.{
            true, // Processor (4)
        }),
        .AssemblyOs = .init(.{
            true, // OSPlatformID (4)
            true, // OSMajorVersion (4)
            true, // OSMinorVersion (4)
        }),
        .AssemblyRef = .init(.{
            true, // AssemblyVersion (4)
            true, // AssemblyBuild (4)
            true, // Flags (4)
            large_blob_indices,
            large_string_indices,
            large_string_indices,
            large_blob_indices,
        }),
        .AssemblyRefProcessor = .init(.{
            true, // Processor (4)
            row_counts.AssemblyRef > std.math.maxInt(u16),
        }),
        .AssemblyRefOs = .init(.{
            true, // OSPlatformID (4)
            true, // OSMajorVersion (4)
            true, // OSMinorVersion (4)
            row_counts.AssemblyRef > std.math.maxInt(u16),
        }),
        .File = .init(.{
            true, // Flags (4)
            large_string_indices,
            large_blob_indices,
        }),
        .ExportedType = .init(.{
            true, // Flags (4)
            true, // TypeDefId (4)
            large_string_indices,
            large_string_indices,
            large_implementation,
        }),
        .ManifestResource = .init(.{
            true, // Offset (4)
            true, // Flags (4)
            large_string_indices,
            large_implementation,
        }),
        .NestedClass = .init(.{
            row_counts.TypeDef > std.math.maxInt(u16),
            row_counts.TypeDef > std.math.maxInt(u16),
        }),
        .GenericParam = .init(.{
            false, // Number (2)
            false, // Flags (2)
            large_type_or_method_def,
            large_string_indices,
        }),
        .MethodSpec = .init(.{
            large_method_def_or_ref,
            large_blob_indices,
        }),
        .GenericParamConstraint = .init(.{
            row_counts.GenericParam > std.math.maxInt(u16),
            large_type_def_or_refs,
        }),
    };

    var table_offsets: TableOffsets = undefined;
    var offset: u32 = 0;
    for (std.enums.values(Table)) |table| {
        table_offsets.valRef(table).* = offset;
        offset += large_columns.rowSize(u32, table) * row_counts.val(table);
    }

    return table_offsets;
}

fn compositeLargeIndices(comptime count: usize, row_counts: [count]u32) bool {
    const bits_taken = switch (count) {
        0 => @compileError("must have at least 1 row"),
        1 => 0,
        2 => 1,
        3, 4 => 2,
        5...7 => 3,
        8...15 => 4,
        16...31 => 5,
        else => @compileError("too many rows"),
    };
    const short_row_count_limit = 1 << (16 - bits_taken);
    for (row_counts) |row_count| {
        if (row_count >= short_row_count_limit) return true;
    }
    return false;
}

pub fn getString(string_heap: ?[]const u8, index: StringHeapIndex) ?[:0]const u8 {
    // bits:
    //     31: IsVirtual
    // 29..31: type (non-virtual: String, DotTerminatedString; virtual: VirtualString, WinRTPrefixedString)
    //  0..28: Heap offset or Virtual index
    //private readonly uint _value;
    //if ((index & 0xE000_0000) != 0) std.debug.panic("todo: handle string index 0x{x}", .{index});

    const mem = string_heap orelse return null;
    if (@intFromEnum(index) >= mem.len) return null;
    const string = mem[@intFromEnum(index)..];

    var len: usize = 0;
    while (true) {
        if (string[len] == 0) return string[0..len :0];
        len += 1;
        if (len >= string.len) return null;
    }
}
pub fn getBlob(blob_heap: ?[]const u8, index: BlobHeapIndex) ?[]const u8 {
    // not sure if this is right?
    //if (index == 0) @panic("todo: not sure if blob index of 0 is valid or not?");
    const mem = blob_heap orelse return null;
    if (@intFromEnum(index) >= mem.len) std.debug.panic("blob index {} is too big (limit is {})", .{ index, mem.len });

    const blobLenLen = decodeSigUnsignedLen(mem[@intFromEnum(index)]);
    const data_index = @intFromEnum(index) +% @as(u32, @intFromEnum(blobLenLen));
    if (data_index >= mem.len) std.debug.panic("blob index {} references memory past end of heap (limit is {})", .{ index, mem.len });
    const blob_len = decodeSigUnsigned(mem[@intFromEnum(index)..]);
    const data = mem[data_index..];
    if (blob_len > data.len) std.debug.panic("blob index {} references memory past end of heap (limit is {})", .{ index, mem.len });
    return data[0..blob_len];
}

pub const ElementType = enum(u8) {
    end = 0x00,
    void = 0x01,
    boolean = 0x02,
    char = 0x03,
    i1 = 0x04,
    u1 = 0x05,
    i2 = 0x06,
    u2 = 0x07,
    i4 = 0x08,
    u4 = 0x09,
    i8 = 0x0a,
    u8 = 0x0b,
    r4 = 0x0c,
    r8 = 0x0d,
    string = 0x0e,
    ptr = 0x0f, // followed by type
    byref = 0x10, // followed by type
    valuetype = 0x11, // followed by TypeDef or TypeRef token
    class = 0x12, // followed by TypeDef or TypeRef token
    @"var" = 0x13, // generic parameter in a generic type definition (unsigned integer)
    array = 0x14, // type rank boundsCount bound1 ... loCount lo1
    genericinst = 0x15, // generic type instantiation. Followed by type type-arg-coutn type-1 ... type-n
    typed_byref = 0x16,
    intptr = 0x18, // System.IntPtr
    uintptr = 0x19, // System.UintPtr
    fnptr = 0x1b, // followed by full method signature
    object = 0x1c, // System.Object
    szarray = 0x1d, // single-dim array with 0 lower bound
    mvar = 0x1e, // generic parameter in a generic method definition (unsigned integer)
    // there's more....

    pub fn decodeU32(byte: u32) ?ElementType {
        return decode(std.math.cast(u8, byte) orelse return null);
    }
    pub fn decode(byte: u8) ?ElementType {
        return switch (byte) {
            @intFromEnum(ElementType.end) => .end,
            @intFromEnum(ElementType.void) => .void,
            @intFromEnum(ElementType.boolean) => .boolean,
            @intFromEnum(ElementType.char) => .char,
            @intFromEnum(ElementType.i1) => .i1,
            @intFromEnum(ElementType.u1) => .u1,
            @intFromEnum(ElementType.i2) => .i2,
            @intFromEnum(ElementType.u2) => .u2,
            @intFromEnum(ElementType.i4) => .i4,
            @intFromEnum(ElementType.u4) => .u4,
            @intFromEnum(ElementType.i8) => .i8,
            @intFromEnum(ElementType.u8) => .u8,
            @intFromEnum(ElementType.r4) => .r4,
            @intFromEnum(ElementType.r8) => .r8,
            @intFromEnum(ElementType.string) => .string,
            @intFromEnum(ElementType.ptr) => .ptr,
            @intFromEnum(ElementType.byref) => .byref,
            @intFromEnum(ElementType.valuetype) => .valuetype,
            @intFromEnum(ElementType.class) => .class,
            @intFromEnum(ElementType.@"var") => .@"var",
            @intFromEnum(ElementType.array) => .array,
            @intFromEnum(ElementType.genericinst) => .genericinst,
            @intFromEnum(ElementType.typed_byref) => .typed_byref,
            @intFromEnum(ElementType.intptr) => .intptr,
            @intFromEnum(ElementType.uintptr) => .uintptr,
            @intFromEnum(ElementType.fnptr) => .fnptr,
            @intFromEnum(ElementType.object) => .object,
            @intFromEnum(ElementType.szarray) => .szarray,
            @intFromEnum(ElementType.mvar) => .mvar,
            else => null,
        };
    }
};

const SigUnsignedLen = enum(u3) {
    _1 = 1,
    _2 = 2,
    _4 = 4,
    pub fn int(len: SigUnsignedLen, T: type) T {
        return @intFromEnum(len);
    }
};
pub fn decodeSigUnsignedLen(first_byte: u8) SigUnsignedLen {
    if (0b00000000 == (first_byte & 0b10000000)) return ._1;
    if (0b10000000 == (first_byte & 0b11000000)) return ._2;
    return ._4;
}

pub fn decodeSigUnsigned(bytes: []const u8) u29 {
    return switch (decodeSigUnsignedLen(bytes[0])) {
        ._1 => return bytes[0],
        ._2 => return (@as(u16, bytes[0] & 0x3f) << 8) | bytes[1],
        ._4 => return (@as(u29, bytes[0] & 0x1f) << 24) |
            (@as(u29, bytes[1]) << 16) |
            (@as(u29, bytes[2]) << 8) |
            (@as(u29, bytes[3]) << 0),
    };
}

pub fn NonExhaustive(comptime T: type) type {
    const info = switch (@typeInfo(T)) {
        .@"enum" => |info| info,
        else => |info| @compileError("expected an Enum type but got a(n) " ++ @tagName(info)),
    };
    std.debug.assert(info.is_exhaustive);
    return @Type(std.builtin.Type{ .@"enum" = .{
        .tag_type = info.tag_type,
        .fields = info.fields,
        .decls = &.{},
        .is_exhaustive = false,
    } });
}

pub const TypeTable = enum(u2) {
    TypeDef = 0,
    TypeRef = 1,
    TypeSpec = 2,
};

pub const TypeToken = enum(u29) {
    _,
    pub fn decode(token: TypeToken) error{InvalidTable}!struct {
        table: NonExhaustive(TypeTable),
        index: u27,
    } {
        return .{
            .table = switch (@as(u2, @intCast(3 & @intFromEnum(token)))) {
                0 => .TypeDef,
                1 => .TypeRef,
                2 => .TypeSpec,
                else => return error.InvalidTable,
            },
            .index = @intCast((@intFromEnum(token) >> 2) - 1),
        };
    }
};

pub const Type = packed struct(u32) {
    table: NonExhaustive(TypeTable),
    index: OptionalIndex(u30),

    pub fn value(typ: Type) ?struct { table: NonExhaustive(TypeTable), index: u30 } {
        return if (typ.index.asIndex()) |index|
            .{ .table = typ.table, .index = index }
        else
            null;
    }
};

pub const ConstantParent = packed struct(u32) {
    table: NonExhaustive(ConstantParent.Table),
    index: OptionalIndex(u30),

    pub const Table = enum(u2) { Field = 0, Param = 1, Property = 2 };

    pub fn init(table: ConstantParent.Table, index: u30) ConstantParent {
        return .{
            .table = @enumFromInt(@intFromEnum(table)),
            .index = .fromIndex(index),
        };
    }
};

pub const MemberRefParent = packed struct(u32) {
    table: NonExhaustive(MemberRefParent.Table),
    index: OptionalIndex(u29),

    pub const Table = enum(u3) { TypeDef = 0, TypeRef = 1, ModuleRef = 2, MethodDef = 3, TypeSpec = 4 };
};

pub const MemberForwarded = packed struct(u32) {
    table: enum(u1) { Field = 0, MethodDef = 1 },
    index: OptionalIndex(u31),
};

pub const ResolutionScope = packed struct(u32) {
    table: enum(u2) { Module = 0, ModuleRef = 1, AssemblyRef = 2, TypeRef = 3 },
    index: OptionalIndex(u30),
};

pub const CustomAttrMethod = packed struct(u32) {
    table: NonExhaustive(CustomAttrMethod.Table),
    index: OptionalIndex(u29),

    pub const Table = enum(u3) { MethodDef = 2, MemberRef = 3 };

    pub fn format(method: CustomAttrMethod, writer: *std.Io.Writer) error{WriteFailed}!void {
        if (method.index.asIndex()) |index|
            try writer.print("{t}:{}", .{ method.table, index })
        else
            try writer.writeAll("null");
    }
};

pub const CustomAttrParent = packed struct(u32) {
    table: NonExhaustive(CustomAttrParent.Table),
    index: OptionalIndex(u27),

    pub fn init(table: CustomAttrParent.Table, index: u27) CustomAttrParent {
        return .{
            .table = @enumFromInt(@intFromEnum(table)),
            .index = .fromIndex(index),
        };
    }

    pub fn format(parent: CustomAttrParent, writer: *std.Io.Writer) error{WriteFailed}!void {
        if (parent.index.asIndex()) |index|
            try writer.print("{t}:{}", .{ parent.table, index })
        else
            try writer.writeAll("null");
    }

    pub const Table = enum(u5) {
        MethodDef = 0,
        Field = 1,
        TypeRef = 2,
        TypeDef = 3,
        Param = 4,
        InterfaceImpl = 5,
        MemberRef = 6,
        Module = 7,
        Permission = 8,
        Property = 9,
        Event = 10,
        StandAloneSig = 11,
        ModuleRef = 12,
        TypeSpec = 13,
        Assembly = 14,
        AssemblyRef = 15,
        File = 16,
        ExportedType = 17,
        ManifestResource = 18,
        GenericParam = 19,
        GenericParamConstraint = 20,
        MethodSpec = 21,
    };
};

pub const Visibility = enum(u3) {
    not_public = 0,
    public = 1,
    nested_public = 2,
    nested_private = 3,
    nested_family = 4,
    nested_assembly = 5,
    nested_family_and_assembly = 6,
    nested_family_or_assembly = 7,
    pub fn isNested(visibility: Visibility) bool {
        return switch (visibility) {
            .not_public, .public => false,
            .nested_public,
            .nested_private,
            .nested_family,
            .nested_assembly,
            .nested_family_and_assembly,
            .nested_family_or_assembly,
            => true,
        };
    }
};
pub const Layout = enum(u2) {
    auto = 0,
    sequential = 1,
    explicit = 2,
    invalid = 3,
};
pub const StringFormat = enum(u2) {
    ansi = 0,
    unicode = 1,
    auto = 2,
    custom = 3,
};
pub const TypeAttributes = packed struct(u32) {
    visibility: Visibility,
    layout: Layout,
    interface: bool,
    reserved0: bool,
    abstract: bool,
    sealed: bool,
    reserved1: bool,
    special_name: bool,
    rt_special_name: bool,
    import: bool,
    serializable: bool,
    reserved2: u2,
    format: StringFormat,
    has_security: bool,
    reserved3: u2,
    is_type_forwarder: bool,
    custom_format: u2,
    before_field_init: bool,
    reserved4: u7,
};

pub const MethodAccessBits = enum(u3) {
    compiler_controlled = 0,
    private = 1,
    family_and_assembly = 2,
    assembly = 3,
    family = 4,
    family_or_assembly = 5,
    public = 6,
    invalid = 7,
};

pub const MethodAttributes = packed struct(u32) {
    access: MethodAccessBits,
    unmanaged_export: bool,
    static: bool,
    final: bool,
    virtual: bool,
    hide_by_sig: bool,
    new_slot: bool,
    strict: bool,
    abstract: bool,
    special_name: bool,
    rt_special_name: bool,
    pinvoke_impl: bool,
    has_security: bool,
    require_sec_object: bool,
    padding: u16 = 0,
};

pub const ParamAttributes = packed struct(u32) {
    in: bool,
    out: bool,
    reserved_2: u2 = 0,
    optional: bool,
    reserved_5: u7 = 0,
    has_default: bool,
    has_field_marshal: bool,
    reserved_14: u2 = 0,
    padding: u16 = 0,
};

pub const MethodImplAttributes = packed struct(u32) {
    code_type: enum(u2) {
        il = 0,
        native = 1,
        optil = 2,
        runtime = 3,
    },
    unmanaged: bool,
    no_inlining: bool,
    forward_ref: bool,
    synchronized: bool,
    no_optimization: bool,
    preserve_sig: bool,
    aggressive_inlining: bool,
    reserved_9: u3 = 0,
    internal_call: bool,
    reserved_13: u3 = 0,
    padding: u16 = 0,
};

pub const LinkIterator = struct {
    links: []const OptionalIndex(u32),
    index: OptionalIndex(u32),
    pub fn next(self: *LinkIterator) ?u32 {
        const index = self.index.asIndex() orelse return null;
        self.index = self.links[index];
        return index;
    }
};

/// A hash map for the given table
pub fn Map(table: Table) type {
    return @field(map, @tagName(table));
}
const map = struct {
    // TODO: use links and make InterfaceImpl return an iterator
    pub const InterfaceImpl = struct {
        store: std.AutoHashMapUnmanaged(u32, Type),
        pub fn alloc(allocator: std.mem.Allocator, tables: *const Tables) error{OutOfMemory}!InterfaceImpl {
            var result: InterfaceImpl = .{ .store = .{} };
            errdefer result.deinit(allocator);
            try result.store.ensureTotalCapacity(allocator, tables.row_counts.InterfaceImpl);
            for (0..tables.row_counts.InterfaceImpl) |i| {
                const interface = tables.row(.InterfaceImpl, i);
                const entry = result.store.getOrPutAssumeCapacity(interface.class.asIndex().?);
                if (entry.found_existing) std.debug.panic(
                    "class (TypeDef index {}) has multiple InterfaceImpl entries",
                    .{interface.class.asIndex().?},
                );
                entry.value_ptr.* = interface.interface;
            }
            return result;
        }
        pub fn deinit(self: *InterfaceImpl, allocator: std.mem.Allocator) void {
            self.store.deinit(allocator);
            self.* = undefined;
        }
        pub fn get(self: *const InterfaceImpl, type_def_index: u32) ?Type {
            return self.store.get(type_def_index);
        }
    };

    pub const Constant = struct {
        store: std.AutoHashMapUnmanaged(ConstantParent, u32),
        pub fn alloc(allocator: std.mem.Allocator, tables: *const Tables) error{OutOfMemory}!Constant {
            var result: Constant = .{ .store = .{} };
            errdefer result.deinit(allocator);
            try result.store.ensureTotalCapacity(allocator, tables.row_counts.Constant);
            for (0..tables.row_counts.Constant) |i| {
                const constant = tables.row(.Constant, i);
                const entry = result.store.getOrPutAssumeCapacity(constant.parent);
                if (entry.found_existing) std.debug.panic(
                    "multiple Constant entries for {}",
                    .{constant.parent},
                );
                entry.value_ptr.* = @intCast(i);
            }
            return result;
        }
        pub fn deinit(self: *Constant, allocator: std.mem.Allocator) void {
            self.store.deinit(allocator);
            self.* = undefined;
        }
        pub fn get(self: *const Constant, item: ConstantParent) ?u32 {
            return self.store.get(item);
        }
    };

    pub const CustomAttr = struct {
        links: []const OptionalIndex(u32),
        store: std.AutoHashMapUnmanaged(CustomAttrParent, u32),
        pub fn alloc(
            allocator: std.mem.Allocator,
            tables: *const Tables,
            opt: struct { reverse: bool = false },
        ) error{OutOfMemory}!CustomAttr {
            const links = try allocator.alloc(OptionalIndex(u32), tables.row_counts.CustomAttr);
            errdefer allocator.free(links);
            var store: std.AutoHashMapUnmanaged(CustomAttrParent, u32) = .{};
            errdefer store.deinit(allocator);
            try store.ensureTotalCapacity(allocator, tables.row_counts.CustomAttr);
            for (0..tables.row_counts.CustomAttr) |counter| {
                const i = if (opt.reverse) tables.row_counts.CustomAttr - 1 - counter else counter;
                const constant = tables.row(.CustomAttr, i);
                const entry = store.getOrPutAssumeCapacity(constant.parent);
                links[i] = if (entry.found_existing) .fromIndex(entry.value_ptr.*) else .none;
                entry.value_ptr.* = @intCast(i);
            }
            return .{ .links = links, .store = store };
        }
        pub fn deinit(self: *CustomAttr, allocator: std.mem.Allocator) void {
            self.store.deinit(allocator);
            allocator.free(self.links);
            self.* = undefined;
        }
        pub fn getIterator(self: *const CustomAttr, parent: CustomAttrParent) LinkIterator {
            return .{
                .links = self.links,
                .index = if (self.store.get(parent)) |i| .fromIndex(i) else .none,
            };
        }
    };

    pub const ClassLayout = struct {
        store: std.AutoHashMapUnmanaged(u32, u32),
        pub fn init(allocator: std.mem.Allocator, tables: *const Tables) error{OutOfMemory}!ClassLayout {
            var result: ClassLayout = .{ .store = .{} };
            errdefer result.deinit(allocator);
            try result.store.ensureTotalCapacity(allocator, tables.row_counts.ClassLayout);
            for (0..tables.row_counts.ClassLayout) |i| {
                const layout = tables.row(.ClassLayout, i);
                const entry = result.store.getOrPutAssumeCapacity(layout.parent.asIndex().?);
                if (entry.found_existing) std.debug.panic(
                    "multiple ClassLayout entries for {}",
                    .{layout.parent.asIndex().?},
                );
                entry.value_ptr.* = @intCast(i);
            }
            return result;
        }
        pub fn deinit(self: *ClassLayout, allocator: std.mem.Allocator) void {
            self.store.deinit(allocator);
            self.* = undefined;
        }
        pub fn get(self: *const ClassLayout, type_def_index: u32) ?u32 {
            return self.store.get(type_def_index);
        }
    };

    pub const ImplMap = struct {
        store: std.AutoHashMapUnmanaged(MemberForwarded, u32),
        pub fn alloc(allocator: std.mem.Allocator, tables: *const Tables) error{OutOfMemory}!ImplMap {
            var result: ImplMap = .{ .store = .{} };
            errdefer result.deinit(allocator);
            try result.store.ensureTotalCapacity(allocator, tables.row_counts.ImplMap);
            for (0..tables.row_counts.ImplMap) |i| {
                const impl_map = tables.row(.ImplMap, i);
                const entry = result.store.getOrPutAssumeCapacity(impl_map.member_forwarded);
                if (entry.found_existing) std.debug.panic(
                    "multiple ImplMap entries for {}",
                    .{impl_map.member_forwarded},
                );
                entry.value_ptr.* = @intCast(i);
            }
            return result;
        }
        pub fn deinit(self: *ImplMap, allocator: std.mem.Allocator) void {
            self.store.deinit(allocator);
            self.* = undefined;
        }
        pub fn get(self: *const ImplMap, item: MemberForwarded) ?u32 {
            return self.store.get(item);
        }
    };

    pub const NestedClass = struct {
        links: []const OptionalIndex(u32),
        store: std.AutoHashMapUnmanaged(u32, u32),
        pub fn alloc(allocator: std.mem.Allocator, tables: *const Tables) error{OutOfMemory}!NestedClass {
            const links = try allocator.alloc(OptionalIndex(u32), tables.row_counts.NestedClass);
            errdefer allocator.free(links);
            var store: std.AutoHashMapUnmanaged(u32, u32) = .{};
            errdefer store.deinit(allocator);
            try store.ensureTotalCapacity(allocator, tables.row_counts.NestedClass);
            for (0..tables.row_counts.NestedClass) |i| {
                const nested_entry = tables.row(.NestedClass, i);
                const entry = store.getOrPutAssumeCapacity(nested_entry.enclosing.asIndex().?);
                links[i] = if (entry.found_existing) .fromIndex(entry.value_ptr.*) else .none;
                entry.value_ptr.* = @intCast(i);
            }
            return .{ .links = links, .store = store };
        }
        pub fn deinit(self: *NestedClass, allocator: std.mem.Allocator) void {
            self.store.deinit(allocator);
            allocator.free(self.links);
            self.* = undefined;
        }
        /// Get an iterator for all nested types for the given type_def_index.
        pub fn getIterator(self: *const NestedClass, type_def_index: u32) LinkIterator {
            return .{
                .links = self.links,
                .index = if (self.store.get(type_def_index)) |i| .fromIndex(i) else .none,
            };
        }
    };
};
