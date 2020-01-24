set -e -u -x

ls meta-pipeline/services | awk '{ print "SERVICE="$1" envsubst < meta-pipeline/infrastructure/pipelines/meta/gosvcpipeline.yaml >> out/generated-pipelines.yaml" }' | sh