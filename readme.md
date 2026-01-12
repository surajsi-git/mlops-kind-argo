# mlops kind argo pipeline

this repo contains a simple local pipeline using kind and argo workflows.

goal:
create a local k8s cluster using kind
run an argo workflow with two steps (train -> serve)
share artifacts between steps using a pvc

running:
- setup steps and commands will be added incrementally


---
## local notes (wip)

simplfied repo structure for now, kept every manifest in the root folder, will decide folder structure once the later stages of assignment are achieved


prereqs:
- docker
- kubectl
- kind
- argo workflows installed in the cluster (wip)

create kind cluster:
kind create cluster --name ml-local

create argo namespace:
kubectl create ns argo

apply pvc:
kubectl apply -f infra/pvc.yaml

apply workflow:
kubectl apply -f workflows/workflow.yaml

check:
kubectl -n argo get pods
kubectl -n argo get wf
