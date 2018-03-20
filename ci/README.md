# Grafana Crossbuild

This directory contains `Dockerfile` and helper script to crossbuild Grafana for
armv6 (raspberry pi 1) and armv7 (raspberry pi 2 and pi 3) from an x64 host
inside a (debian stretch) docker container.

> For arm64, this build grafana with an arm64 phantomjs binary.

## Usage
Build the docker image

```bash
docker build [--build-arg LABEL=<grafana-tag>] [--build-arg DEPTH=<depth>] [--build-arg COMMIT=<git-commit>] -t grafana-builder .
```

>- LABEL is a branch or a tag of grafana github repo, default is master
>- DEPTH is the number of commit to be checkout, default is 1
>- COMMIT is a specific commit to checkout, default is head
>
> As a consequence:
>- without option, it prepares build of current commit on master
>- if you intend to build a specific commit, COMMIT should be reachable within the DEPTH commits from current head of the branch LABEL

Build Grafana depending on your target,

```bash
docker run --name build-armv6 grafana-builder ./build.sh armv6
```

or

```bash
docker run --name build-armv7 grafana-builder ./build.sh armv7
```

or

```bash
docker run --name build-arm64 grafana-builder ./build.sh arm64
```

Then you can extract .deb and tarball from the container:

```bash
docker cp build-armv6:/tmp/graf-build/src/github.com/grafana/grafana/dist/ armv6
```

or

```bash
docker cp build-armv7:/tmp/graf-build/src/github.com/grafana/grafana/dist/ armv7
```

or

```bash
docker cp build-arm64:/tmp/graf-build/src/github.com/grafana/grafana/dist/ arm64
```

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
