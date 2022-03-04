
#!/bin/sh
set -e

pwd=$(pwd)
hash=$(git describe --match "v[0-9]*" --tags $(git rev-list --tags --max-count=1))
#
## Install Kind
curl -Lo $pwd/kind https://kind.sigs.k8s.io/dl/v0.11.0/kind-linux-amd64
chmod a+x $pwd/kind

echo "kind load docker-image ${REPO}/kyverno:$hash"

## Create Kind Cluster
$pwd/kind create cluster
$pwd/kind load docker-image ${REPO}/kyverno:$hash
$pwd/kind load docker-image ${REPO}/kyvernopre:$hash

pwd=$(pwd)
cd $pwd/definitions
echo "Installing kustomize"
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
kustomize edit set image ${REPO}/kyverno:$hash
kustomize edit set image ${REPO}/kyvernopre:$hash
kustomize build $pwd/definitions/ -o $pwd/definitions/install.yaml
