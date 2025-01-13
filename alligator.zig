const std = @import("std");
const expect = std.testing.expect;

pub const Alligator = struct {
    base: *std.heap.GeneralPurposeAllocator,
    totalAlligator: usize,
    totalFreed: usize,
};
