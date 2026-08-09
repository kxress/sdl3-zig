const sdl = @import("sdl");

pub const Surface = struct {
    instance: sdl.vulkan.VkInstance,
    raw: sdl.vulkan.VkSurfaceKhr,
    allocator: ?*const sdl.vulkan.VkAllocationCallbacks,

    pub fn init(
        window: sdl.video.Window,
        instance: sdl.vulkan.VkInstance,
        allocator: ?*const sdl.vulkan.VkAllocationCallbacks,
    ) sdl.Error!Surface {
        var surface: sdl.vulkan.VkSurfaceKhr = undefined;
        try sdl.vulkan.createSurface(window, instance, allocator, &surface);
        return .{ .instance = instance, .raw = surface, .allocator = allocator };
    }

    pub fn deinit(self: *@This()) void {
        sdl.vulkan.destroySurface(self.instance, self.raw, self.allocator);
        self.* = undefined;
    }
};

pub const loadLibrary = sdl.vulkan.loadLibrary;
pub const unloadLibrary = sdl.vulkan.unloadLibrary;
pub const getVkGetInstanceProcAddr = sdl.vulkan.getVkGetInstanceProcAddr;
pub const getInstanceExtensions = sdl.vulkan.getInstanceExtensions;
pub const raw = sdl.vulkan;
