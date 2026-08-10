const sdl = @import("sdl");
const std = @import("std");

pub fn Descriptor(comptime Raw: type) type {
    return struct {
        raw: Raw,
        pub fn fromSdl(value: Raw) @This() {
            return .{ .raw = value };
        }
        pub fn toSdl(self: @This()) Raw {
            return self.raw;
        }
        pub fn default() @This() {
            return .{ .raw = std.mem.zeroes(Raw) };
        }
    };
}

pub const RasterizerState = Descriptor(sdl.gpu.RasterizerState);
pub const DepthStencilState = Descriptor(sdl.gpu.DepthStencilState);
pub const SamplerCreateInfo = Descriptor(sdl.gpu.SamplerCreateInfo);
pub const GraphicsPipelineCreateInfo = Descriptor(sdl.gpu.GraphicsPipelineCreateInfo);
pub const ComputePipelineCreateInfo = Descriptor(sdl.gpu.ComputePipelineCreateInfo);

pub const TextureFormat = struct {
    raw: sdl.gpu.TextureFormat,
    pub fn fromSdl(value: sdl.gpu.TextureFormat) ?TextureFormat {
        if (value == .invalid) return null;
        return .{ .raw = value };
    }
    pub fn toSdl(self: TextureFormat) sdl.gpu.TextureFormat {
        return self.raw;
    }
};

pub const Device = struct {
    raw: sdl.gpu.Device,

    pub const Options = struct {
        format_flags: sdl.gpu.ShaderFormat = 0,
        debug_mode: bool = false,
        name: ?[:0]const u8 = null,
    };

    pub fn init(options: Options) sdl.Error!Device {
        return .{ .raw = try sdl.gpu.createDevice(options.format_flags, options.debug_mode, options.name) };
    }

    pub fn deinit(self: *@This()) void {
        self.raw.deinit();
        self.* = undefined;
    }
};

pub const ShaderFormat = struct {
    raw: sdl.gpu.ShaderFormat,
    pub fn fromSdl(value: sdl.gpu.ShaderFormat) ShaderFormat {
        return .{ .raw = value };
    }
    pub fn toSdl(self: ShaderFormat) sdl.gpu.ShaderFormat {
        return self.raw;
    }
};

pub const BufferUsage = struct {
    raw: sdl.gpu.BufferUsageFlags = 0,
    pub fn fromSdl(value: sdl.gpu.BufferUsageFlags) BufferUsage {
        return .{ .raw = value };
    }
    pub fn toSdl(self: BufferUsage) sdl.gpu.BufferUsageFlags {
        return self.raw;
    }
    pub fn contains(self: BufferUsage, flag: sdl.gpu.BufferUsageFlags) bool {
        return self.raw & flag != 0;
    }
    pub fn with(self: BufferUsage, flag: sdl.gpu.BufferUsageFlags) BufferUsage {
        return .{ .raw = self.raw | flag };
    }
};

pub const TextureUsage = struct {
    raw: sdl.gpu.TextureUsageFlags = 0,
    pub fn fromSdl(value: sdl.gpu.TextureUsageFlags) TextureUsage {
        return .{ .raw = value };
    }
    pub fn toSdl(self: TextureUsage) sdl.gpu.TextureUsageFlags {
        return self.raw;
    }
    pub fn contains(self: TextureUsage, flag: sdl.gpu.TextureUsageFlags) bool {
        return self.raw & flag != 0;
    }
    pub fn with(self: TextureUsage, flag: sdl.gpu.TextureUsageFlags) TextureUsage {
        return .{ .raw = self.raw | flag };
    }
};

pub const BufferLocation = struct {
    buffer: ?*anyopaque = null,
    offset: u32 = 0,
    pub fn toSdl(self: BufferLocation) sdl.gpu.BufferLocation {
        return .{ .buffer = self.buffer, .offset = self.offset };
    }
    pub fn fromSdl(value: sdl.gpu.BufferLocation) BufferLocation {
        return .{ .buffer = value.buffer, .offset = value.offset };
    }
};

pub const TextureLocation = struct {
    texture: ?*anyopaque = null,
    mip_level: u32 = 0,
    layer: u32 = 0,
    x: u32 = 0,
    y: u32 = 0,
    z: u32 = 0,
    pub fn toSdl(self: TextureLocation) sdl.gpu.TextureLocation {
        return .{ .texture = self.texture, .mip_level = self.mip_level, .layer = self.layer, .x = self.x, .y = self.y, .z = self.z };
    }
    pub fn fromSdl(value: sdl.gpu.TextureLocation) TextureLocation {
        return .{ .texture = value.texture, .mip_level = value.mip_level, .layer = value.layer, .x = value.x, .y = value.y, .z = value.z };
    }
};

pub const BufferRegion = struct {
    buffer: ?*anyopaque = null,
    offset: u32 = 0,
    size: u32 = 0,
    pub fn toSdl(self: BufferRegion) sdl.gpu.BufferRegion {
        return .{ .buffer = self.buffer, .offset = self.offset, .size = self.size };
    }
    pub fn fromSdl(value: sdl.gpu.BufferRegion) BufferRegion {
        return .{ .buffer = value.buffer, .offset = value.offset, .size = value.size };
    }
};

pub const TextureRegion = struct {
    texture: ?*anyopaque = null,
    mip_level: u32 = 0,
    layer: u32 = 0,
    x: u32 = 0,
    y: u32 = 0,
    z: u32 = 0,
    w: u32 = 1,
    h: u32 = 1,
    d: u32 = 1,
    pub fn toSdl(self: TextureRegion) sdl.gpu.TextureRegion {
        return .{ .texture = self.texture, .mip_level = self.mip_level, .layer = self.layer, .x = self.x, .y = self.y, .z = self.z, .w = self.w, .h = self.h, .d = self.d };
    }
    pub fn fromSdl(value: sdl.gpu.TextureRegion) TextureRegion {
        return .{ .texture = value.texture, .mip_level = value.mip_level, .layer = value.layer, .x = value.x, .y = value.y, .z = value.z, .w = value.w, .h = value.h, .d = value.d };
    }
};

pub const BufferCreateInfo = struct {
    usage: sdl.gpu.BufferUsageFlags = 0,
    size: u32 = 0,
    props: u32 = 0,
    pub fn toSdl(self: BufferCreateInfo) sdl.gpu.BufferCreateInfo {
        return .{ .usage = self.usage, .size = self.size, .props = self.props };
    }
};

pub const TextureCreateInfo = struct {
    type_: sdl.gpu.TextureType = ._2d,
    format: sdl.gpu.TextureFormat = .invalid,
    usage: sdl.gpu.TextureUsageFlags = 0,
    width: u32 = 1,
    height: u32 = 1,
    layer_count_or_depth: u32 = 1,
    num_levels: u32 = 1,
    sample_count: sdl.gpu.SampleCount = .count1,
    props: u32 = 0,
    pub fn toSdl(self: TextureCreateInfo) sdl.gpu.TextureCreateInfo {
        return .{ .type_ = self.type_, .format = self.format, .usage = self.usage, .width = self.width, .height = self.height, .layer_count_or_depth = self.layer_count_or_depth, .num_levels = self.num_levels, .sample_count = self.sample_count, .props = self.props };
    }
};

pub const raw = sdl.gpu;
