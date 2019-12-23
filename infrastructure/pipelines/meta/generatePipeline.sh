set -e -u -x

ls meta-pipeline/services | awk '{print "SERVICE="$1 "generated-pipelines.yaml << (envsubst < meta-pipeline/infrastructure/pipelines/meta/gosvcpipeline.yaml)" }' | bash