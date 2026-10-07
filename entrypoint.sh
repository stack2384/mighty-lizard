#!/bin/bash
set -e

RENDER_PORT="${PORT:-10000}"
DEFAULT_ISO="https://download.tails.net/tails/stable/tails-amd64-7.14/tails-amd64-7.14.iso"
ISO_URL="${TAILS_ISO_URL:-$DEFAULT_ISO}"
ISO_PATH="/app/tails.iso"

# Set default index page
ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# 1. Start websockify immediately in the background so Render's healthcheck passes
echo "[+] Starting noVNC proxy on port $RENDER_PORT..."
websockify --web=/usr/share/novnc/ "$RENDER_PORT" 127.0.0.1:5900 &
WEBSOCKIFY_PID=$!

# 2. Fetch Tails ISO
if [ ! -f "$ISO_PATH" ]; then
    echo "[+] Downloading Tails ISO from: $ISO_URL"
    curl -L -f -o "$ISO_PATH" "$ISO_URL" || {
        echo "[-] Failed to download ISO."
        exit 1
    }
fi

# 3. Launch QEMU
echo "[+] Booting Tails OS via QEMU..."
qemu-system-x86_64 \
    -m 3072 \
    -smp 2 \
    -cdrom "$ISO_PATH" \
    -vga virtio \
    -display vnc=127.0.0.1:0 \
    -daemonize

# Keep entrypoint alive tied to websockify
wait $WEBSOCKIFY_PID
