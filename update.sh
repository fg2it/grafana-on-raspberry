#!/bin/bash

set -x

CFGFILE='grafana.yaml'

usage() {
  base="$(basename "$0")"
  cat <<EOUSAGE
usage: $base [-1|-2|-3|-4|-5] <github tag>
Setup and release new grafana version on grafana-on-raspberry github repo
  -1 do only step 1: create trigger commit
  -2 do only step 2: create tag to trigger deployment
  -3 do only step 3: wait for travis
  -4 do only step 4: create docker image, test and push
  -5 do only step 5: commit docker update
  -h this help
EOUSAGE
}

trigger_commit() {
  echo "dummy commit to trigger ${VERSION} build on ci" > .dummy
  git add .dummy
  git commit -m "trigger ${VERSION}"
  git push
}

deploy_commit() {
  DIGEST=$(git log -n1 --pretty=oneline | cut -f1 -d' ')
  git tag -a ${VERSION} -m ${VERSION} ${DIGEST}
  git push origin ${VERSION}
}

wait_travis() {
  STATE=$(travis history -b ${VERSION} --no-interactive | head -n1 | cut -f2 -d' ')
  sleep 600
  for i in `seq 1 25`; do
    echo ${STATE}
    case ${STATE} in
      passed:)
        break
      ;;
      failed:)
        echo "** Err: Travis build failed"
        echo "** Docker image NOT build"
        echo "** Fail **"
        exit 1
      ;;
    esac
    sleep 60
    STATE=$(travis history -b ${VERSION} --no-interactive | head -n1 | cut -f2 -d' ')
  done
  if [[ ${STATE} != *passed:* ]]; then
    echo "** Err: Travis build timeout (current state: ${STATE})"
    echo "** Docker image NOT build"
    exit 1
  fi
}

docker_image() {
  cd docker/v4.x/
  sed -i "1s/^/- ${VERSION}\n/" ${CFGFILE}
  ./build.py
  ./build.py -t
  ./build.py -p
  cd -
}

docker_commit() {
  git rm .dummy
  git commit -a -m "docker: ${VERSION}"
  git push
}


if [[ `git config user.name` != "fg2it" ]]; then
  echo "Error: Wrong git user"
  exit 1
fi

VERSION=$1
if (( $# != 1 )); then
	VERSION=$2
fi

case $1 in
  -1)
    shift
    trigger_commit
    exit 0
    ;;
  -2)
    shift
    deploy_commit
    exit 0
    ;;
  -3)
    shift
    wait_travis
    exit 0
    ;;
  -4)
    shift
    docker_image
    exit 0
    ;;
  -5)
    shift
    docker_commit
    exit 0
    ;;
  -*)
    usage
    exit 0
    ;;
esac

echo >&2 "1/5 creating trigger commit"
trigger_commit
echo >&2 "2/5 creating tag/trigger deployment"
deploy_commit
echo >&2 "3/5 waiting travis"
wait_travis
echo >&2 "4/5 docker"
docker_image
echo >&2 "5/5 commit docker update"
docker_commit
echo >&2 "Success"
