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

To build statically linked executables for both x86_64 and aarch64 linux:

```
docker run --rm \
    -v "$(pwd)":/src \
    ghcr.io/recmo/rust-static-build:1.65-x86_64 \
    cargo build --release
docker run --rm \
    -v "$(pwd)":/src \
    ghcr.io/recmo/rust-static-build:1.65-aarch64 \
    cargo build --release
```

## Maintainer build instructions

Build locally

```
for host in amd64 arm64; do
    for target in x86_64 aarch64; do
        docker build --platform linux/$host --build-arg TARGET=$target --tag ghcr.io/recmo/rust-static-build:1.65-$target-$host .
        docker push ghcr.io/recmo/rust-static-build:1.65-$target-$host
    done
done
```

Create manifests

```
for target in x86_64 aarch64; do
    docker manifest rm ghcr.io/recmo/rust-static-build:1.65-$target
    docker manifest create \
        ghcr.io/recmo/rust-static-build:1.65-$target \
        ghcr.io/recmo/rust-static-build:1.65-$target-amd64 \
        ghcr.io/recmo/rust-static-build:1.65-$target-arm64
    docker manifest inspect ghcr.io/recmo/rust-static-build:1.65-$target
    docker manifest push ghcr.io/recmo/rust-static-build:1.65-$target
done
```

Test manifests

```
for host in amd64 arm64; do
    for target in x86_64 aarch64; do
        docker run --pull always --platform linux/$host --rm -it ghcr.io/recmo/rust-static-build:1.65-$target cargo --version
    done
done
```
