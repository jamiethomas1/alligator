const std = @import("std");
const expect = std.testing.expect;
const Alligator = @import("alligator.zig").Alligator;

test "alligate memory" {
    var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = false }){}; // Safety false as not implemented free() yet
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) expect(false) catch @panic("TEST FAILED: GeneralPurposeAllocator leaked memory");
    }

    var alligator = Alligator.init(&gpa.allocator());
    defer alligator.deinit();

    const buffer = try alligator.alligate(u8, 128);
    try expect(@TypeOf(buffer) == []u8);
    try expect(buffer.len == 128);
    try expect(alligator.total_alligated == 128);
}

test "free memory" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) expect(false) catch @panic("TEST FAILED: GeneralPurposeAllocator leaked memory");
    }

    var alligator = Alligator.init(&gpa.allocator());
    defer alligator.deinit();

    const buffer = try alligator.alligate(u8, 128);
    alligator.free(u8, buffer);
    try expect(alligator.total_freed == 128);
    try expect(alligator.total_alligated - alligator.total_freed == 0);
}

test "net usage tracking" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) expect(false) catch @panic("TEST FAILED: GeneralPurposeAllocator leaked memory");
    }

    var alligator = Alligator.init(&gpa.allocator());
    defer alligator.deinit();

    const buffer1 = try alligator.alligate(u8, 128);
    const buffer2 = try alligator.alligate(u8, 64);
    alligator.free(u8, buffer1);

    try expect(alligator.total_alligated == 192);
    try expect(alligator.total_freed == 128);
    alligator.free(u8, buffer2);
}

test "double free prevention" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) expect(false) catch @panic("TEST FAILED: GeneralPurposeAllocator leaked memory");
    }

    var alligator = Alligator.init(&gpa.allocator());
    defer alligator.deinit();

    const buffer = try alligator.alligate(u8, 128);
    alligator.free(u8, buffer);
    alligator.free(u8, buffer); // Double free

    try expect(alligator.total_freed == 128);
}

// test "freeing wrong size" {
//     var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//     defer {
//         const deinit_status = gpa.deinit();
//         if (deinit_status == .leak) expect(false) catch @panic("TEST FAILED: GeneralPurposeAllocator leaked memory");
//     }
//
//     var alligator = Alligator.init(&gpa.allocator());
//
//     const buffer = try alligator.alligate(u8, 128);
//     alligator.free(buffer, u8, 64); // Freeing wrong size
//
//     try expect(alligator.total_freed == 0);
// }
//
// test "freeing wrong type" {
//     var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//     defer {
//         const deinit_status = gpa.deinit();
//         if (deinit_status == .leak) expect(false) catch @panic("TEST FAILED: GeneralPurposeAllocator leaked memory");
//     }
//
//     var alligator = Alligator.init(&gpa.allocator());
//
//     const buffer = try alligator.alligate(u8, 128);
//     alligator.free(buffer, u16, 128); // Freeing wrong type
//
//     try expect(alligator.total_freed == 0);
// }
//
// test "zero allocation handling" {
//     var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//     defer {
//         const deinit_status = gpa.deinit();
//         if (deinit_status == .leak) expect(false) catch @panic("TEST FAILED: GeneralPurposeAllocator leaked memory");
//     }
//
//     var alligator = Alligator.init(&gpa.allocator());
//
//     const buffer = try alligator.alligate(u8, 0);
//
//     try expect(buffer == null);
//     try expect(alligator.total_alligated == 0);
// }
