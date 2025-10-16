 **Horizontal Pod Autoscaler (HPA)** on a running deployment using your provided commands.

---

## 🌐 Kubernetes Lab: Horizontal Pod Autoscaling (HPA)

### 🧩 Objective

Scale pods automatically based on CPU usage.

---

### 🪜 Steps

#### 1️⃣ Create a sample deployment

```bash
kubectl create deployment cpu-demo --image=ubuntu -- sleep 3600
```

#### 2️⃣ Add CPU requests and limits (needed for HPA)

```bash
kubectl set resources deployment cpu-demo \
  --requests=cpu=100m --limits=cpu=500m
```

#### 3️⃣ Deploy the Metrics Server (if not already installed)

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Check:

```bash
kubectl top pods
```

#### 4️⃣ Create HPA

```bash
kubectl autoscale deployment cpu-demo --cpu-percent=50 --min=1 --max=5
```

Check HPA:

```bash
kubectl get hpa
```

#### 5️⃣ Open a shell inside the pod

```bash
POD=$(kubectl get pod -l app=cpu-demo -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD -- sh
```

#### 6️⃣ Install stress tool and generate CPU load

Inside the pod:

```bash
apt-get update && apt-get install -y stress
stress --cpu 2 --timeout 120
```

*(This will create CPU load for 2 minutes)*

#### 7️⃣ Watch autoscaling in action

In another terminal:

```bash
kubectl get hpa -w
kubectl get pods -w
kubectl top pods
```

You’ll see pod replicas increase when CPU usage goes above the target (50%),
and scale down after the load ends.

---

### 🧹 Cleanup

```bash
kubectl delete hpa cpu-demo
kubectl delete deployment cpu-demo
```
