set -e -u -x

echo "" > generated-pipelines.yaml
ls meta-pipeline/services | awk '{ print "SERVICE="$1" envsubst < meta-pipeline/infrastructure/pipelines/meta/gosvcpipeline.yaml >> generated-pipelines.yaml" }' | sh