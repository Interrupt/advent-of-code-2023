const std = @import("std");

const str_nums = [_] [:0]const u8 {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine"};

pub fn main() !void {
    const path = "assets/puzzle1/input.txt";
    // const file = try std.fs.openFile(path, .{});
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();


    var buffered_file = std.io.bufferedReader(file.reader());
    var read_stream = buffered_file.reader();
    var buffer: [128]u8 = undefined;

    var total_sum: i64 = 0;

    while(try read_stream.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        std.debug.print("{s}\n", .{line});

        const f_d_idx: ?FoundIndex = findFirstDigit(line);
        const l_d_idx: ?FoundIndex = findLastDigit(line);

        // check for string versions as well
        const f_idx: ?FoundIndex = findFirstStringNumber(line);
        const l_idx: ?FoundIndex = findLastStringNumber(line);

        var overall_lowest: ?FoundIndex = f_d_idx;
        var overall_highest: ?FoundIndex = l_d_idx;

        if(f_idx != null) {
            if(overall_lowest == null or overall_lowest.?.idx > f_idx.?.idx)
                overall_lowest = f_idx;
        }

        if(l_idx != null) {
            if(overall_highest == null or overall_highest.?.idx < l_idx.?.idx)
                overall_highest = l_idx;
        }

        if(overall_lowest == null or overall_highest == null) {
            continue;
        }

        const total = (overall_lowest.?.num * 10) + overall_highest.?.num;
        total_sum += total;

        std.debug.print(" +{?d}={?d}\n", .{total, total_sum});
    }

    std.debug.print("total sum: {d}\n", .{total_sum});
}

const FoundIndex = struct {
    idx: usize,
    num: u8,
};

fn findFirstDigit(buffer: []const u8) ?FoundIndex {
    var first_idx: ?usize = null;
    for(buffer, 0..) |c, i| {
        if(c < '0' or c > '9')
            continue;

        if(first_idx == null) {
            first_idx = i;
            return FoundIndex{.idx = i, .num = buffer[i] - 48};
        }
    }
    return null;
}

fn findLastDigit(buffer: []const u8) ?FoundIndex {
    var last_idx: ?usize = null;
    for(buffer, 0..) |c, i| {
        if(c < '0' or c > '9')
            continue;

        if(last_idx == null or last_idx.? < i) {
            last_idx = i;
        }
    }

    if(last_idx == null)
        return null;

    return FoundIndex{.idx = last_idx.?, .num = buffer[last_idx.?] - 48};
}

fn findFirstStringNumber(buffer: []const u8) ?FoundIndex {
    var lowest: ?usize = null;
    var val: u8 = 0;

    for(str_nums, 0..) |num, i| {
        const index = std.mem.indexOf(u8, buffer, num);
        if(index != null) {
            if(lowest != null and lowest.? < index.?)
                continue;

            lowest = index;
            val = @intCast(i);
        }
    }

    if(lowest == null)
        return null;

    return FoundIndex{.idx = lowest.?, .num = val + 1};
}

fn findLastStringNumber(buffer: []const u8) ?FoundIndex {
    var highest: ?usize = null;
    var val: u8 = 0;

    for(str_nums, 0..) |num, i| {
        const index = std.mem.lastIndexOf(u8, buffer, num);
        if(index != null) {
            if(highest != null and highest.? > index.?)
                continue;

            highest = index;
            val = @intCast(i);
        }
    }
    if(highest == null)
        return null;

    return FoundIndex{.idx = highest.?, .num = val + 1};
}
