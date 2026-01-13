= MLOps Pipeline on Local Kubernetes

[+] Project Overview

This repository contains a fully automated MLOps pipeline that runs on a local Kubernetes cluster. It covers the end-to-end lifecycle of a simple model: local cluster provisioning, workflow execution, model training, and model serving for inference.

[+] System Architecture

The pipeline is orchestrated using Argo Workflows and implemented as a DAG. Training runs in a Python container that installs scikit-learn, generates synthetic data, trains a Logistic Regression model, and writes the trained model artifact to a shared PVC. Serving uses a kubectl task to launch a FastAPI pod that mounts the same PVC to load the trained model, and exposes the API using a Kubernetes Service.

[+] Prerequisites

* Docker Desktop (or Docker Engine)
* kubectl
* kind
* Argo Workflows CLI (optional; used by the script if available)

[+] Repository Layout

* `infra-storage.yaml`: PVC definition used as artifact storage
* `workflow.yaml`: Argo Workflow defining train and serve steps
* `run.sh`: One-click entry point to create infra and run the workflow
* `serve/`: FastAPI serving app and Dockerfile (if included)

[+] Installation and Execution

Clone the repository:


    git clone https://github.com/surajsi-git/mlops-kind-argo.git
    cd mlops-kind-argo

Run the pipeline:

On Linux/macOS/WSL2:

    chmod +x run.sh
    ./run.sh


On Windows (Git Bash):

    sh run.sh

The script will create a kind cluster, install Argo Workflows, apply the PVC manifest, and submit the workflow.

[+] Testing Inference

After the workflow completes, port-forward the service:

    kubectl port-forward -n argo svc/model-service 8080:80


Health check:

    curl -s http://localhost:8080/health

Prediction request (note: the current training step uses n_features=4, so send 4 values):

Linux/macOS/WSL2:

    curl -s -X POST http://localhost:8080/predict -H "Content-Type: application/json" -d '{"features":[1.0,2.0,-0.5,1.1]}'

Windows PowerShell:

    Invoke-RestMethod -Uri http://localhost:8080/predict -Method Post -Body '{"features":[1.0,2.0,-0.5,1.1]}' -ContentType "application/json"

Example response:

{"prediction": 1}

[+] Cleanup

To remove the local environment:

    kind delete cluster --name ml-local


