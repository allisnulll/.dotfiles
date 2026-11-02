#!/bin/bash

# Unlock the login keyring of the gnome-keyring daemon that is already running
# (and owns org.freedesktop.secrets), by speaking its control-socket protocol.
# Starting `gnome-keyring-daemon --unlock` instead would launch a *second*
# daemon that never owns the secret service, so the real one stays locked.

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"

exec /usr/bin/python3 - "$HOME/.keyring_pass" "$XDG_RUNTIME_DIR/keyring/control" <<'PY'
import socket
import struct
import sys
import time

pw_path, control_path = sys.argv[1], sys.argv[2]

with open(pw_path, "rb") as f:
    password = f.read()

# gnome-keyring control protocol (daemon/control/gkd-control-client.c):
#   one NUL credentials byte, then a big-endian packet:
#   uint32 total_size, uint32 op (1 = UNLOCK), uint32 password_len, password
# The reply is uint32 total_size, uint32 result (0 = OK).
def unlock_once():
    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    sock.settimeout(2)
    try:
        sock.connect(control_path)
        sock.sendall(b"\0")
        body = struct.pack(">II", 0, 1) + struct.pack(">I", len(password)) + password
        body = struct.pack(">I", len(body)) + body[4:]
        sock.sendall(body)
        header = sock.recv(4)
        if len(header) < 4:
            return None
        size = struct.unpack(">I", header)[0]
        rest = b""
        while len(rest) < size - 4:
            chunk = sock.recv(size - 4 - len(rest))
            if not chunk:
                break
            rest += chunk
        if len(rest) < 4:
            return None
        return struct.unpack(">I", rest[:4])[0]
    finally:
        sock.close()

# The daemon is Type=simple, so it may still be binding the socket when this
# unit starts. Give it a few seconds.
for _ in range(40):
    try:
        result = unlock_once()
    except OSError:
        result = None
    if result == 0:
        sys.exit(0)
    if result is not None:
        print("gnome-keyring refused to unlock the login keyring", file=sys.stderr)
        sys.exit(1)
    time.sleep(0.25)

print("gnome-keyring control socket is not available", file=sys.stderr)
sys.exit(1)
PY
