const std = @import("std");
const catalog = @import("catalog.zig");

pub fn main(init: std.process.Init) !void {
    var buffer: [4096]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &buffer);
    const stdout = &stdout_writer.interface;

    var previous_origin: ?catalog.Origin = null;
    var previous_category: ?[]const u8 = null;
    for (catalog.examples) |example| {
        if (previous_origin == null or previous_origin.? != example.origin) {
            if (previous_origin != null) try stdout.writeByte('\n');
            try stdout.print("{s} examples\n", .{example.origin.label()});
            previous_origin = example.origin;
            previous_category = null;
        }
        if (previous_category == null or
            !std.mem.eql(u8, previous_category.?, example.category))
        {
            try stdout.print("  {s}\n", .{example.category});
            previous_category = example.category;
        }
        try stdout.print("    {s:<42} {s}\n", .{ example.name, example.source });
    }

    try stdout.writeAll(
        "\nBuild one: zig build build-example -Dexample=<name>\n" ++
            "Run one:   zig build run-example -Dexample=<name> -- [arguments]\n",
    );
    try stdout.flush();
}
