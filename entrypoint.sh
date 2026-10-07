#!/bin/bash
set -e

# Default ISO URL if not passed via Render environment variable
DEFAULT_ISO="https://github.com/Tails-OS/tails/releases/download/7.14/tails-amd64-7.14.iso"
ISO_URL="${TAILS_ISO_URL:-$DEFAULT_ISO}"
ISO_PATH="/app/tails.iso"

# 1. Fetch Tails ISO from GitHub or specified URL
if [ ! -f "$ISO_PATH" ]; then
    echo "[+] Downloading Tails ISO from: $ISO_URL"
    wget -q --show-progress -O "$ISO_PATH" "$ISO_URL"
fi

# 2. Launch QEMU in software emulation mode with VNC bound to localhost:5900
echo "[+] Booting Tails OS via QEMU..."
qemu-system-x86_64 \
    -m 3072 \
    -smp 2 \
    -cdrom "$ISO_PATH" \
    -vga virtio \
    -display vnc=127.0.0.1:0 \
    -daemonize

# 3. Start websockify/noVNC on Render's HTTP port
RENDER_PORT="${PORT:-10000}"
echo "[+] Starting noVNC proxy on port $RENDER_PORT..."
exec websockify --web=/usr/share/novnc/ "$RENDER_PORT" 127.0.0.1:5900
