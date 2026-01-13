#!/bin/bash
set -e

# setup kind
kind create cluster --name ml-local || echo "cluster already there"

# argo install
kubectl create ns argo || true
kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/latest/download/quick-start-minimal.yaml

# storage
kubectl apply -f pvc.yaml

# run it
argo submit -n argo workflow.yaml --watch