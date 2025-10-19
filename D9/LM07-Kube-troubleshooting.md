
## 🧩 **Metrics Server Troubleshooting & Fix Guide (Consolidated Flow)**

### **1️⃣ Problem Overview**

You encountered multiple errors:

| Error                                                                  | Message / Symptom                                                       |
| ---------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| ❌ `error: Metrics API not available`                                   | When running `kubectl top nodes/pods`                                   |
| ⚠️ `Failed to scrape node: connect: connection refused`                | Metrics-server log — cannot connect to kubelet on master node           |
| ⚠️ `Failed to scrape node: request failed, status: "401 Unauthorized"` | Metrics-server log — cannot authenticate to kubelet on worker node      |
| ⚠️ `exec: "curl": executable file not found in $PATH`                  | When trying to test kubelet connectivity from inside metrics-server pod |

---

### **2️⃣ Root Cause Analysis**

| Area                     | Likely Cause                                       | Notes                                                                   |
| ------------------------ | -------------------------------------------------- | ----------------------------------------------------------------------- |
| Kubelet API (port 10250) | Metrics server can’t connect — connection refused  | The kubelet might be listening only on localhost or blocked by firewall |
| Kubelet authentication   | Metrics server not allowed or certificate mismatch | Needs proper TLS or use of `--kubelet-insecure-tls` flag                |
| Pod network / RBAC       | Missing or incorrect permissions                   | Metrics server may lack rights to access kubelet APIs                   |
| Testing environment      | Missing debugging tools                            | Metrics-server image lacks `curl` or `wget`                             |

---

### **3️⃣ Validation & Environment Inspection**

#### ✅ Step 1: Confirm metrics-server pod status

```bash
kubectl get pods -n kube-system | grep metrics-server
kubectl logs -n kube-system <metrics-server-pod-name>
```

You should see logs like:

```
E... scraper.go:149] "Failed to scrape node" err="..."
```

#### ✅ Step 2: Check deployment configuration

```bash
kubectl get deployment metrics-server -n kube-system -o yaml | grep kubelet
```

Ensure these flags exist under the container args:

```yaml
- --kubelet-insecure-tls
- --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
- --metric-resolution=15s
```

If not present — **patch the deployment**:

```bash
kubectl edit deployment metrics-server -n kube-system
```

Add under:

```yaml
spec:
  template:
    spec:
      containers:
      - args:
        - --cert-dir=/tmp
        - --secure-port=10250
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-insecure-tls
```

Save and exit — deployment will auto-rollout.

---

### **4️⃣ Network & Access Validation**

#### ✅ Step 3: Confirm Kubelet API access from a node

Run on the node itself:

```bash
curl -vk https://127.0.0.1:10250/metrics --insecure
```

* If this works, kubelet is up.
* If **connection refused**, check kubelet service:

  ```bash
  sudo systemctl status kubelet
  sudo netstat -tulnp | grep 10250
  ```

If kubelet is running only on localhost, verify kubelet config (`/var/lib/kubelet/config.yaml`):

```yaml
address: 0.0.0.0
readOnlyPort: 10255
```

Ensure it listens on all interfaces.

Then reload:

```bash
sudo systemctl restart kubelet
```

---

### **5️⃣ In-Cluster Debug Test**

Since metrics-server image lacks `curl`, run a debug pod:

```bash
kubectl run debug --rm -i --tty --image=radial/busyboxplus:curl -- /bin/sh
```

Inside the pod, test kubelet access:

```sh
curl -vk https://<node-ip>:10250/metrics --insecure
```

Expected result: You should see plain-text metrics (starts with `# HELP ...`).

If this fails → check firewall or CNI routing.

---

### **6️⃣ Firewall & Port Rules**

Allow inbound access on 10250 for the metrics-server namespace network:

```bash
sudo ufw allow 10250/tcp
sudo iptables -I INPUT -p tcp --dport 10250 -j ACCEPT
```

---

### **7️⃣ RBAC & Permissions Validation**

Ensure Metrics Server has cluster-wide access:

```bash
kubectl get clusterrolebinding | grep metrics-server
```

If missing:

```bash
kubectl create clusterrolebinding metrics-server:system:auth-delegator \
  --clusterrole=system:auth-delegator \
  --serviceaccount=kube-system:metrics-server
```

---

### **8️⃣ Restart and Test**

```bash
kubectl rollout restart deployment metrics-server -n kube-system
sleep 30
kubectl get pods -n kube-system | grep metrics-server
```

Then test:

```bash
kubectl top nodes
kubectl top pods -A
```

✅ **Expected output:**

```
NAME           CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
kube-master01  125m         6%     780Mi           25%
kube-wn01      200m         10%    900Mi           30%
```

---

### **9️⃣ Clean Up & Maintenance**

If pods are **Evicted / Unknown**:

```bash
kubectl get pods -n default | grep -E 'Evicted|Unknown' | awk '{print $1}' | xargs kubectl delete pod -n default --force --grace-period=0
```

To check resources:

```bash
kubectl top nodes
kubectl top pods -A
```

---

### ✅ **Final Notes**

| Component        | Verified Working                   |
| ---------------- | ---------------------------------- |
| Metrics Server   | ✅ Deployment healthy               |
| Kubelet API      | ✅ Accessible on port 10250         |
| Network / TLS    | ✅ `--kubelet-insecure-tls` enabled |
| RBAC Permissions | ✅ Bound via ClusterRoleBinding     |
| Metrics API      | ✅ `kubectl top` functional         |

