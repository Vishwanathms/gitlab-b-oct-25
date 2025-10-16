# Kubernetes lab: Horizontal and Vertical Pod Autoscaling (HPA & VPA) — Step-by-step

Goal — show how to enable and test **Horizontal Pod Autoscaler (HPA)** and **Vertical Pod Autoscaler (VPA)** for a *running deployment*, and how to simulate load inside a pod using the commands you supplied:

```bash
kubectl exec -it <your-pod-name> -- sh
apt-get update && apt-get install -y stress
stress --cpu 2 --timeout 120
```

This lab covers two flows:

1. If you already have a running deployment — how to add resource requests/limits, enable HPA and VPA and test.
2. If you **don’t** have one — create a small sample deployment that is easy to stress and test.

> Notes before starting
>
> * You need `kubectl` configured to talk to a cluster, and cluster RBAC allowing you to deploy components (metrics server, VPA components if required).
> * HPA requires the **metrics API** (metrics-server) to be available. VPA requires its controller components installed.
> * Some container images (minimal/alpine/scratch) may not have `apt-get` — adjust the install command (`apk add --no-cache stress` for Alpine, or use a Debian-based image). I call out alternatives below.

---

## Prerequisites (verify)

Run:

```bash
kubectl version --short
kubectl cluster-info
kubectl get nodes
```

Check you can list and edit deployments:

```bash
kubectl get deployments --all-namespaces
```

Check if metrics-server is present:

```bash
kubectl get deployment metrics-server -n kube-system
kubectl top nodes
kubectl top pods
```

If `kubectl top` returns metrics, metrics-server (or equivalent) is installed and working.

---

## PART A — If you already have a running deployment (recommended quick path)

### 1. Identify your deployment and a pod

Replace `my-deploy` below with your deployment name.

```bash
kubectl get deploy
kubectl get pods -l app=<label-if-applicable>  # or use selector you normally use
```

Pick one pod name for testing:

```bash
POD=$(kubectl get pods -l app=<your-app-label> -o jsonpath='{.items[0].metadata.name}')
echo $POD
```

### 2. Ensure your deployment sets CPU requests & limits

HPA scales on CPU% derived from `requests`. VPA uses requests/limits as well.

If your deployment **does not** have requests/limits, patch it (example sets request 100m, limit 500m):

```bash
kubectl patch deploy <your-deploy> --type='json' -p='[
  {"op":"replace","path":"/spec/template/spec/containers/0/resources",
   "value":{"requests":{"cpu":"100m","memory":"128Mi"},"limits":{"cpu":"500m","memory":"256Mi"}}}
]'
```

To verify:

```bash
kubectl get deploy <your-deploy> -o=jsonpath='{.spec.template.spec.containers[0].resources}' | jq .
```

### 3. Install metrics-server (if `kubectl top` fails)

