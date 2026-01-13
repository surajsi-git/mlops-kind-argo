Finally got everything working perfectly. All the bugs from the last few tries are squashed.

Updates:
- FastAPI fixed: Added the `Body(...)` thing so it stops complaining about missing fields when I curl it.
- Dependencies: Made sure `python-multipart` is installed in the pod startup so it doesnt crash on launch.
- Cleanup: Updated `run.sh` to delete old pods and services first, otherwise redeploying was failing because names already existed.
- ConfigMap: Kept the server code in the configmap, its way easier to manage than nesting it in the yaml.

Deployment:
1. `./run.sh`
2. Wait for the green checks in Argo.
3. `kubectl port-forward -n argo svc/model-service 8080:80`
4. Run the curl test:
   `curl -X POST http://localhost:8080/predict -H "Content-Type: application/json" -d "[1.0, 2.0, -0.5, 1.1]"`

It finally returns the prediction JSON!