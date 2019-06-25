#!/bin/bash

GCLOUD_SDK_VERSION="251.0.0"
GCLOUD_FORCE_UPDATE="false"

GCLOUD_PROJECT_NAME="ci-system"
GCLOUD_COMPUTE_ZONE="asia-east1-a"

set -xe

# Install Google Cloud SDK
if [ ! -d "$HOME/google-cloud-sdk" ] || [[ $GCLOUD_FORCE_UPDATE == "true" ]]; then
	curl https://sdk.cloud.google.com | bash > /dev/null
fi
source $HOME/google-cloud-sdk/path.bash.inc

# Install kubectl to manage k8s
gcloud components update kubectl

# Authenticate with Google Cloud
gcloud auth activate-service-account --key-file "$K8S_SERVICE_ACCOUNT_FILE"
gcloud config set project $GCLOUD_PROJECT_NAME
gcloud config set compute/zone $GCLOUD_COMPUTE_ZONE

pwd
ls
