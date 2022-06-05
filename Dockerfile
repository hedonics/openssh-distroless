# OpenSSH build stage
FROM debian:bullseye-backports as build

# libxcrypt 4.4.28
ARG LIBXCRYPT_VERSION="4.4.28"
ARG LIBXCRYPT_CHECKSUM="9e936811f9fad11dbca33ca19bd97c55c52eb3ca15901f27ade046cc79e69e87"

# zlib 1.2.12
ARG ZLIB_VERSION="1.2.12"
ARG ZLIB_CHECKSUM="91844808532e5ce316b3c010929493c0244f3d37593afd6de04f71821d5136d9"

# LibreSSL 3.5.3
ARG LIBRESSL_VERSION="3.5.3"
ARG LIBRESSL_CHECKSUM="3ab5e5eaef69ce20c6b170ee64d785b42235f48f2e62b095fca5d7b6672b8b28"

# OpenSSH 9.0p1
ARG OPENSSH_VERSION="9.0p1"
ARG OPENSSH_CHECKSUM="03974302161e9ecce32153cfa10012f1e65c8f3750f573a73ab1befd5922a28a"

RUN mkdir -p /ssh/var/empty
WORKDIR /
ENV CFLAGS="-I/ssh/include -L." \
    CPPFLAGS="-I/ssh/include -L."
RUN apt update && \
    apt install -y build-essential libkrb5-dev libssl-dev \
                   libgss-dev libaudit-dev libcom-err2 libpam0g-dev wget \
                   libselinux1-dev libsystemd-dev libwrap0-dev lsb-base
RUN wget "https://github.com/besser82/libxcrypt/releases/download/v${LIBXCRYPT_VERSION}/libxcrypt-${LIBXCRYPT_VERSION}.tar.xz" && \
    wget "https://zlib.net/zlib-${ZLIB_VERSION}.tar.gz" && \
    wget "https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VERSION}.tar.gz" && \
    wget "https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-${OPENSSH_VERSION}.tar.gz" && \
    echo -n "${LIBXCRYPT_CHECKSUM}  libxcrypt-${LIBXCRYPT_VERSION}.tar.xz" | sha256sum --check && \
    echo -n "${ZLIB_CHECKSUM}  zlib-${ZLIB_VERSION}.tar.gz" | sha256sum --check && \
    echo -n "${LIBRESSL_CHECKSUM}  libressl-${LIBRESSL_VERSION}.tar.gz" | sha256sum --check && \
    echo -n "${OPENSSH_CHECKSUM}  openssh-${OPENSSH_VERSION}.tar.gz" | sha256sum --check
RUN tar xf libxcrypt-*.tar.xz && cd libxcrypt-*/ && \
    ./configure --prefix="/ssh" && \
    make -j`nproc` && make install && cd / && \
    tar xf zlib-*.tar.gz && cd zlib-*/ && \
    ./configure --prefix="/ssh" && \
    make -j`nproc` && make install && cd / && \
    tar xf libressl-*.tar.gz && cd libressl-*/ && \
    ./config --prefix="/ssh" && \
    make -j`nproc` && make install && cd / && \
    tar xf openssh-*.tar.gz && cd openssh-*/ && \
    cp -p /ssh/lib/*.a . && \
    ./configure --prefix="/ssh" --with-privsep-user=nobody \
                --with-privsep-path="/ssh/var/empty" \
                LIBS='-pthread' && \
    make -j`nproc` && make install

# Base distroless image stage
FROM gcr.io/distroless/base-debian11 as base
COPY --from=build /ssh /ssh

# Stages for each entrypoint

FROM base as ssh
CMD ["/ssh/bin/ssh"]

FROM base as ssh-add
CMD ["/ssh/bin/ssh-add"]

FROM base as ssh-agent
CMD ["/ssh/bin/ssh-agent"]

FROM base as ssh-keygen
CMD ["/ssh/bin/ssh-keygen"]

FROM base as ssh-keyscan
CMD ["/ssh/bin/ssh-keyscan"]

FROM base as sshd
CMD ["/ssh/sbin/sshd"]

FROM base as scp
CMD ["/ssh/bin/scp"]

FROM base as sftp
CMD ["/ssh/bin/sftp"]