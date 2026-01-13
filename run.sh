#!/bin/bash
set -e

echo "cleaning up old stuff..."
argo delete -n argo --all || true
kubectl delete pod model-server-pod -n argo --ignore-not-found

kubectl apply -f pvc.yaml

echo "submitting argo..."
argo submit -n argo workflow.yaml --watch

echo "pipeline done. try port forward now"

kubectl port-forward -n argo pod/model-server-pod 8080:8080