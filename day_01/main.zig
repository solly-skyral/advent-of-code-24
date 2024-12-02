const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn distance(first: std.ArrayList(i64), second: std.ArrayList(i64)) i64 {
    var acc: i64 = 0;
    for (first.items, second.items) |x, y| {
        acc += @intCast(@abs(x - y));
    }
    return acc;
}

pub fn similarity(first: std.ArrayList(i64), second: std.ArrayList(i64)) !i64 {
    const max_item = std.mem.max(i64, second.items);
    var occurences = try std.ArrayList(u32).initCapacity(allocator, @intCast(max_item + 1));
    occurences.appendNTimesAssumeCapacity(0, @intCast(max_item + 1));
    defer occurences.deinit();

    for (second.items) |item| {
        occurences.items[@intCast(item)] += 1;
    }

    var acc: i64 = 0;
    for (first.items) |item| {
        acc += item * occurences.items[@intCast(item)];
    }

    return acc;
}

pub fn main() !void {
    const file = @embedFile("input.txt");
    var lines = std.mem.tokenizeScalar(u8, file, '\n');

    var line_count: usize = 0;
    while (lines.next()) |_| {
        line_count += 1;
    }
    lines.reset();

    var list_a = try std.ArrayList(i64).initCapacity(allocator, line_count);
    var list_b = try std.ArrayList(i64).initCapacity(allocator, line_count);
    defer list_a.deinit();
    defer list_b.deinit();

    while (lines.next()) |line| {
        var vals = std.mem.tokenizeAny(u8, line, "   ");
        const first = try std.fmt.parseInt(i64, vals.next().?, 10);
        const second = try std.fmt.parseInt(i64, vals.next().?, 10);

        list_a.appendAssumeCapacity(first);
        list_b.appendAssumeCapacity(second);
    }

    std.mem.sort(i64, list_a.items, {}, comptime std.sort.asc(i64));
    std.mem.sort(i64, list_b.items, {}, comptime std.sort.asc(i64));

    const part1 = distance(list_a, list_b);
    const part2: i64 = try similarity(list_a, list_b);

    std.debug.print("{}\n", .{part1});
    std.debug.print("{}\n", .{part2});
}
