# Rust static build

![lines of code](https://img.shields.io/tokei/lines/github/recmo/rust-static-build)
[![Build, Test & Deploy](https://github.com/recmo/rust-static-build/actions/workflows/build-test-deploy.yml/badge.svg)](https://github.com/recmo/rust-static-build/actions/workflows/build-test-deploy.yml)

Rust build image to create statically compiled binaries.

Supports both `linux/amd64` and `linux/arm64` platforms.

Includes

* [musl](https://musl.libc.org/) and a musl-gcc compiler for C, C++ dependencies,
* [zlib](https://zlib.net/), and
* [openssl](https://www.openssl.org/).
* [libpq](https://www.postgresql.org/docs/current/libpq.html) .

It is similar to `https://github.com/emk/rust-musl-builder` and `https://github.com/rust-embedded/cross` but also supports building with arm64 as host (i.e. Apple Silicon) and has OpenSSL and libpq included.

## Build locally


```
docker build --build-arg TARGET=aarch64 --tag ghcr.io/recmo/rust-static-build:1.58-aarch64 .
docker build --build-arg TARGET=x86_64 --tag ghcr.io/recmo/rust-static-build:1.58-x86_64 .
```
