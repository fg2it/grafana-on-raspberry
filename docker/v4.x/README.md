# Unofficial Grafana Docker image for armhf

---

## **Warning Notice: End of Life**

Starting from [v5.2.0-beta1](https://github.com/grafana/grafana/releases/tag/v5.2.0-beta1) Grafana introduced [official support](https://grafana.com/grafana/download/5.2.0-beta1?platform=arm) for armv7 and arm64 linux platforms. Many thanks to them for that.

As a consequence, this repo is no more needed and stops support starting from v5.2.0-beta1.

If you are using unofficial builds from this repo, you are invited to upgrade to official builds.

> Should you need armv6 build, you are invited to ask official support.

---

> here v4.x stands for any of v4.0.0-beta[1-2], v4.0.[1-2], v4.1.0-beta1, v4.1.[0-2], v4.2.0-beta1, v4.2.0, v4.3.0-beta1, v4.3.[0-2], v4.4.[0-3], v4.5.0-beta1, v4.5.[0-2], v4.6.0-beta[1-3], v4.6.[0-3]
>
> ... and also v5.0.0-beta[1-5], v5.0.[0-4] and v5.1.xx

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
one](https://github.com/grafana/grafana-docker/blob/61f378236434fca515248c4012bb1414cc77386c/README.md).

## Caution

It was tested on raspberry pi 2 and pi 3, and won't work on pi 1.

## Running your Grafana container

Start your container binding the external port `3000`.

```bash
docker run -d --name=grafana -p 3000:3000 fg2it/grafana-armhf:<tag>
```

Try it out, default admin user is admin/admin.

In case port 3000 is closed for external clients or there is no access
to the browser - you may test it by issuing:

```bash
curl -i localhost:3000/login
```

Make sure that you are getting "...200 OK" in response.
After that continue testing by modifying your client request to grafana.

## Configuring your Grafana container

All options defined in conf/grafana.ini can be overridden using environment
variables by using the syntax `GF_<SectionName>_<KeyName>`. For example:

```bash
docker run \
  -d \
  -p 3000:3000 \
  --name=grafana \
  -e "GF_SERVER_ROOT_URL=http://grafana.server.name" \
  -e "GF_SECURITY_ADMIN_PASSWORD=secret" \
  fg2it/grafana-armhf:<tag>
```

You can use your own grafana.ini file by using environment variable `GF_PATHS_CONFIG`.

More information in the grafana configuration [documentation](http://docs.grafana.org/installation/configuration/).

## Grafana container with persistent storage (recommended)

```bash
# create a persistent volume for your data in /var/lib/grafana (database and plugins)
docker volume create --name grafana-storage

# start grafana
docker run \
  -d \
  -p 3000:3000 \
  --name=grafana \
  -v grafana-storage:/var/lib/grafana \
  fg2it/grafana-armhf:<tag>
```
Note: An unnamed volume will be created for you when you boot Grafana,
using `docker volume create grafana-storage` just makes it easier to find
by giving it a name.

You need at least docker v1.9 for this. See the [data volume](https://docs.docker.com/engine/tutorials/dockervolumes/#/data-volumes)
documentation on docker.

## Installing plugins for Grafana

Pass the plugins you want installed to docker with the `GF_INSTALL_PLUGINS` environment variable as a comma separated list. This will pass each plugin name to `grafana-cli plugins install ${plugin}`.

```bash
docker run \
  -d \
  -p 3000:3000 \
  --name=grafana \
  -e "GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource" \
  fg2it/grafana-armhf:<tag>
```

## Building a custom Grafana image with pre-installed plugins

The `custom/` folder includes a `Dockerfile` that can be used to build a custom Grafana image. It accepts `GRAFANA_VERSION` and `GF_INSTALL_PLUGINS` as build arguments.

Example of how to build and run:

```bash
cd custom
docker build -t grafana:v5.0.4-with-plugins \
  --build-arg "GRAFANA_VERSION=v5.0.4" \
  --build-arg "GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource" .
docker run \
  -d \
  -p 3000:3000 \
  --name=grafana \
  grafana:v5.0.4-with-plugins
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
