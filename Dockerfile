FROM rust as build-env
WORKDIR /src

RUN apt-get update &&\
    apt-get install -y libssl-dev texinfo libcap2-bin &&\
    apt-get clean && rm -rf /var/lib/apt/lists/* &&\
    rustup target add $(uname -m)-unknown-linux-musl

# Build {x86_64,aarch64}-linux-musl toolchain
# This is required to build zlib, openssl and other C dependencies
ARG MUSL_CROSS_VERSION=0.9.9
RUN curl -fL "https://github.com/richfelker/musl-cross-make/archive/v${MUSL_CROSS_VERSION}.tar.gz"\
    | tar xz && cd musl-cross-make-${MUSL_CROSS_VERSION} &&\
    make install TARGET=$(uname -m)-linux-musl OUTPUT=/usr/local/musl &&\
    rm -r /src/musl-cross-make-${MUSL_CROSS_VERSION}
ENV CC_x86_64_unknown_linux_musl=/usr/local/musl/bin/x86_64-linux-musl-gcc
ENV CC_aarch64_unknown_linux_musl=/usr/local/musl/bin/aarch64-linux-musl-gcc

# Build zlib
ARG ZLIB_VERSION=1.2.11
RUN curl -fL "http://zlib.net/zlib-$ZLIB_VERSION.tar.gz" | tar xz && cd "zlib-$ZLIB_VERSION" &&\
    export CC=/usr/local/musl/bin/$(uname -m)-linux-musl-gcc &&\
    ./configure --static --prefix=/usr/local/musl && make && make install &&\
    rm -r "/src/zlib-$ZLIB_VERSION"

# Build OpenSSL
ARG OPENSSL_VERSION=1.1.1l
RUN curl -fL "https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz" | tar xz &&\
    cd "openssl-$OPENSSL_VERSION" &&\
    export CC=/usr/local/musl/bin/$(uname -m)-linux-musl-gcc &&\
    ./Configure no-shared --prefix=/usr/local/musl linux-$(uname -m) &&\
    make install_sw &&\
    rm -r "/src/openssl-$OPENSSL_VERSION"
ENV X86_64_UNKNOWN_LINUX_MUSL_OPENSSL_DIR=/usr/local/musl
ENV X86_64_UNKNOWN_LINUX_MUSL_OPENSSL_STATIC=1
ENV AARCH64_UNKNOWN_LINUX_MUSL_OPENSSL_DIR=/usr/local/musl
ENV AARCH64_UNKNOWN_LINUX_MUSL_OPENSSL_STATIC=1
