#!/bin/bash

set -xe

if [ -z "$TARGET_NB_NODES" ]; then
    JOB_QUEUE_COUNT=$(curl --user ${JENKINS_USR}:${JENKINS_PWD} http://localhost:8080/queue/api/xml | grep -o "<task" | wc -l)
    CURRENT_NODE_COUNT=$(curl --user ${JENKINS_USR}:${JENKINS_PWD} http://localhost:8080/computer/api/json | jq '.computer | length')

    EXECUTOR_PER_NODE=2

    set +e
    TARGET_NB_NODES=`expr $JOB_QUEUE_COUNT / $EXECUTOR_PER_NODE`

    if [ $((JOB_QUEUE_COUNT%2)) -ne 0 ]; then
        TARGET_NB_NODES=`expr $TARGET_NB_NODES + 1`
    fi
    set -e
fi

if [ -n "$TARGET_NB_NODES" ]; then
    if ! [ -d "$WORKSPACE/ci-cd-system" ]; then
        git clone https://github.com/chienphamvu/ci-cd-system.git
    fi

    cd "$WORKSPACE/ci-cd-system/cloud/node"

    terraform init

    terraform apply -auto-approve=true \
                    -var "aws_access_key=${AWS_ACCESS_KEY}" \
                    -var "aws_secret_key=${AWS_SECRET_KEY}" \
                    -var "node_count=${TARGET_NB_NODES}"
fi