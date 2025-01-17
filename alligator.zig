const std = @import("std");
const Error = std.mem.Allocator.Error;

const AlligationMeta = struct {
    address: *u8,
    size: usize,
};

pub const Alligator = struct {
    base: *const std.mem.Allocator,
    total_alligated: usize,
    total_freed: usize,
    alligations: std.AutoHashMap(*u8, AlligationMeta),

    pub fn init(base: *const std.mem.Allocator) Alligator {
        return Alligator{
            .base = base,
            .total_alligated = 0,
            .total_freed = 0,
            .alligations = std.AutoHashMap(*u8, AlligationMeta).init(base.*),
        };
    }

    pub fn deinit(self: *Alligator) void {
        self.alligations.deinit();
    }

    pub fn alligate(self: *Alligator, comptime T: type, count: usize) Error![]T {
        const buffer: []T = try self.base.alloc(T, count);

        const address = &buffer[0];
        try self.alligations.put(address, AlligationMeta{
            .address = address,
            .size = count * @sizeOf(T),
        });

        self.total_alligated += buffer.len * @sizeOf(T);

        std.debug.print("Added pointer {} with count {} to alligations map\n", .{ address, count });

        return buffer;
    }

    pub fn free(self: *Alligator, comptime T: type, buffer: []T) void {
        const address = &buffer[0];
        const total_to_free = buffer.len * @sizeOf(T);

        std.debug.print("Attempting to free at address {}\n", .{address});

        const alligation: AlligationMeta = self.alligations.get(address) orelse {
            std.debug.print("No alligation found for pointer {}\n", .{address});
            return;
        };

        std.debug.print("Found alligated buffer:\n{}\n", .{alligation});
        std.debug.print("Freeing active buffer: {s}\n", .{address});

        self.base.free(buffer);
        self.total_freed += total_to_free;
        _ = self.alligations.remove(address);
    }
};
