#!/bin/sh

set -e

DIR="$( cd "$( dirname "$0" )" && pwd )"
REPO_ROOT="$(git rev-parse --show-toplevel)"
PLATFORM="linux/amd64"
OCI_OUTPUT="$REPO_ROOT/build/oci"
DOCKERFILE="$REPO_ROOT/Dockerfile"

export DOCKER_BUILDKIT=1
export SOURCE_DATE_EPOCH=1

echo $DOCKERFILE
docker build -f "$DOCKERFILE" "$REPO_ROOT" \
	--platform "$PLATFORM" \
	--output type=oci,rewrite-timestamp=true,force-compression=true,dest=$OCI_OUTPUT/zallet.tar,name=zallet \
	"$@"
