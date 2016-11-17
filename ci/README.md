# Grafana Crossbuild

This directory contains `Dockerfile` and helper script to crossbuild Grafana for
armv6 (raspberry pi 1) and armv7 (raspberry pi 2 and pi 3) from an x64 host
inside a docker container.

## Usage
Build the docker image
```bash
$ docker build -t grafana-builder .
```

Build Grafana depending on your target,
```bash
$ docker run --name build-armv6 grafana-builder ./build.sh armv6 [grafana-tag]
```
or
```bash
$ docker run --name build-armv7 grafana-builder ./build.sh armv7 [grafana-tag]
```
If present, `grafana-tag` should be a tag from the Grafana github
[repo](https://github.com/grafana/grafana). If no tag is provided, build against
current commit of master branch.

Then you can extract .deb and tarball from the container:
```bash
$ docker cp build-armv6:/tmp/graf-build/src/github.com/grafana/grafana/dist/ armv6
```
or
```bash
$ docker cp build-armv7:/tmp/graf-build/src/github.com/grafana/grafana/dist/ armv7
```

## How it works
It uses the crossbuild feature of go exposed via command line options of the
`build.go` tool from Grafana which was introduced after v3.1.1.
Due to some `C` bindings in some go modules used in Grafana, a `c/c++` toolchain is needed.
> For armv6, the toolchain comes from
[raspberrypi/tools](https://github.com/raspberrypi/tools), see
[here](https://github.com/fg2it/cross-rpi1b).

> For armv7, the toolchain comes from [Emdebian](http://www.emdebian.org/).

It uses a v2.1.1 PhantomJS binary from my
[phantomjs-on-raspberry](https://github.com/fg2it/phantomjs-on-raspberry) repo.
