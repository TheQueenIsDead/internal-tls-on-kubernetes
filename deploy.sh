#!/usr/bin/env bash

set -e

# Increment build count
BUILD_FILE=".build"
if [ ! -f $BUILD_FILE ]; then
  BUILD=1
else
  BUILD=$(cat $BUILD_FILE)
  BUILD=$(($BUILD+1))
fi;
echo $BUILD > $BUILD_FILE


# Build the image
echo "Building image:"
docker build . -t "client-demo:$BUILD"
#minikube image build -t "client-demo:$BUILD" .
echo "Done"

## Load into minikube
echo "Loading image:"
minikube image load "client-demo:$BUILD"
minikube image ls | grep $BUILD
echo "Done"

# Deploy changed app, bear in mind it has a different image name in the minikube lib
echo "Deleting deployment"
kubectl delete deployment client-deployment --force=true --grace-period=0 --wait
echo "Done"
echo "Creating deployment"
kubectl apply -f kubernetes.yml
kubectl set image deployment client-deployment client="docker.io/library/client-demo:$BUILD"
echo "Done"
