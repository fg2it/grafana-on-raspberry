# Unofficial Grafana Docker image for armhf

This project builds a Docker image with an unofficial grafana
[v3.0.2](https://github.com/grafana/grafana/tree/v3.0.2) build for armhf and
closely follow the [official docker
image](https://github.com/grafana/grafana-docker). The base docker image is
[resin/armv7hf-debian:jessie](https://hub.docker.com/r/resin/armv7hf-debian/)

The container is available on [dockerhub](https://hub.docker.com/r/fg2it/grafana-armhf/) :
```
docker pull fg2it/grafana-armhf:v3.0.2
```

The following documentation is a mere adaptation of the [official
one](https://github.com/grafana/grafana-docker/tree/aff14bd707682870b9d5f2f2b62d2eb09f734923).

## Caution
It was tested only on a raspberry pi 2.

## Running your Grafana container

Start your container binding the external port `3000`.

```
docker run -d --name=grafana -p 3000:3000 fg2it/grafana-armhf:v3.0.2
```

Try it out, default admin user is admin/admin.

## Configuring your Grafana container

All options defined in conf/grafana.ini can be overridden using environment
variables, for example:

```
docker run \
  -d \
  -p 3000:3000 \
  --name=grafana \
  -e "GF_SERVER_ROOT_URL=http://grafana.server.name" \
  -e "GF_SECURITY_ADMIN_PASSWORD=secret" \
  fg2it/grafana-armhf:v3.0.2
```

## Grafana container with persistent storage (recommended)

```
# create /var/lib/grafana as persistent volume storage
docker run -d -v /var/lib/grafana --name grafana-storage hypriot/armhf-busybox

# start grafana
docker run \
  -d \
  -p 3000:3000 \
  --name=grafana \
  --volumes-from grafana-storage \
  fg2it/grafana-armhf:v3.0.2
```

## Configuring AWS credentials for CloudWatch support

```
docker run \
  -d \
  -p 3000:3000 \
  --name=grafana \
  -e "GF_AWS_PROFILES=default" \
  -e "GF_AWS_default_ACCESS_KEY_ID=YOUR_ACCESS_KEY" \
  -e "GF_AWS_default_SECRET_ACCESS_KEY=YOUR_SECRET_KEY" \
  -e "GF_AWS_default_REGION=us-east-1" \
  fg2it/grafana-armhf:v3.0.2
```

You may also specify multiple profiles to `GF_AWS_PROFILES` (e.g.
`GF_AWS_PROFILES=default another`).

Supported variables:

- `GF_AWS_${profile}_ACCESS_KEY_ID`: AWS access key ID (required).
- `GF_AWS_${profile}_SECRET_ACCESS_KEY`: AWS secret access  key (required).
- `GF_AWS_${profile}_REGION`: AWS region (optional).


## See:
- [Grafana 3.0 Stable Released](http://grafana.org/blog/2016/05/11/grafana-3-0-stable-released.html) on the official blog
- [Unofficial Grafana deb](https://github.com/fg2it/grafana-on-raspberry/releases)
