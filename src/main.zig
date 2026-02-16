const std = @import("std");
const net = std.net;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    // 1. Get the port Azure wants us to listen on
    const port_str = std.process.getEnvVarOwned(allocator, "FUNCTIONS_CUSTOMHANDLER_PORT") catch "8080";
    const port = try std.fmt.parseInt(u16, port_str, 10);

    const address = try net.Address.parseIp("127.0.0.1", port);
    var server = try address.listen(.{ .reuse_address = true });
    std.debug.print("Zig handler listening on port {}\n", .{port});

    while (true) {
        var conn = try server.accept();
        defer conn.stream.close();

        // 2. Minimal HTTP Response for Azure
        const response =
            "HTTP/1.1 200 OK\r\n" ++
            "Content-Type: text/plain\r\n" ++
            "Content-Length: 18\r\n" ++
            "\r\n" ++
            "Hello from Zig! ⚡";

        _ = try conn.stream.write(response);
    }
}
