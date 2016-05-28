# grafana-on-raspberry through docker
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
