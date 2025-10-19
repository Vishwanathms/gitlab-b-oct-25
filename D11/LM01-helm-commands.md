## 🧪 **Helm Lab Manual — Python + Redis Deployment**

### **1️⃣ Prerequisites**

Ensure:

* Helm and kubectl are installed.
* Your Kubernetes context points to the correct cluster.
* Namespace exists:

```bash
kubectl create ns 10-vish
```

---

### **2️⃣ Helm Chart Linting**

Validate your Helm chart before installation:

```bash
helm lint py-app1/
```

✅ **Expected:**
`[INFO] Chart.yaml: icon is recommended`
If you get an error like `nil pointer evaluating interface`,
→ Add missing keys (`ingress`, `httpRoute`, etc.) to `values.yaml`.

---

### **3️⃣ Installation**

Install the chart (Helm auto-generates a release name):

```bash
helm install python-redis-chart --generate-name -n 10-vish
```

✅ **Expected Output:**

```
NAME: python-redis-chart-1689
LAST DEPLOYED: ...
NAMESPACE: 10-vish
STATUS: deployed
REVISION: 1
```

Troubleshooting:

* If you see `Error: INSTALLATION FAILED`, check `_helpers.tpl` for missing helper definitions like:

  ```yaml
  {{- define "py-app1.fullname" -}}
  {{ .Release.Name }}-{{ .Chart.Name }}
  {{- end -}}
  ```

---

### **4️⃣ List Releases**

```bash
helm list -n 10-vish
```

✅ **Example Output:**

```
NAME                        NAMESPACE  REVISION  STATUS
python-redis-chart-1689     10-vish    1         deployed
```

---

### **5️⃣ Watch the Deployment Rollout**

Monitor rollout of your Deployment:

```bash
kubectl rollout status deployment/vish-pa-deploy -n 10-vish
```

Watch pods in real time:

```bash
kubectl get pods -n 10-vish -w
```

Check logs:

```bash
kubectl logs -l app=vish-python-app -n 10-vish -f
```

---

### **6️⃣ Upgrade the Release**

To apply new configuration or chart updates:

```bash
helm upgrade python-redis-chart-1689 py-app1/ -f values.yaml -n 10-vish
```

💡 Use this to preview the difference before upgrade (optional plugin):

```bash
helm plugin install https://github.com/databus23/helm-diff
helm diff upgrade python-redis-chart-1689 py-app1/ -f values.yaml -n 10-vish
```

---

### **7️⃣ Verify Upgrade**

```bash
helm status python-redis-chart-1689 -n 10-vish
kubectl get pods -n 10-vish
```

✅ **Expected:**
Old pods terminate → new pods start with new image/tag or config.

---

### **8️⃣ Rollback to Previous Version**

View release history:

```bash
helm history python-redis-chart-1689 -n 10-vish
```

Rollback to a specific revision:

```bash
helm rollback python-redis-chart-1689 1 -n 10-vish
```

Or rollback to the last successful version:

```bash
helm rollback python-redis-chart-1689 -n 10-vish
```

Watch rollout again:

```bash
kubectl rollout status deployment/vish-pa-deploy -n 10-vish
```

---

### **9️⃣ Troubleshooting Quick Reference**

| **Issue**                                     | **Probable Cause**                                        | **Fix**                                                                                                       |
| --------------------------------------------- | --------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| `nil pointer evaluating interface {}.enabled` | Missing key like `.Values.ingress` or `.Values.httpRoute` | Add the section in `values.yaml` or use safe check: `{{- if and .Values.ingress (.Values.ingress.enabled) }}` |
| `did not find expected key`                   | YAML indentation issue                                    | Check spaces in Deployment and NOTES templates                                                                |
| `no template "fullname"`                      | Missing helper in `_helpers.tpl`                          | Add `define "chartname.fullname"` block                                                                       |
| Pods stuck in `ImagePullBackOff`              | Invalid image repo or tag                                 | Verify `image.repository` and `image.tag`                                                                     |
| Pods stuck in `CrashLoopBackOff`              | App error                                                 | Check logs: `kubectl logs <pod> -n 10-vish`                                                                   |
| Upgrade fails with “already exists”           | Resource name conflict                                    | Delete failed release: `helm uninstall <release> -n 10-vish` and reinstall                                    |

---

### **10️⃣ Uninstall**

```bash
helm uninstall python-redis-chart-1689 -n 10-vish
```

Confirm removal:

```bash
helm list -n 10-vish
kubectl get all -n 10-vish
```

