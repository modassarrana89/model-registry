#!/usr/bin/env bash

set -e

# see Makefile for the IMG_ variables semantic
IMG_REGISTRY="quay.io"
IMG_ORG="${IMG_ORG:-morana/kubeflow}"
IMG_REPO="${IMG_REPO:-model-registry}"
DOCKER_USER="morana"
DOCKER_PWD="Cgkc6cGY0aAgyqDboVQceocJuH5Vw7CSs+FZ/x4KDYGTTMSun/eTYydqZqSLw3kPpq8HOeDseHPOcAMEQmwJLA=="

# image version
HASH="$(git rev-parse --short=7 HEAD)"
VERSION="${VERSION:-$HASH}"

# if set to 0 skip image build
# otherwise build it
BUILD_IMAGE="${BUILD_IMAGE:-true}"

# if set to 0 skip push to registry
# otherwise build and push it
BUILD_PUSH_IMAGE="${BUILD_PUSH_IMAGE:-false}"

# skip if image already existing on registry
SKIP_IF_EXISTING="${SKIP_IF_EXISTING:-false}"

# assure docker exists
docker -v foo >/dev/null 2>&1 || {
    echo >&2 "::error:: Docker is required.  Aborting."
    exit 1
}

# if quay.io, can opt to skip if image already existing
if [[ "${SKIP_IF_EXISTING,,}" == "true" && "${IMG_REGISTRY,,}" == "quay.io" ]]; then
    TAGS=$(curl --request GET "https://$IMG_REGISTRY/api/v1/repository/${IMG_ORG}/${IMG_REPO}/tag/?specificTag=${VERSION}")
    LATEST_TAG_HAS_END_TS=$(echo "$TAGS" | jq .tags - | jq 'sort_by(.start_ts) | reverse' | jq '.[0].end_ts')
    NOT_EMPTY=$(echo "${TAGS}" | jq .tags - | jq any)

    # Image only exists if there is a tag that does not have "end_ts" (i.e. it is still present).
    if [[ "$NOT_EMPTY" == "true" && $LATEST_TAG_HAS_END_TS == "null" ]]; then
        echo "::error:: The image ${IMG_ORG}/${IMG_REPO}:${VERSION} already exists"
        exit 1
    else
        echo "Image does not exist...proceeding with build & push."
    fi
fi

# build docker image, login is not required at this step
if [[ "${BUILD_IMAGE,,}" == "true" ]]; then
    echo "Building container image.."
    make \
        IMG_REGISTRY="${IMG_REGISTRY}" \
        IMG_ORG="${IMG_ORG}" \
        IMG_REPO="${IMG_REPO}" \
        IMG_VERSION="${VERSION}" \
        image/build
else
    echo "Skip container image build."
fi

# build and push container image to registry
if [[ "${BUILD_PUSH_IMAGE,,}" == "true" ]]; then
    echo "Build & Push multi-arch container image.."
    make \
        IMG_REGISTRY="${IMG_REGISTRY}" \
        IMG_ORG="${IMG_ORG}" \
        IMG_REPO="${IMG_REPO}" \
        IMG_VERSION="${VERSION}" \
        image/buildx
else
    echo "Skip container image build and push."
fi
