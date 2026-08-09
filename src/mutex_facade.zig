const sdl = @import("sdl");

pub const Mutex = struct {
    raw: sdl.mutex.Mutex,
    pub fn init() sdl.Error!Mutex {
        return .{ .raw = try sdl.mutex.create() };
    }
    pub fn deinit(self: *@This()) void {
        self.raw.deinit();
        self.* = undefined;
    }
};

pub const Condition = struct {
    raw: sdl.mutex.Condition,
    pub fn init() sdl.Error!Condition {
        return .{ .raw = try sdl.mutex.createCondition() };
    }
    pub fn deinit(self: *@This()) void {
        self.raw.deinit();
        self.* = undefined;
    }
};

pub const RwLock = struct {
    raw: sdl.mutex.RwLock,
    pub fn init() sdl.Error!RwLock {
        return .{ .raw = try sdl.mutex.createRwLock() };
    }
    pub fn deinit(self: *@This()) void {
        self.raw.deinit();
        self.* = undefined;
    }
};

pub const Semaphore = struct {
    raw: sdl.mutex.Semaphore,
    pub fn init(initial_value: u32) sdl.Error!Semaphore {
        return .{ .raw = try sdl.mutex.createSemaphore(initial_value) };
    }
    pub fn deinit(self: *@This()) void {
        self.raw.deinit();
        self.* = undefined;
    }
};

pub const raw = sdl.mutex;
