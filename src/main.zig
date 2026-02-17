const std = @import("std");
const net = std.net;

const body = "Hello from Zig!\n";

const response =
    "HTTP/1.1 200 OK\r\n" ++
    "Content-Type: text/plain\r\n" ++
    std.fmt.comptimePrint("Content-Length: {d}\r\n", .{body.len}) ++
    "\r\n" ++
    body;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const port_str = std.process.getEnvVarOwned(allocator, "FUNCTIONS_CUSTOMHANDLER_PORT") catch "8080";
    defer if (std.process.getEnvVarOwned(allocator, "FUNCTIONS_CUSTOMHANDLER_PORT")) |s| allocator.free(s) else |_| {};
    const port: u16 = std.fmt.parseInt(u16, port_str, 10) catch 8080;

    const address = net.Address.parseIp("0.0.0.0", port) catch unreachable;
    var server = try address.listen(.{ .reuse_address = true });
    defer server.deinit();

    std.debug.print("Zig handler listening on 0.0.0.0:{d}\n", .{port});

    while (true) {
        const conn = server.accept() catch |err| {
            std.debug.print("Accept error: {}\n", .{err});
            continue;
        };

        handleConnection(conn) catch |err| {
            std.debug.print("Connection error: {}\n", .{err});
        };
    }
}

fn handleConnection(conn: net.Server.Connection) !void {
    defer conn.stream.close();

    // Read and discard the full HTTP request (headers + any body)
    var buf: [4096]u8 = undefined;
    while (true) {
        const n = try conn.stream.read(&buf);
        if (n == 0) return; // Client closed before sending anything

        // Check if we've received the end of headers (\r\n\r\n)
        // For GET requests with enableForwardingHttpRequest there is no body,
        // so end-of-headers is the end of the request.
        if (std.mem.indexOf(u8, buf[0..n], "\r\n\r\n") != null) break;
    }

    // Send the response
    _ = try conn.stream.writeAll(response);
}
