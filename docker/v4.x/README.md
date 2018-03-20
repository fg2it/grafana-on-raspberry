# Unofficial Grafana Docker image for armhf

> here v4.x stands for any of v4.0.0-beta[1-2], v4.0.[1-2], v4.1.0-beta1, v4.1.[0-2], v4.2.0-beta1, v4.2.0, v4.3.0-beta1, v4.3.[0-2], v4.4.[0-3], v4.5.0-beta1, v4.5.[0-2], v4.6.0-beta[1-3], v4.6.[0-3]
>
> ... and also v5.0.0-beta[1-5], v5.0.[0-3]

This project builds a Docker image with an unofficial grafana
build for armhf available [here](https://github.com/fg2it/grafana-on-raspberry/releases/) and
closely follow the [official docker
image](https://github.com/grafana/grafana-docker). The base docker image is
[arm32v7/debian:stretch-slim](https://hub.docker.com/r/arm32v7/debian/) (was [resin/armv7hf-debian:jessie](https://hub.docker.com/r/resin/armv7hf-debian/) up to and including v5.0.3).

The container are available on [dockerhub](https://hub.docker.com/r/fg2it/grafana-armhf/).
See [dockerhub](https://hub.docker.com/r/fg2it/grafana-armhf/tags) for available
version. Alternately, you can just have a look at the `grafana.yaml` file or use the registry api :

```bash
curl -s -S https://registry.hub.docker.com/v2/repositories/fg2it/grafana-armhf/tags/ | python -m json.tool | grep 'name.*v5'
```

For example,

```bash
% curl -s -S https://registry.hub.docker.com/v2/repositories/fg2it/grafana-armhf/tags/ | python -m json.tool | grep 'name.*v5'
            "name": "v5.0.3",
            "name": "v5.0.2",
            "name": "v5.0.1",
            "name": "v5.0.0",
            "name": "v5.0.0-beta5",
            "name": "v5.0.0-beta4",
            "name": "v5.0.0-beta3",
            "name": "v5.0.0-beta2",
            "name": "v5.0.0-beta1",
% docker pull fg2it/grafana-armhf:v5.0.2
```

The following documentation is a mere adaptation of the [official
one](https://github.com/grafana/grafana-docker/tree/7eed5279e62fb1ebb78bef11e45e015cd09f4f0e).

## Caution

It was tested on raspberry pi 2 and pi 3, and won't work on pi 1.

## Running your Grafana container

Start your container binding the external port `3000`.

```bash
docker run -d --name=grafana -p 3000:3000 fg2it/grafana-armhf:<tag>
```

Try it out, default admin user is admin/admin.

## Configuring your Grafana container

All options defined in conf/grafana.ini can be overridden using the syntax `GF_<SectionName>_<KeyName>`. For example:

```bash
docker run \
  -d \
  -p 3000:3000 \
  --name=grafana \
  -e "GF_SERVER_ROOT_URL=http://grafana.server.name" \
  -e "GF_SECURITY_ADMIN_PASSWORD=secret" \
  fg2it/grafana-armhf:<tag>
```

More information in the grafana configuration [documentation](http://docs.grafana.org/installation/configuration/).

## Grafana container with persistent storage (recommended)

```bash
# create /var/lib/grafana as persistent volume storage
docker run -d -v /var/lib/grafana --name grafana-storage hypriot/armhf-busybox

# start grafana
docker run \
  -d \
  -p 3000:3000 \
  --name=grafana \
  --volumes-from grafana-storage \
  fg2it/grafana-armhf:<tag>
```

> This is the way recommended in the [grafana official documentation](https://github.com/grafana/grafana-docker/tree/7eed5279e62fb1ebb78bef11e45e015cd09f4f0e#grafana-container-with-persistent-storage-recommended).
Nevertheless, at some point I found this sharp underrated
[answer](http://serverfault.com/a/760244) to "docker volume container or
docker volume?" on severfault which refers to
[this](https://github.com/docker/docker/issues/20465) issue
and [this](https://github.com/docker/docker/issues/17798) one (especially [this](https://github.com/docker/docker/issues/17798#issuecomment-154815207) post
and [this](https://github.com/docker/docker/issues/17798#issuecomment-154820406)
one). So, I would advise to stop using data volume containers and switch to data volumes using the `docker volume` command.

```bash
docker volume create --name grafana-storage
docker run \
  -d \
  -p 3000:3000 \
  --name=grafana \
  -v grafana-storage:/var/lib/grafana \
  fg2it/grafana-armhf:<tag>
```

You need at least docker v1.9 for this. See the [data volume](https://docs.docker.com/engine/tutorials/dockervolumes/#/data-volumes)
documentation on docker.

## Installing plugins for Grafana (since v3)

Pass the plugins you want installed to docker with the `GF_INSTALL_PLUGINS` environment variable as a comma seperated list. This will pass each plugin name to `grafana-cli plugins install ${plugin}`.

```bash
docker run \
  -d \
  -p 3000:3000 \
  --name=grafana \
  -e "GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource" \
  fg2it/grafana-armhf:<tag>
```

## Running specific version of Grafana

```bash
# specify right tag, e.g. v2.6.0 - see Docker Hub for available tags
docker run \
  -d \
  -p 3000:3000 \
  --name grafana \
  fg2it/grafana-armhf:v2.6.0
```

## Building a custom Grafana image with pre-installed plugins

Dockerfile:

```Dockerfile
FROM fg2it/grafana:5.0.0
ENV GF_PATHS_PLUGINS=/opt/grafana-plugins
RUN mkdir -p $GF_PATHS_PLUGINS
RUN grafana-cli --pluginsDir $GF_PATHS_PLUGINS plugins install grafana-clock-panel
```

Add lines with `RUN grafana-cli ...` for each plugin you wish to install in your custom image. Don't forget to specify what version of Grafana you wish to build from (replace 5.0.0 in the example).

Example of how to build and run:

```bash
docker build -t grafana:5.0.0-custom .
docker run \
  -d \
  -p 3000:3000 \
  --name=grafana \
  grafana:5.0.0-custom
```

## Configuring AWS credentials for CloudWatch support

```bash
docker run \
  -d \
  -p 3000:3000 \
  --name=grafana \
  -e "GF_AWS_PROFILES=default" \
  -e "GF_AWS_default_ACCESS_KEY_ID=YOUR_ACCESS_KEY" \
  -e "GF_AWS_default_SECRET_ACCESS_KEY=YOUR_SECRET_KEY" \
  -e "GF_AWS_default_REGION=us-east-1" \
  fg2it/grafana-armhf:<tag>
```

You may also specify multiple profiles to `GF_AWS_PROFILES` (e.g.
`GF_AWS_PROFILES=default another`).

Supported variables:

- `GF_AWS_${profile}_ACCESS_KEY_ID`: AWS access key ID (required).
- `GF_AWS_${profile}_SECRET_ACCESS_KEY`: AWS secret access  key (required).
- `GF_AWS_${profile}_REGION`: AWS region (optional).

## See

- [Unofficial Grafana deb](https://github.com/fg2it/grafana-on-raspberry/releases)
