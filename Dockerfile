# Citadel DNS Infrastructure - Docker Image
# Based on Arch Linux for maximum compatibility

FROM archlinux:latest

LABEL maintainer="Citadel Project"
LABEL description="Fortified DNS Infrastructure with DNSCrypt-Proxy and CoreDNS"
LABEL version="3.1.2"

# Install dependencies
RUN pacman -Sy --noconfirm && \
    pacman -S --noconfirm \
    bash \
    curl \
    wget \
    git \
    systemd \
    systemd-sysvcompat \
    sudo \
    nftables \
    dnsutils \
    bind-tools \
    jq \
    nc \
    && pacman -Scc --noconfirm

# Create cytadela user and directories
RUN useradd -r -s /bin/false cytadela && \
    mkdir -p /opt/cytadela /etc/cytadela /var/lib/cytadela && \
    chown -R cytadela:cytadela /opt/cytadela /etc/cytadela /var/lib/cytadela

# Copy Citadel files
COPY . /opt/cytadela/

# Set permissions
RUN chmod +x /opt/cytadela/citadel.sh /opt/cytadela/citadel_en.sh && \
    chmod +x /opt/cytadela/modules/*.sh && \
    ln -sf /opt/cytadela/citadel.sh /usr/local/bin/citadel && \
    ln -sf /opt/cytadela/citadel_en.sh /usr/local/bin/citadel-en

# Expose DNS ports
EXPOSE 53/tcp 53/udp
EXPOSE 853/tcp  # DNS-over-TLS
EXPOSE 443/tcp  # DNS-over-HTTPS (optional)

# Expose metrics ports
EXPOSE 9153/tcp  # CoreDNS metrics
EXPOSE 9100/tcp  # Citadel metrics (optional)

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD dig @127.0.0.1 -p 53 cloudflare.com +short +timeout=5 || exit 1

# Volume for persistent data
VOLUME ["/etc/cytadela", "/var/lib/cytadela"]

# Environment variables
ENV CYTADELA_MODE=docker
ENV CYTADELA_DEBUG=0

# Entrypoint
ENTRYPOINT ["/opt/cytadela/citadel.sh"]
CMD ["--help"]
