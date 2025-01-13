const std = @import("std");
const expect = std.testing.expect;
const Alligator = @import("alligator.zig");

test "alligate memory" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer gpa.deinit();

    var alligator = Alligator.init(&gpa.allocator);

    const buffer = alligator.alligate(u8, 128) catch expect(false);
    try expect(buffer != null);
    try expect(alligator.totalAlligated == 128);
}

test "free memory" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer gpa.deinit();

    var alligator = Alligator.init(&gpa.allocator);

    const buffer = alligator.alligate(u8, 128) catch expect(false);
    alligator.free(buffer);
    try expect(alligator.totalFreed == 128);
    try expect(alligator.totalAlligated - alligator.totalFreed == 0);
}

test "net usage tracking" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer gpa.deinit();

    var alligator = Alligator.init(&gpa.allocator);

    const buffer1 = alligator.alligate(u8, 128) catch expect(false);
    const buffer2 = alligator.alligate(u8, 64) catch expect(false);
    alligator.free(buffer1, u8, 128);
    _ = buffer2;

    try expect(alligator.totalAlligated == 192);
    try expect(alligator.totalFreed == 128);
    try expect(alligator.totalAlligated - alligator.totalFreed == 64);
}

test "double free prevention" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer gpa.deinit();

    var alligator = Alligator.init(&gpa.allocator);

    const buffer = alligator.alligate(u8, 128) catch expect(false);
    alligator.free(buffer);
    alligator.free(buffer); // Double free

    try expect(alligator.totalFreed == 128);
}

test "null free handling" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer gpa.deinit();

    var alligator = Alligator.init(&gpa.allocator);

    alligator.free(null, u8, 128); // Freeing null

    try expect(alligator.totalFreed == 0);
}

// Continue here
test "freeing wrong size" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer gpa.deinit();

    var alligator = Alligator.init(&gpa.allocator);

    const buffer = alligator.alligate(u8, 128) catch expect(false);
    alligator.free(buffer, u8, 64); // Freeing wrong size

    try expect(alligator.totalFreed == 0);
}

test "freeing wrong type" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer gpa.deinit();

    var alligator = Alligator.init(&gpa.allocator);

    const buffer = alligator.alligate(u8, 128) catch expect(false);
    alligator.free(buffer, u16, 128); // Freeing wrong type

    try expect(alligator.totalFreed == 0);
}

test "zero allocation handling" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer gpa.deinit();

    var alligator = Alligator.init(&gpa.allocator);

    const buffer = alligator.alligate(u8, 0) catch expect(false);

    try expect(buffer == null);
    try expect(alligator.totalAlligated == 0);
}
