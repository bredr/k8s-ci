set -e -u -x

ls meta-pipeline/services | awk '{ print "SERVICE="$1" envsubst < meta-pipeline/infrastructure/pipelines/meta/gosvcpipeline.yaml > out/"$1".yaml" }' | sh
echo 'pipelines:' > out/generated-pipelines.yaml
ls meta-pipeline/services | awk '{ print "SERVICE="$1" envsubst < meta-pipeline/infrastructure/pipelines/meta/metapipeline.yaml >> out/generated-pipelines.yaml" }' | sh

cat out/generated-pipelines.yaml