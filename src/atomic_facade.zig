const sdl = @import("sdl");

pub const Int = struct {
    raw: sdl.atomic.Int = .{ .value = 0 },
    pub fn init(value: i32) Int {
        return .{ .raw = .{ .value = value } };
    }
    pub fn get(self: *@This()) i32 {
        return sdl.atomic.getInt(&self.raw);
    }
    pub fn set(self: *@This(), value: i32) i32 {
        return sdl.atomic.setInt(&self.raw, value);
    }
    pub fn add(self: *@This(), value: i32) i32 {
        return sdl.atomic.addInt(&self.raw, value);
    }
    pub fn compareAndSwap(self: *@This(), old: i32, new: i32) bool {
        return sdl.atomic.compareAndSwapInt(&self.raw, old, new);
    }
};

pub const U32 = struct {
    raw: sdl.atomic.U32 = .{ .value = 0 },
    pub fn init(value: u32) U32 {
        return .{ .raw = .{ .value = value } };
    }
    pub fn get(self: *@This()) u32 {
        return sdl.atomic.getU32(&self.raw);
    }
    pub fn set(self: *@This(), value: u32) u32 {
        return sdl.atomic.setU32(&self.raw, value);
    }
    pub fn add(self: *@This(), value: u32) u32 {
        return sdl.atomic.addU32(&self.raw, value);
    }
    pub fn compareAndSwap(self: *@This(), old: u32, new: u32) bool {
        return sdl.atomic.compareAndSwapU32(&self.raw, old, new);
    }
};

pub const Spinlock = struct {
    raw: sdl.atomic.SpinLock = 0,
    pub fn lock(self: *@This()) void {
        sdl.atomic.lockSpinlock(&self.raw);
    }
    pub fn tryLock(self: *@This()) bool {
        return sdl.atomic.tryLockSpinlock(&self.raw);
    }
    pub fn unlock(self: *@This()) void {
        sdl.atomic.unlockSpinlock(&self.raw);
    }
};

pub const raw = sdl.atomic;
