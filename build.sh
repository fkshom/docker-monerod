#!/usr/bin/env bash

set -ue

function usage() {
  cat << EOF
  Update the node docker images.
  Usage:
    $0 [-s] [MAJOR_VERSION(S)] [VARIANT(S)]
  Examples:
    - update.sh                      # Update all images
  OPTIONS:
    -s Security update; skip updating the yarn and alpine versions.
    -b CI config update only
    -h Show this message
EOF
}

enable_push=0
for OPT in "$@"; do
  case $OPT in
      --push)
          enable_push=1
          ;;
  esac
  shift
done

DOCKER_REGISTORY=gitlab.com/fkshom/docker-monerod
TAG=${1:-latest}
echo docker build -t ${DOCKER_REGISTORY}:${TAG} .

if [ ${enable_push} -eq 1 ]; then
  echo docker push ${DOCKER_REGISTORY}:${TAG}
fi
