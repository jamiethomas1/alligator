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

    const buffer = try alligator.alligate(u8, 128);
    try expect(@TypeOf(buffer) == []u8);
    try expect(buffer.len == 128);
    try expect(alligator.totalAlligated == 128);
}

test "free memory" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) expect(false) catch @panic("TEST FAILED: GeneralPurposeAllocator leaked memory");
    }

    var alligator = Alligator.init(&gpa.allocator());

    const buffer = try alligator.alligate(u8, 128);
    alligator.free(buffer);
    try expect(alligator.totalFreed == 128);
    try expect(alligator.totalAlligated - alligator.totalFreed == 0);
}

// test "net usage tracking" {
//     var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//     defer {
//         const deinit_status = gpa.deinit();
//         if (deinit_status == .leak) expect(false) catch @panic("TEST FAILED: GeneralPurposeAllocator leaked memory");
//     }
//
//     var alligator = Alligator.init(&gpa.allocator());
//
//     const buffer1 = try alligator.alligate(u8, 128);
//     const buffer2 = try alligator.alligate(u8, 64);
//     alligator.free(buffer1, u8, 128);
//     _ = buffer2;
//
//     try expect(alligator.totalAlligated == 192);
//     try expect(alligator.totalFreed == 128);
//     try expect(alligator.totalAlligated - alligator.totalFreed == 64);
// }
//
// test "double free prevention" {
//     var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//     defer {
//         const deinit_status = gpa.deinit();
//         if (deinit_status == .leak) expect(false) catch @panic("TEST FAILED: GeneralPurposeAllocator leaked memory");
//     }
//
//     var alligator = Alligator.init(&gpa.allocator());
//
//     const buffer = try alligator.alligate(u8, 128);
//     alligator.free(buffer);
//     alligator.free(buffer); // Double free
//
//     try expect(alligator.totalFreed == 128);
// }
//
// test "null free handling" {
//     var gpa = std.heap.GeneralPurposeAllocator(.{}){};
//     defer {
//         const deinit_status = gpa.deinit();
//         if (deinit_status == .leak) expect(false) catch @panic("TEST FAILED: GeneralPurposeAllocator leaked memory");
//     }
//
//     var alligator = Alligator.init(&gpa.allocator());
//
//     alligator.free(null, u8, 128); // Freeing null
//
//     try expect(alligator.totalFreed == 0);
// }
//
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
//     try expect(alligator.totalFreed == 0);
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
//     try expect(alligator.totalFreed == 0);
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
//     try expect(alligator.totalAlligated == 0);
// }
