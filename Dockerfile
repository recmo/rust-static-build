FROM rust:1.61
WORKDIR /src

# Target architecture, one of x864_64 or aarch64
ARG TARGET
LABEL org.opencontainers.image.description Rust builder for static $TARGET-linux-musl executables.

# Build {x86_64,aarch64}-linux-musl toolchain
# This is required to build zlib, openssl and other C dependencies
ARG MUSL_CROSS_VERSION=fe915821b652a7fa37b34a596f47d8e20bc72338
RUN curl -fL "https://github.com/richfelker/musl-cross-make/archive/${MUSL_CROSS_VERSION}.tar.gz"\
    | tar xz && cd musl-cross-make-${MUSL_CROSS_VERSION} &&\
    make install TARGET=$TARGET-linux-musl OUTPUT=/usr/local/musl &&\
    rm -r /src/musl-cross-make-${MUSL_CROSS_VERSION}
ENV CC_x86_64_unknown_linux_musl=/usr/local/musl/bin/x86_64-linux-musl-gcc
ENV CC_aarch64_unknown_linux_musl=/usr/local/musl/bin/aarch64-linux-musl-gcc

# Build zlib
ARG ZLIB_VERSION=1.2.12
RUN curl -fL "http://zlib.net/zlib-$ZLIB_VERSION.tar.gz" | tar xz && cd "zlib-$ZLIB_VERSION" &&\
    export CC=/usr/local/musl/bin/$TARGET-linux-musl-gcc &&\
    ./configure --static --prefix=/usr/local/musl && make && make install &&\
    rm -r "/src/zlib-$ZLIB_VERSION"

# Build OpenSSL
ARG OPENSSL_VERSION=1.1.1n
RUN curl -fL "https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz" | tar xz &&\
    cd "openssl-$OPENSSL_VERSION" &&\
    export CC=/usr/local/musl/bin/$TARGET-linux-musl-gcc &&\
    ./Configure no-shared --prefix=/usr/local/musl linux-$TARGET &&\
    make install_sw &&\
    rm -r "/src/openssl-$OPENSSL_VERSION"
ENV X86_64_UNKNOWN_LINUX_MUSL_OPENSSL_DIR=/usr/local/musl
ENV X86_64_UNKNOWN_LINUX_MUSL_OPENSSL_STATIC=1
ENV AARCH64_UNKNOWN_LINUX_MUSL_OPENSSL_DIR=/usr/local/musl
ENV AARCH64_UNKNOWN_LINUX_MUSL_OPENSSL_STATIC=1

# Build libpq from postgresql
ARG POSTGRESql_VERSION=14.2
RUN curl -fL "https://ftp.postgresql.org/pub/source/v$POSTGRESql_VERSION/postgresql-$POSTGRESql_VERSION.tar.gz" | tar xz &&\
    cd "postgresql-$POSTGRESql_VERSION" &&\
    ./configure --host=$(uname -m)-linux --prefix=/usr/local/musl \
        CC=/usr/local/musl/bin/$TARGET-linux-musl-gcc \
        CPPFLAGS=-I/usr/local/musl/include \
        LDFLAGS=-L/usr/local/musl/lib \
        --with-openssl --without-readline && \
    cd src/interfaces/libpq && make all-static-lib && make install-lib-static && \
    cd ../../bin/pg_config && make && make install && \
    rm -r "/src/postgresql-$POSTGRESql_VERSION"

# Install clang beacuse proc-macros require it on x86_64 hosts
RUN apt-get update &&\
    apt-get install -y clang &&\
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set rust target
ENV CARGO_BUILD_TARGET=$TARGET-unknown-linux-musl
ENV CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER=/usr/local/musl/bin/x86_64-linux-musl-gcc
ENV CARGO_TARGET_AARCH64_UNKNOWN_LINUX_MUSL_LINKER=/usr/local/musl/bin/aarch64-linux-musl-gcc
RUN rustup target add $CARGO_BUILD_TARGET
