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


updated the workflow to use real python instead of just echo strings
added scikit-learn to training step to make a real model.joblib file

## Current status:
Workflow is failing. i keep getting "mapping values are not allowed in this context" error when i try to run `argo submit`. 
I think its something with the way i am putting the python code inside the yaml file but not sure.

## to do:
- fix the yaml syntax error
- actually load the model in the server pod
- add a service so we can port-forward properly (pod only right now)