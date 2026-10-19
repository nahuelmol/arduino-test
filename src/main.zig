const std       = @import("std");
const arduino   = @import("arduino");
const worker    = @import("controllers\\worker.zig");
const Command   = @import("command.zig").Command;
const screen    = @import("screen");

pub fn main() !void {
    const port_name = "\\\\.\\COM5";
    std.debug.print("Opening port: {s}", .{port_name});

    const file = try std.fs.cwd().openFile(port_name, .{ .mode = .read_only });
    defer file.close();

    var read_buffer: [2]u8 = undefined;
    var file_reader = file.reader(&read_buffer);
    const reader = &file_reader.interface;

    std.debug.print("listening on port {s}...\n\n", .{port_name});

    while (true) {
        const BITE = reader.take(1) catch {
            //if (err == error.EndOfStream) break;
            //break;
        };

        std.debug.print("Byte: {}\n", .{BITE[0]});
        reader.toss(1);
    }
}

