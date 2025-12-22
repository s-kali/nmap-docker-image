# https://hub.docker.com/_/debian
FROM debian:bookworm-slim AS build

# Nmap build dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        g++ \
        liblua5.4-dev \
        libpcap-dev \
        libpcre3-dev \
        libssh2-1-dev \
        libssl-dev \
        libtool \
        linux-headers-generic \
        make \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy files required for build (Nmap repository: https://github.com/nmap/nmap/)
COPY . .

# Configure Nmap build
RUN ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --mandir=/usr/share/man \
    --infodir=/usr/share/info \
    --without-zenmap \
    --without-nmap-update \
    --with-liblua=/usr/lua5.4 \
    --with-libpcap=yes \
    --with-libpcre=yes \
    --with-libssh2=yes \
    --with-libz=yes \
    --with-openssl=yes \
    && make \
    && make install DESTDIR=/install \
    && rm -rf /install/usr/share/man

FROM debian:bookworm-slim

# Nmap runtime dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        libgcc-s1 \
        liblua5.4-0 \
        libpcap0.8 \
        libssh2-1 \
        libssl3 \
        libstdc++6 \
        zlib1g \
    && update-ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /install/ /
