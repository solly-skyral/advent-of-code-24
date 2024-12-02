const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn report_safe(levels: std.ArrayList(u32)) bool {
    var increasing = false;
    var decreasing = false;

    var previous_item: u32 = 0;
    for (levels.items) |item| {
        if (previous_item == 0) {
            previous_item = item;
            continue;
        }

        if (item > previous_item) {
            increasing = true;
        }
        if (item < previous_item) {
            decreasing = true;
        }

        if ((item == previous_item) or (increasing and decreasing) or (@abs(@as(i64, item) - previous_item) > 3)) {
            return false;
        }
        previous_item = item;
    }
    return true;
}

pub fn report_safe_skip_level(levels: std.ArrayList(u32), skip: usize) bool {
    var increasing = false;
    var decreasing = false;

    var previous_item: u32 = 0;
    for (levels.items, 0..) |item, i| {
        if (skip == i) {
            continue;
        }

        if (previous_item == 0) {
            previous_item = item;
            continue;
        }

        if (item > previous_item) {
            increasing = true;
        }
        if (item < previous_item) {
            decreasing = true;
        }

        if ((item == previous_item) or (increasing and decreasing) or (@abs(@as(i64, item) - previous_item) > 3)) {
            return false;
        }
        previous_item = item;
    }
    return true;
}

pub fn report_safe_dampened(levels: std.ArrayList(u32)) bool {
    for (levels.items, 0..) |_, i| {
        if (report_safe_skip_level(levels, i)) {
            return true;
        }
    }
    return false;
}

pub fn main() !void {
    const file = @embedFile("input.txt");
    var lines = std.mem.tokenizeScalar(u8, file, '\n');

    var part1: u64 = 0;
    var part2: u64 = 0;
    while (lines.next()) |line| {
        var vals = std.mem.tokenizeAny(u8, line, " ");

        var levels = std.ArrayList(u32).init(allocator);
        defer levels.deinit();
        while (vals.next()) |val| {
            const parsed = try std.fmt.parseInt(u32, val, 10);
            try levels.append(parsed);
        }
        part1 += @intFromBool(report_safe(levels));
        part2 += @intFromBool(report_safe_dampened(levels));
    }

    std.debug.print("{}\n", .{part1});
    std.debug.print("{}\n", .{part2});
}
