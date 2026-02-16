# KServe

Model serving (InferenceService CRD). Deploy via Argo CD.

## Deploy

```bash
# KServe is typically installed via kubectl/Helm
# Add Application when ready
kubectl apply -f applications.yaml
```

## App repo

weather-api-fastapi: add kserve InferenceService manifests under mlops/realtime-inference/overlays/{dev,uat,prod}.
