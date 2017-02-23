#!/bin/bash
_repo_tag=$1
_grafana_stamp=$2
_docker_tag=$3
_pkg_name=$1

if [ -z "${_repo_tag}" ]; then
  source GRAFANA_META
  _repo_tag=$REPO_TAG
  _grafana_stamp=$GRAFANA_STAMP
  _docker_tag=${REPO_TAG%-testing}
  _grafana_version=${_docker_tag#v}
  if [[ ${_grafana_version} == *beta* ]]; then
    _pkg_name=${_grafana_version/-beta/-${GRAFANA_STAMP}beta}
  else
    _pkg_name=${_grafana_version}-${GRAFANA_STAMP}
  fi
fi

echo "REPO_TAG : ${_repo_tag}"
echo "GRAFANA PACKAGE NAME: ${_pkg_name}"
echo "DOCKER TAG: ${_docker_tag}"

docker build                                   \
  --pull                                       \
  --build-arg REPO_TAG=${_repo_tag}            \
  --build-arg PKG_NAME=${_pkg_name}            \
  --tag "fg2it/grafana-armhf:${_docker_tag}" .
