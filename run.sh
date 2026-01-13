#!/bin/bash
set -e

# 1. Cluster Setup
if ! kind get clusters | grep -q "ml-local"; then
  echo "Creating Kind Cluster..."
  kind create cluster --name ml-local
else
  echo "Cluster already exists."
fi

# 2. Argo Installation
echo "Installing Argo Workflows..."
kubectl create namespace argo --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argo -f https://github.com/argoproj/argo-workflows/releases/latest/download/quick-start-minimal.yaml

# 3. Permissions
echo "Setting up permissions..."
kubectl create clusterrolebinding argo-admin-binding \
  --clusterrole=admin \
  --serviceaccount=argo:default \
  --namespace=argo --dry-run=client -o yaml | kubectl apply -f -

# 4. Create the ConfigMap
echo "Creating Server ConfigMap..."
kubectl create configmap model-server-code -n argo \
  --from-literal=server.py="
import uvicorn
from fastapi import FastAPI, Body
import joblib
import numpy as np
import os

app = FastAPI()
MODEL_PATH = '/mnt/model/model.joblib'

@app.get('/')
def read_root():
    exists = os.path.exists(MODEL_PATH)
    return {'status': 'LIVE', 'model': 'LogisticRegression', 'artifact_found': exists}

@app.post('/predict')
def predict(features: list = Body(...)):
    if not os.path.exists(MODEL_PATH):
        return {'error': 'Model file not found on storage'}
    
    model = joblib.load(MODEL_PATH)
    data = np.array(features).reshape(1, -1)
    prediction = model.predict(data)
    return {'prediction': int(prediction[0])}

if __name__ == '__main__':
    uvicorn.run(app, host='0.0.0.0', port=8080)
" --dry-run=client -o yaml | kubectl apply -f -

# 5. Storage
echo "Provisioning PVC..."
kubectl apply -f pvc.yaml

echo "Waiting for Argo Controller..."
kubectl wait --for=condition=available --timeout=300s deployment/workflow-controller -n argo

# 6. Run Pipeline
echo "Submitting Workflow..."
argo delete -n argo --all || true
kubectl delete pod model-server-pod -n argo --ignore-not-found || true
kubectl delete svc model-service -n argo --ignore-not-found || true

argo submit -n argo --watch workflow.yaml

echo ""
echo "Pipeline Finished Successfully!"
echo "--------------------------------------------------"
echo "WAIT 30 SECONDS for the server to install packages, then:"
echo "1. Run: kubectl port-forward -n argo svc/model-service 8080:80"
echo "2. Test: curl -X POST http://localhost:8080/predict -H 'Content-Type: application/json' -d '[1.0, 2.0, -0.5, 1.1]'"