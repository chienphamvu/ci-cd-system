#!/bin/bash

set -xe

EXECUTOR_PER_NODE=2

JOB_QUEUE_COUNT=$(curl --user ${JENKINS_USR}:${JENKINS_PWD} http://localhost:8080/queue/api/xml > output.xml | grep -o "<task" | wc -l)
CURRENT_NODE_COUNT=$(curl --user ${JENKINS_USR}:${JENKINS_PWD} http://localhost:8080/computer/api/json | jq '.computer | length')

if [ -n "$TARGET_NB_NODES" ]; then
    while [ $TARGET_NB_NODES -gt 0 ]; do
        echo "hello $TARGET_NB_NODES"

        if [ $TARGET_NB_NODES -eq 1 ]; then
            break
        fi

        TARGET_NB_NODES=`expr $TARGET_NB_NODES - 1`
    done

    if ! [ -d "$WORKSPACE/ci-cd-system.git" ]; then
        git clone https://github.com/chienphamvu/ci-cd-system.git
    fi

    cd "$WORKSPACE/ci-cd-system/cloud/node"

    ls

    terraform init

    # terraform apply -var "aws-access-key=${AWS_ACCESS_KEY}" \
    #                 -var "aws-secret-key=${AWS_SECRET_KEY}"

fi