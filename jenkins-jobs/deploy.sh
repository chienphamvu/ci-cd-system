#!/bin/bash

GCLOUD_SDK_VERSION="251.0.0"
GCLOUD_FORCE_UPDATE=${GCLOUD_FORCE_UPDATE:-false}
GCLOUD_PROJECT_ID=${GCLOUD_PROJECT_ID:-web-app-244813}
GCLOUD_COMPUTE_ZONE=${GCLOUD_COMPUTE_ZONE:-asia-east1-a}
GCLOUD_K8S_CLUSTER_NAME=${GCLOUD_K8S_CLUSTER_NAME:-web-app-cluster}

set -xe

GIT_SHA=$(git rev-parse HEAD)

# Build docker image
DOCKER_IMAGE="chienphamvu/php-apache"

docker build -t ${DOCKER_IMAGE}:latest -t ${DOCKER_IMAGE}:${GIT_SHA} .

docker login --username $DOCKER_USR --password $DOCKER_PWD
docker push ${DOCKER_IMAGE}:latest
docker push ${DOCKER_IMAGE}:${GIT_SHA}

# Install Google Cloud SDK
if [ ! -d "$HOME/google-cloud-sdk" ] || [[ $GCLOUD_FORCE_UPDATE == "true" ]]; then
	curl https://sdk.cloud.google.com | bash > /dev/null
fi
source $HOME/google-cloud-sdk/path.bash.inc

# Install kubectl to manage k8s
gcloud components update kubectl

# Authenticate with Google Cloud
gcloud auth activate-service-account --key-file "$K8S_SERVICE_ACCOUNT_FILE"
gcloud config set project $GCLOUD_PROJECT_ID
gcloud config set compute/zone $GCLOUD_COMPUTE_ZONE
gcloud container clusters get-credentials $GCLOUD_K8S_CLUSTER_NAME

# Deploy to K8S
kubectl apply -f k8s
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml

kubectl set image deployments/php-apache php-apache=${DOCKER_IMAGE}:${GIT_SHA}
