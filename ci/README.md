# Grafana Crossbuild Reusing Official Packages

This directory contains `Dockerfile` and helper script to crossbuild Grafana for
armv6 (raspberry pi 1), armv7 (raspberry pi 2 and pi 3) and arm64 from an x64 host
inside a (debian stretch) docker container.

> For arm64, this build grafana with an arm64 phantomjs binary.

## Usage

For each arch, this is a two steps process. A first container (fg2it/fgbw) is used to build grafana
and prepare packages (tar and deb). Then, two other containers are used to package (one for tar.gz and one for .deb). A docker volume is used to exchange data between containers.

Build the fg2it/fgbw docker image

```bash
docker build [--build-arg GRAFANA_VERSION=<grafana-version] -t fgbw .
```

>- GRAFANA_VERSION must be a released grafana version (without front 'v')

Build Grafana depending on your target, e.g. for armv6

```bash
docker volume create assets-fgbw
docker run --rm -v assets-fgbw:/tmp/assets/ fgbw ./build.sh armv6
```

Then, to package

```bash
./package.sh armv6
```

The .deb and tarball are in your working directory (`armv6/`, `armv7/` and `arm64/`).

> `build_and_package.sh armv6` essentially does that.

## How it works

It uses the crossbuild feature of go exposed via command line options of the
`build.go` tool from Grafana which was introduced after v3.1.1.
Due to some `C` bindings in some go modules used in Grafana, a `c/c++` toolchain is needed.
> For armv6, the toolchain comes from
[raspberrypi/tools](https://github.com/raspberrypi/tools), see
[here](https://github.com/fg2it/cross-rpi1b).
>
> For armv7 and arm64, the toolchains come from `crossbuild-essential-armhf` `crossbuild-essential-arm64` packages (stretch).

For all three targets, it uses a v2.1.1 PhantomJS binary from my
[phantomjs-on-raspberry](https://github.com/fg2it/phantomjs-on-raspberry) repo.
