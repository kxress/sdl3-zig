const std = @import("std");
const sdl = @import("sdl");

pub const Error = error{
    InvalidMetadata,
    UnsupportedMetadataVersion,
    ShaderNotFound,
    StageMismatch,
    FormatMismatch,
};

pub const Stage = enum { vertex, fragment, compute };

pub const Output = struct {
    path: []const u8,
    sha256: []const u8,
};

const InputShader = struct {
    name: []const u8,
    stage: []const u8,
    entrypoint: []const u8 = "main",
};

const InputManifest = struct {
    version: u32,
    shaders: []InputShader,
};

pub const Shader = struct {
    name: []const u8,
    stage: Stage,
    entrypoint: []const u8,
};

pub const Field = enum { name, stage, entrypoint };

/// Owns parsed shader-manifest JSON and validates lookups against runtime needs.
pub const Metadata = struct {
    arena: std.heap.ArenaAllocator,
    shaders: []Shader,

    pub fn load(allocator: std.mem.Allocator, json: []const u8) !Metadata {
        var arena = std.heap.ArenaAllocator.init(allocator);
        errdefer arena.deinit();
        const parsed = std.json.parseFromSliceLeaky(InputManifest, arena.allocator(), json, .{}) catch
            return error.InvalidMetadata;
        if (parsed.version != 1) return error.UnsupportedMetadataVersion;

        const shaders = try arena.allocator().alloc(Shader, parsed.shaders.len);
        for (parsed.shaders, shaders) |input, *shader| {
            shader.* = .{
                .name = input.name,
                .stage = std.meta.stringToEnum(Stage, input.stage) orelse return error.InvalidMetadata,
                .entrypoint = input.entrypoint,
            };
        }
        return .{ .arena = arena, .shaders = shaders };
    }

    pub fn loadEmbedded(allocator: std.mem.Allocator, comptime json: []const u8) !Metadata {
        return load(allocator, json);
    }

    pub fn loadFile(allocator: std.mem.Allocator, path: []const u8) !Metadata {
        const bytes = try std.fs.cwd().readFileAlloc(allocator, path, 16 * 1024 * 1024);
        defer allocator.free(bytes);
        return load(allocator, bytes);
    }

    pub fn deinit(self: *@This()) void {
        self.arena.deinit();
        self.* = undefined;
    }

    pub fn find(self: Metadata, name: []const u8) Error!Shader {
        for (self.shaders) |shader| if (std.mem.eql(u8, shader.name, name)) return shader;
        return error.ShaderNotFound;
    }

    pub fn validate(self: Metadata, name: []const u8, stage: Stage, format: sdl.gpu.ShaderFormat) Error!Shader {
        const shader = try self.find(name);
        if (shader.stage != stage) return error.StageMismatch;
        if (format == 0) return error.FormatMismatch;
        return shader;
    }

    pub fn lookup(self: Metadata, name: []const u8, field: Field) Error![]const u8 {
        const shader = try self.find(name);
        return switch (field) {
            .name => shader.name,
            .stage => @tagName(shader.stage),
            .entrypoint => shader.entrypoint,
        };
    }
};

/// Loads shader payloads from a directory using the conventional `<name>.<format>` path.
pub const Directory = struct {
    allocator: std.mem.Allocator,
    root: []u8,
    metadata: Metadata,

    pub fn init(allocator: std.mem.Allocator, root: []const u8) !Directory {
        const owned_root = try allocator.dupe(u8, root);
        errdefer allocator.free(owned_root);
        var manifest_path = try std.fs.path.join(allocator, &.{ root, "shader-manifest.json" });
        defer allocator.free(manifest_path);
        const metadata = Metadata.loadFile(allocator, manifest_path) catch |err| return err;
        return .{ .allocator = allocator, .root = owned_root, .metadata = metadata };
    }

    pub fn deinit(self: *@This()) void {
        self.metadata.deinit();
        self.allocator.free(self.root);
        self.* = undefined;
    }

    pub fn load(self: *@This(), name: []const u8, format: []const u8) ![]u8 {
        _ = try self.metadata.find(name);
        const filename = try std.fmt.allocPrint(self.allocator, "{s}.{s}", .{ name, format });
        defer self.allocator.free(filename);
        const path = try std.fs.path.join(self.allocator, &.{ self.root, filename });
        defer self.allocator.free(path);
        return std.fs.cwd().readFileAlloc(self.allocator, path, 256 * 1024 * 1024);
    }
};

test "metadata loads and validates a shader entry" {
    const json =
        "{\"version\":1,\"shaders\":[{\"name\":\"basic\",\"stage\":\"vertex\"}]}";
    var metadata = try Metadata.load(std.testing.allocator, json);
    defer metadata.deinit();
    const shader = try metadata.validate("basic", .vertex, 1);
    try std.testing.expectEqualStrings("main", shader.entrypoint);
    try std.testing.expectEqualStrings("vertex", try metadata.lookup("basic", .stage));
}
