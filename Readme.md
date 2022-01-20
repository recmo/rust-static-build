# Rust static build

![lines of code](https://img.shields.io/tokei/lines/github/recmo/rust-static-build)
[![Build, Test & Deploy](https://github.com/recmo/rust-static-build/actions/workflows/build-test-deploy.yml/badge.svg)](https://github.com/recmo/rust-static-build/actions/workflows/build-test-deploy.yml)

Rust build image to create statically compiled binaries.

It supports cross compiling with both `linux/amd64` and `linux/arm64` as host platforms and `x86_64` and `aarch64` as target architectures.

Includes

* [musl](https://musl.libc.org/) and a musl-gcc compiler for C, C++ dependencies,
* [zlib](https://zlib.net/), and
* [openssl](https://www.openssl.org/).
* [libpq](https://www.postgresql.org/docs/current/libpq.html) .

It is similar to `https://github.com/emk/rust-musl-builder` and `https://github.com/rust-embedded/cross` but also supports building with `linux/arm64` as host (i.e. docker on Apple Silicon) and has OpenSSL and libpq included.

## Using

```
docker run --rm -v "$(pwd)":/src ghcr.io/recmo/rust-static-build:1.58-x86_64 cargo build --release
docker run --rm -v "$(pwd)":/src ghcr.io/recmo/rust-static-build:1.58-aarch64 cargo build --release
```

## Build locally


```
docker build --build-arg TARGET=aarch64 --tag ghcr.io/recmo/rust-static-build:1.58-aarch64 .
docker build --build-arg TARGET=x86_64 --tag ghcr.io/recmo/rust-static-build:1.58-x86_64 .
```


## Developer notes

Update manifest

```
docker manifest create \
    ghcr.io/recmo/rust-static-build:1.58-aarch64 \
    --amend ghcr.io/recmo/rust-static-build:1.58-aarch64-amd64 \
    --amend ghcr.io/recmo/rust-static-build:1.58-aarch64-arm64
docker manifest push ghcr.io/recmo/rust-static-build:1.58-aarch64
```
```
docker manifest create \
    ghcr.io/recmo/rust-static-build:1.58-x86_64 \
    --amend ghcr.io/recmo/rust-static-build:1.58-x86_64-amd64 \
    --amend ghcr.io/recmo/rust-static-build:1.58-x86_64-arm64
docker manifest push ghcr.io/recmo/rust-static-build:1.58-x86_64
```
