red=$'\e[1;31m'
grn=$'\e[1;32m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
white=$'\e[0m'

case $(uname | tr '[:upper:]' '[:lower:]') in
  linux*)
    export OS_NAME=linux
    ;;
  darwin*)
    export OS_NAME=osx
    ;;
  msys*)
    export OS_NAME=windows
    ;;
  *)
    export OS_NAME=notset
    ;;
esac

echo $blu Running on $OS_NAME $white
echo ""

echo $mag Starting minikube ci $white
minikube start -p ci
kubectl config use-context ci

echo $mag Installing Concourse... $white
helm repo add concourse https://concourse-charts.storage.googleapis.com/
helm repo update 
kubectl apply -f infrastructure/namespaces/ci.yaml
LOCAL_IP=`minikube -p ci ip`
echo $blu Hosting on $LOCAL_IP $white
helm upgrade ci concourse/concourse --version=8.4.1 --namespace ci --install --force --wait -f <(envsubst < infrastructure/thirdparties/concourse.yaml) 
echo $grn Installed Concourse $white
echo ""

echo $mag Setting up ingress... $white
minikube -p ci addons enable ingress
kubectl apply -f infrastructure/ingresses/concourse.yaml
echo $grn Setup ingress, access Concourse on http://$LOCAL_IP:80/ $white
echo ""

echo $mag Installing fly... $white
case $OS_NAME in
    osx)
        wget -O fly "http://$LOCAL_IP/api/v1/cli?arch=amd64&platform=darwin" ;;
    windows)
        wget -O fly "http://$LOCAL_IP/api/v1/cli?arch=amd64&platform=windows" ;;
    linux)
        wget -O fly "http://$LOCAL_IP/api/v1/cli?arch=amd64&platform=linux" ;;
    *)
        exit 1 ;;
esac
chmod +x fly
echo $grn installed fly $white
echo ""

echo $mag Logging into concourse... $white
./fly --target example login --team-name main --username test --password test --concourse-url http://$LOCAL_IP/
echo $grn logged into concourse $white

echo $mag Configuring pipelines... $white
PRIVATE_REPO_KEY=`cat ~/.ssh/id_rsa`
kubectl create secret generic -n ci-main git --from-literal=private-repo-key=$PRIVATE_REPO_KEY
kubectl create secret generic -n ci-main concourse --from-literal=username=test --from-literal=password=test
./fly -t example set-pipeline \
    --pipeline meta-pipeline \
    --config <(envsubst < infrastructure/pipelines/meta-pipeline.yaml) \
echo $grp configured pipelines $white