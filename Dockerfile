FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PORT=10000

# Install QEMU hypervisor, noVNC web viewer, websockify, and networking tools
RUN apt-get update && apt-get install -y \
    qemu-system-x86 \
    novnc \
    websockify \
    wget \
    ca-certificates \
    procps \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy and prepare execution script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

EXPOSE 10000

ENTRYPOINT ["/app/entrypoint.sh"]
