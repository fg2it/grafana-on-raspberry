# grafana-on-raspberry (and arm64) [![Release][release-svg]][release_url] [![Build Status][ci-svg]][ci-url]

---

## **Warning Notice: End of Life**

Starting from [v5.2.0-beta1](https://github.com/grafana/grafana/releases/tag/v5.2.0-beta1) Grafana introduced [official support](https://grafana.com/grafana/download/5.2.0-beta1?platform=arm) for armv7 and arm64 linux platforms. Many thanks to them for that.

As a consequence, this repo is no more needed and stops support starting from v5.2.0-beta1.

If you are using unofficial builds from this repo, you are invited to upgrade to official builds.

> Should you need armv6 build, you are invited to ask official support.

---

[release-svg]: https://img.shields.io/github/release/fg2it/grafana-on-raspberry.svg
[release_url]: https://github.com/fg2it/grafana-on-raspberry/releases/latest
[ci-svg]: https://travis-ci.org/fg2it/grafana-on-raspberry.svg?branch=master
[ci-url]: https://travis-ci.org/fg2it/grafana-on-raspberry

> | raspberry pi 1 (armv6) | raspberry pi 2 and 3 (armv7) | arm64 |
> | :---: | :---: | :---: |
> | [ ![Download][pi1-svg] ][pi1-url] |  [ ![Download][pi2-svg] ][pi2-url] | [ ![Download][arm64-svg] ][arm64-url]

[pi1-svg]: https://api.bintray.com/packages/fg2it/deb-rpi-1b/grafana-on-raspberry/images/download.svg
[pi1-url]: https://bintray.com/fg2it/deb-rpi-1b/grafana-on-raspberry/_latestVersion
[pi2-svg]: https://api.bintray.com/packages/fg2it/deb/grafana-on-raspberry/images/download.svg
[pi2-url]: https://bintray.com/fg2it/deb/grafana-on-raspberry/_latestVersion
[arm64-svg]: https://api.bintray.com/packages/fg2it/deb-arm64/grafana-on-raspberry/images/download.svg
[arm64-url]: https://bintray.com/fg2it/deb-arm64/grafana-on-raspberry/_latestVersion

[Grafana](http://grafana.org) *unofficial* packages for arm based raspberry pi (1, 2 and 3) and arm64/aarch64.

Grafana doesn't provide packages for arm, so the purpose of this repo is to provide notes
on how you can build Grafana yourself and packages I build according to these notes.

Deb packages and tarballs are available from the github [release][release] section
(only pi 2 and pi 3) and most recent ones are also available from a deb repo on
[bintray][bintray-pi2/3] (including for [pi 1][bintray-pi1] and [arm64/aarch64][bintray-arm64]). See the
[wiki](../../wiki) for details.

[release]: https://github.com/fg2it/grafana-on-raspberry/releases
[bintray-pi2/3]: https://bintray.com/fg2it/deb/grafana-on-raspberry "bintray repo for pi 2/3"
[bintray-pi1]: https://bintray.com/fg2it/deb-rpi-1b/grafana-on-raspberry "bintray repo for pi 1b"
[bintray-arm64]: https://bintray.com/fg2it/deb-arm64/grafana-on-raspberry "bintray repo for arm64/aarch64"

## `ci/`

Notes and tools to crossbuild Grafana. Used to build on [travis](https://travis-ci.org/).

## `docker/`

The `docker/` folder contains `Dockerfile` and related files to build images
running grafana for armhf. Corresponding images are on [dockerhub](https://hub.docker.com/r/fg2it/grafana-armhf/).

## `old-versions/`

This directory contains notes for versions from 2.1.2 up to 3.1.1 for wheezy and jessie distro.

## Other boards

These packages have been reported to work on some other armv6/armv7 boards running
debian-like os like odroid or orange pi. See the [FAQ](../../wiki/FAQ) for details.

---

## License

Grafana [license](https://github.com/grafana/grafana/blob/master/LICENSE.md).
