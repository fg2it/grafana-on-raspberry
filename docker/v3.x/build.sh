#!/bin/bash
_grafana_version=$1
_grafana_stamp=$2
_grafana_tag=$3
_pkg_name=$1

if [ -z "${_grafana_version}" ]; then
        source GRAFANA_META
        _grafana_version=$GRAFANA_VERSION
        _grafana_stamp=$GRAFANA_STAMP
        _grafana_tag=v$GRAFANA_VERSION
        if [[ $GRAFANA_VERSION == *beta* ]]; then
                _pkg_name=${GRAFANA_VERSION/-beta/-${GRAFANA_STAMP}beta}
        else
                _pkg_name=${GRAFANA_VERSION}-${GRAFANA_STAMP}
        fi
fi

echo "GRAFANA PACKAGE NAME: ${_pkg_name}"
echo "DOCKER TAG: ${_grafana_tag}"

docker build                                           \
       --build-arg GRAFANA_VERSION=${_grafana_version} \
       --build-arg PKG_NAME=${_pkg_name}               \
       --tag "fg2it/grafana-armhf:${_grafana_tag}" .