If `kubectl top pods` errors, you must install metrics-server. A typical install is:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# wait a bit:
kubectl -n kube-system rollout status deployment/metrics-server
kubectl top pods
```

(If your environment blocks direct GitHub URLs, fetch the file separately and `kubectl apply -f` from local.)

### 4. Create an HPA for your deployment (quick)

Use `kubectl autoscale` — it creates an HPA object that targets CPU utilization:

```bash
kubectl autoscale deployment/<your-deploy> --cpu-percent=50 --min=1 --max=10
```

Verify:

```bash
kubectl get hpa
kubectl describe hpa
```

### 5. Simulate CPU load inside a pod (your provided commands)

Pick a pod from the deployment and exec into it.

**Important**: Your `apt-get` command requires a Debian/Ubuntu-based container image. If your container is Alpine, use `apk add --no-cache stress`. If it’s truly minimal and lacks a package manager, you can run a separate utility pod (example below).

Example (if `apt-get` available inside pod):

```bash
kubectl exec -it $POD -- sh -c "apt-get update && apt-get install -y stress"
kubectl exec -it $POD -- sh -c "stress --cpu 2 --timeout 120"
```

Alternative (Alpine):

```bash
kubectl exec -it $POD -- sh -c "apk add --no-cache stress"
kubectl exec -it $POD -- sh -c "stress --cpu 2 --timeout 120"
```

Alternative if your app container does not allow installs: run a one-off debug pod (Debian) in the same node or same namespace that targets the service (you just need to generate CPU load on the deployment pods; easiest is to `kubectl run` a sidecar pod or attach `stress` to a real target container — but HPA measures CPU per pod, so you must create CPU load inside the target pods themselves or replace them with a test image):

Run a debug pod that mounts the CPU namespace of a target pod — advanced. Simpler: temporarily patch the deployment to use a Debian-based image with your app or add an init container. (This is described in troubleshooting below.)

### 6. Observe HPA reaction

While stress runs (120s), watch:

```bash
kubectl top pods -w
kubectl get hpa -w
kubectl get deploy <your-deploy> -w
```

You should see CPU usage of pods rise, HPA scale `REPLICAS` up (within min/max) and new pods coming up. After load ends, HPA will scale down (observe cooldown — default 5 minutes).

### 7. Clean up HPA (if desired)

```bash
kubectl delete hpa <your-deploy>
# or:
kubectl autoscale deployment/<your-deploy> --min=1 --max=1 --cpu-percent=1
```

---

## PART B — If you **don’t** have a convenient deployment (create a test deployment)

Create a simple deployment that runs a small HTTP server on a Debian-based image and allows apt-get to install `stress`.

### 1. Create `stress-test` deployment manifest

Save as `stress-deploy.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: stress-test
  labels:
    app: stress-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: stress-test
  template:
    metadata:
      labels:
        app: stress-test
    spec:
      containers:
      - name: stress-test
        image: ubuntu:22.04
        command: ["sh","-c"]
        args:
          - apt-get update && apt-get install -y python3 python3-pip && \
            pip3 install flask && \
            cat > /app/server.py <<'PY'
from flask import Flask
app=Flask(__name__)
@app.route("/")
def ok(): return "ok"
app.run(host="0.0.0.0", port=8080)
PY
            python3 /app/server.py
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "500m"
            memory: "256Mi"
        ports:
        - containerPort: 8080
