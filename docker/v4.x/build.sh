#!/bin/bash

#set -x

usage() {
  base="$(basename "$0")"
  cat <<EOUSAGE
usage: $base [-d|-t|-p] [repo-tag] [stamp]
Build docker images
  -d show default
  -t create & run docker container
  -p push images to dockerhub
EOUSAGE
}

setup() {
  _repo_tag=$1
  _grafana_stamp=$2

  if [ -z "${_repo_tag}" ]; then
    source GRAFANA_META
    _repo_tag=$REPO_TAG
    _grafana_stamp=$GRAFANA_STAMP
  fi

  _docker_tag=${REPO_TAG%-testing}
  _pkg_name=${_docker_tag#v}
  if [ ! -z "${_grafana_stamp}" ]; then
    if [[ ${_pkg_name} == *beta* ]]; then
      _pkg_name=${_pkg_name/-beta/-${GRAFANA_STAMP}beta}
    else
      _pkg_name=${_pkg_name}-${GRAFANA_STAMP}
    fi
  fi
}

build(){
  echo "Building image for fg2it/grafana-armhf:${_docker_tag}"
  docker build                                   \
    --pull                                       \
    --build-arg REPO_TAG=${_repo_tag}            \
    --build-arg PKG_NAME=${_pkg_name}            \
    --tag "fg2it/grafana-armhf:${_docker_tag}" .
}

test(){
  echo "Running container fg2it/grafana-armhf:${_docker_tag}"
  docker run -ti --rm --name=testgrafana${_docker_tag} -p 9999:3000 fg2it/grafana-armhf:${_docker_tag}
}

push(){
  echo "Docker login:"
  docker login
  echo "Pushing fg2it/grafana-armhf:${_docker_tag}"
  docker push fg2it/grafana-armhf:${_docker_tag}
}

MODE=build

case "$1" in
  -t)
    MODE=test
    shift
    ;;
  -p)
    MODE=push
    shift
    ;;
  -d)
    MODE=default
    shift
    ;;
  -*)
    echo >&2 'error: unknown arg' "$1"
    usage >&2
    exit 1
    ;;
esac

setup

echo "REPO TAG             : ${_repo_tag}"
echo "GRAFANA PACKAGE NAME : ${_pkg_name}"
echo "DOCKER TAG           : ${_docker_tag}"

case $MODE in
  default)
    exit
    ;;
  push)
    push
    ;;
  test)
    test
    ;;
  build)
    build
esac
