const std = @import("std");
const Error = std.mem.Allocator.Error;

pub const Alligator = struct {
    base: *const std.mem.Allocator,
    totalAlligated: usize,
    totalFreed: usize,

    pub fn init(base: *const std.mem.Allocator) Alligator {
        return Alligator{
            .base = base,
            .totalAlligated = 0,
            .totalFreed = 0,
        };
    }

    pub fn alligate(self: *Alligator, comptime T: type, count: usize) Error![]T {
        const ptr = try self.base.alloc(T, count);

        self.totalAlligated += ptr.len;

        return ptr;
    }

    pub fn free(self: *Alligator, buffer: anytype) void {
        const totalToFree = buffer.len;
        self.base.free(buffer);
        self.totalFreed += totalToFree;
    }
};
