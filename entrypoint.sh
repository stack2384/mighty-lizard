#!/bin/bash
set -e

# Official direct CDN link for Tails 7.14
DEFAULT_ISO="https://download.tails.net/tails/stable/tails-amd64-7.14/tails-amd64-7.14.iso"
ISO_URL="${TAILS_ISO_URL:-$DEFAULT_ISO}"
ISO_PATH="/app/tails.iso"

# 1. Fetch Tails ISO from official mirror or specified URL
if [ ! -f "$ISO_PATH" ]; then
    echo "[+] Downloading Tails ISO from: $ISO_URL"
    curl -L -f -o "$ISO_PATH" "$ISO_URL" || {
        echo "[-] Failed to download ISO. Please check the URL."
        exit 1
    }
fi

# 2. Launch QEMU in software emulation mode
echo "[+] Booting Tails OS via QEMU..."
qemu-system-x86_64 \
    -m 3072 \
    -smp 2 \
    -cdrom "$ISO_PATH" \
    -vga virtio \
    -display vnc=127.0.0.1:0 \
    -daemonize

# 3. Start websockify/noVNC on Render's assigned port
RENDER_PORT="${PORT:-10000}"
echo "[+] Starting noVNC proxy on port $RENDER_PORT..."
exec websockify --web=/usr/share/novnc/ "$RENDER_PORT" 127.0.0.1:5900