```

Apply it:

```bash
kubectl apply -f stress-deploy.yaml
kubectl get pods -l app=stress-test -w
```

### 2. Create HPA:

```bash
kubectl autoscale deployment/stress-test --cpu-percent=50 --min=1 --max=10
kubectl get hpa
```

### 3. Exec in the pod and run `stress` (this image used apt-get so install works)

```bash
POD=$(kubectl get pod -l app=stress-test -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD -- sh -c "apt-get update && apt-get install -y stress"
kubectl exec -it $POD -- sh -c "stress --cpu 2 --timeout 120"
```

Watch `kubectl top pods` and `kubectl get hpa -w` to see scaling.

---

## PART C — Vertical Pod Autoscaler (VPA)

> **Warning:** VPA may evict and recreate pods to apply new resource recommendations (depending on `updateMode`). VPA works best for stateful or jobs where horizontal scaling is not a fit — use carefully in production.

### 1. Install VPA controller components (if not present)

The VPA is provided by the Kubernetes Autoscaler project. A typical install is to apply the VPA release YAML from the autoscaler repo. Example (run from a machine with internet access):

```bash
kubectl apply -f https://github.com/kubernetes/autoscaler/releases/latest/download/vertical-pod-autoscaler.yaml
```

(If your environment disallows direct URL, download the YAML and `kubectl apply -f` locally.)

Verify:

```bash
kubectl get pods -n kube-system | grep vpa
kubectl get crd | grep verticalpodautoscalers
```

### 2. Create a VPA object (recommendation mode first)

Create `vpa-recommend.yaml`:

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: stress-test-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind:       "Deployment"
    name:       "stress-test"
  updatePolicy:
    updateMode: "Off"   # Off for safe testing; other options: "Auto" or "Recreate"
```

Apply:

```bash
kubectl apply -f vpa-recommend.yaml
kubectl describe vpa stress-test-vpa
```

Check recommendations after some workload runs:

```bash
kubectl get vpa stress-test-vpa -o yaml
# or
kubectl describe vpa stress-test-vpa
```

Look for `recommendation` section which suggests CPU/memory.

### 3. Apply VPA in `Auto` mode (to let it change requests automatically)

**Caution**: This mode may evict pods to update resources.

Edit or apply:

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: stress-test-vpa
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind:       "Deployment"
    name:       "stress-test"
  updatePolicy:
    updateMode: "Auto"
```

Apply:

```bash
kubectl apply -f vpa-auto.yaml
```

Watch pods — VPA may evict pods and new pods will come up with updated requests/limits. You can check the updated resources in the deployment's PodTemplate or the new pods.

### 4. Observe

* Recommendations: `kubectl describe vpa stress-test-vpa`
* Pod resources: `kubectl describe pod <pod-name>` -> check `Limits:` and `Requests:`
* Note: VPA updates often change the deployment template on eviction or annotate pods — check docs for exact behaviour for your VPA version.

### 5. Combining HPA + VPA

* **Caveat:** HPA relies on replica count; VPA changes per-pod resources. Running both `Auto` VPA and CPU-based HPA can cause oscillations because VPA changes requests which changes the CPU% calculation used by HPA. Best practice:

  * Use VPA in `recommend` or `off` for workloads horizontally scaled by HPA, or
  * Use HPA for stateless scalable services and VPA for workloads that should change size but not replica count — test carefully.

---

## Useful commands (summary)

Monitor resources:

```bash
kubectl top nodes
kubectl top pods
kubectl get hpa
kubectl describe hpa <hpa-name>
kubectl get vpa
kubectl describe vpa <vpa-name>
kubectl get deploy <deploy-name> -o yaml
kubectl get pods -l app=<label> -o wide
```

HPA create (alternative YAML method):

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: stress-test
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

Apply with `kubectl apply -f hpa.yaml`.

---

## Troubleshooting & Tips

* `kubectl top` returns `<error: metrics not available>` → metrics-server not installed or misconfigured (check TLS args and API aggregation). Re-install metrics-server and confirm `kubectl -n kube-system logs deployment/metrics-server`.
* `stress` install fails (no apt) → container image is minimal. Options:

  * Use `apk add` for Alpine: `apk add --no-cache stress`.
  * Run a temporary Debian pod in same namespace, or modify your deployment to use a Debian-based image during the lab.
* HPA doesn't scale even though CPU is high:

  * Check deployment has CPU **requests** set. HPA uses requested CPU as the baseline for percentage calculation.
  * Confirm metrics-server is returning `kubectl top pods` metrics.
* VPA not recommending anything → ensure enough historical resource usage; run load for some time so VPA sees usage patterns.
* Prevent oscillations when using HPA + VPA: use VPA in `Off` or `Recommend` mode for workloads horizontally scaled, or use HPA with custom metrics that aren’t affected by per-pod resource changes.

---

## Cleanup (optional)

```bash
kubectl delete deployment stress-test
kubectl delete hpa stress-test
kubectl delete vpa stress-test-vpa
# if you installed metrics-server and want to remove:
kubectl delete -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# if you installed VPA components:
kubectl delete -f https://github.com/kubernetes/autoscaler/releases/latest/download/vertical-pod-autoscaler.yaml
```

---

## Quick checklist you can copy-paste to run the full demo (assuming you need a sample deployment)

```bash
# 1. create test deployment
kubectl apply -f stress-deploy.yaml

# 2. install metrics-server if needed
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl -n kube-system rollout status deployment/metrics-server

# 3. create HPA
kubectl autoscale deployment/stress-test --cpu-percent=50 --min=1 --max=10

# 4. exec into pod and simulate load
POD=$(kubectl get pod -l app=stress-test -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD -- sh -c "apt-get update && apt-get install -y stress"
kubectl exec -it $POD -- sh -c "stress --cpu 2 --timeout 120" &

# 5. monitor
kubectl top pods -w
kubectl get hpa -w
```

