red=$'\e[1;31m'
grn=$'\e[1;32m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
white=$'\e[0m'

echo $mag Installing Concourse... $white
helm repo add concourse https://concourse-charts.storage.googleapis.com/
helm repo update 
kubectl apply -f infrastructure/namespaces/ci.yaml
LOCAL_IP=`minikube ip`
echo $blu Hosting on $LOCAL_IP $white
helm upgrade ci concourse/concourse --namespace ci --install --force --wait -f <(envsubst < infrastructure/thirdparties/concourse.yaml) 
echo $grn Installed Concourse $white
echo ""

echo $mag Setting up ingress... $white
minikube addons enable ingress
kubectl apply -f infrastructure/ingresses/concourse.yaml
echo $grn Setup ingress, access Concourse on http://$LOCAL_IP:80/ $white
echo ""