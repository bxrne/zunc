#!/bin/sh
echo "[start.sh] pwd: $(pwd)" >&2
echo "[start.sh] handler perms: $(ls -la handler 2>&1)" >&2
echo "[start.sh] FUNCTIONS_CUSTOMHANDLER_PORT=$FUNCTIONS_CUSTOMHANDLER_PORT" >&2

# Copy binary to writable /tmp and make executable
cp handler /tmp/zig_handler 2>&1 || { echo "[start.sh] FAILED to copy handler" >&2; exit 1; }
chmod +x /tmp/zig_handler 2>&1 || { echo "[start.sh] FAILED to chmod handler" >&2; exit 1; }

echo "[start.sh] launching /tmp/zig_handler..." >&2
exec /tmp/zig_handler

