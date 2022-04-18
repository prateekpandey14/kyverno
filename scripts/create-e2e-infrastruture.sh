#!/bin/sh
set -e

pwd=$(pwd)

## Install Kind
curl -Lo "$pwd"/kind https://kind.sigs.k8s.io/dl/v0.11.0/kind-linux-amd64
chmod a+x "$pwd"/kind

echo "kind load docker-image ${REPO}/kyverno:$IMAGE_TAG_DEV"

## Create Kind Cluster
if [ -z "${KIND_IMAGE}" ]; then
    "$pwd"/kind create cluster
else
    "$pwd"/kind create cluster --image="${KIND_IMAGE}"
fi

$pwd/kind load docker-image ${REPO}/kyverno:${IMAGE_TAG_DEV}
$pwd/kind load docker-image ${REPO}/kyvernopre:${IMAGE_TAG_DEV}

pwd=$(pwd)
cd "$pwd"/config
echo "Installing kustomize"
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
kustomize edit set image ${REPO}/kyverno:${IMAGE_TAG_DEV}
kustomize edit set image ${REPO}/kyvernopre:${IMAGE_TAG_DEV}
kustomize build $pwd/config/ -o $pwd/config/install.yaml
