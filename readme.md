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


fixed the yaml issues. used the pipe | for the shell commands so the colons dont break the parser anymore. the argo workflow now actually finishes both steps.

## current issues:
- the pod is created but it keeps crashing. logs show "RuntimeError: Form data requires python-multipart". 
- tried to port-forward but I forgot to make a Service, and doing it to the pod directly is annoying because the name keeps changing if I redeploy.
- I need to load the model properly and return real predictions, right now its just returning 'test'.

## todo:
- install python-multipart in the server pod
- add a Kubernetes Service manifest
- figure out why the python code is so messy inside the yaml file. maybe use a configmap?