# grafana-on-raspberry through docker
[![](https://images.microbadger.com/badges/version/fg2it/grafana-armhf.svg)](https://microbadger.com/images/fg2it/grafana-armhf) [![](https://images.microbadger.com/badges/image/fg2it/grafana-armhf.svg)](https://microbadger.com/images/fg2it/grafana-armhf) [![Docker Pulls](https://img.shields.io/docker/pulls/fg2it/grafana-armhf.svg?style=flat-square)](https://hub.docker.com/r/fg2it/grafana-armhf/)

---

## **Warning Notice: End of Life**

Starting from [v5.2.0-beta1](https://github.com/grafana/grafana/releases/tag/v5.2.0-beta1) Grafana introduced [official support](https://grafana.com/grafana/download/5.2.0-beta1?platform=arm) for armv7 and arm64 linux platforms. Many thanks to them for that.

As a consequence, this repo is no more needed and stops support starting from v5.2.0-beta1.

If you are using unofficial builds from this repo, you are invited to upgrade to official builds.

> Should you need armv6 build, you are invited to ask official support.

---

[Grafana](http://grafana.org) *unofficial* docker image for armhf.

The build process closely follows the [official
one](https://github.com/grafana/grafana-docker). You can get the image from
[dockerhub](https://hub.docker.com/r/fg2it/grafana-armhf/).

Obviously, you will need docker to run a container. The easiest way might be to
use [hypriot deb package](http://blog.hypriot.com/downloads/).

See [dockerhub](https://hub.docker.com/r/fg2it/grafana-armhf/tags) for available
version. Alternately, you can use the registry api :
```bash
curl -s -S https://registry.hub.docker.com/v2/repositories/fg2it/grafana-armhf/tags/ | python -m json.tool | grep name
```

Grafana [license](https://github.com/grafana/grafana/blob/master/LICENSE.md).
