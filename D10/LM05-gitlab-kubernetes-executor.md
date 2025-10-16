# **Lab Manual: GitLab Runner with Kubernetes Executor (Private GitLab)**

**Objective:** Configure GitLab CI/CD to run jobs inside Kubernetes pods using a VM-installed GitLab Runner or an in-cluster runner.

**Prerequisites:**

1. Private GitLab instance (URL and project access).
2. Kubernetes cluster (any cloud or on-prem).
3. VM with GitLab Runner installed OR ability to install Helm inside Kubernetes.
4. `kubectl` configured to access your cluster.
5. Basic Linux CLI knowledge.

---

## **Step 1: Create Kubernetes Namespace**

```bash
kubectl create namespace gitlab
```

> All runner-related pods and secrets will live here.

---

## **Step 2: Create Service Account and Permissions**

```bash
kubectl create serviceaccount gitlab-runner -n gitlab
kubectl create clusterrolebinding gitlab-runner \
  --clusterrole=cluster-admin \
  --serviceaccount=gitlab:gitlab-runner
```

* This gives the runner full control over the namespace (required for pod creation).

---

## **Step 3: Get Kubernetes Token**

### **Option A: Kubernetes 1.24+**

```bash
kubectl create token gitlab-runner -n gitlab
```

* Copy the output; this is your `bearer_token` for GitLab Runner registration.

### **Option B: Older Kubernetes**

```bash
kubectl get secret $(kubectl get serviceaccount gitlab-runner -n gitlab -o jsonpath="{.secrets[0].name}") -n gitlab -o go-template="{{.data.token | base64decode}}"
```

* If it fails (empty list), ensure secrets exist:

```bash
kubectl get serviceaccount gitlab-runner -n gitlab -o yaml
```

* Create manually if needed:

```bash
kubectl create secret generic gitlab-runner-token --from-literal=token="dummy" -n gitlab
kubectl patch serviceaccount gitlab-runner -p '{"secrets":[{"name":"gitlab-runner-token"}]}' -n gitlab
```

---

## **Step 4: Handle Self-Signed Certificates**

**Problem:** TLS errors like:

```
tls: failed to verify certificate: x509: certificate signed by unknown authority
```

### **Option 1: Use `insecure` flag (quick)**

* Edit `/etc/gitlab-runner/config.toml`:

```toml
[runners.kubernetes]
host = "https://<K8S_API_SERVER>:6443"
namespace = "gitlab"
bearer_token = "<TOKEN>"
image = "alpine:latest"
insecure = true
```

### **Option 2: Use CA certificate (recommended)**

```bash
mkdir -p ~/gitlab-runner
kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 --decode > ~/gitlab-runner/ca.crt
```

* Update `config.toml`:

```toml
ca_file = "/home/<user>/gitlab-runner/ca.crt"
```

* Restart the runner:

```bash
sudo gitlab-runner restart
```

---

## **Step 5: Register GitLab Runner (VM-installed)**

```bash
sudo gitlab-runner register
```

Prompts:

| Prompt           | Example                         |
| ---------------- | ------------------------------- |
| GitLab URL       | `https://<PRIVATE_GITLAB>`      |
| Token            | `<PROJECT_REGISTRATION_TOKEN>`  |
| Description      | `k8s-runner`                    |
| Tags             | `k8s`                           |
| Executor         | `kubernetes`                    |
| Kubernetes host  | `https://<K8S_API_SERVER>:6443` |
| Kubernetes token | `<SERVICE_ACCOUNT_TOKEN>`       |
| Namespace        | `gitlab`                        |
| Default Image    | `alpine:latest`                 |

> If the runner skips Kubernetes prompts, manually edit `/etc/gitlab-runner/config.toml` as in Step 4.

---

## **Step 6: Test Runner with `.gitlab-ci.yml`**

```yaml
stages:
  - test

test_job:
  stage: test
  tags:
    - k8s
  script:
    - echo "Hello from Kubernetes Executor!"
    - uname -a
```

* Push to GitLab.
* Verify pod creation in Kubernetes:

```bash
kubectl get pods -n gitlab
```

---

## **Step 7: Troubleshooting Common Errors**

| Error                                          | Cause                                | Fix                                                                  |
| ---------------------------------------------- | ------------------------------------ | -------------------------------------------------------------------- |
| `tls: failed to verify certificate`            | Self-signed Kubernetes certificate   | Use `insecure = true` or provide CA in `ca_file`                     |
| `panic: runtime error: invalid memory address` | Misconfigured runner / missing token | Check `config.toml`, ensure `host`, `token`, `namespace` are correct |
| `Error executing template`                     | Service account has no secret        | Use `kubectl create token` (K8s 1.24+) or manually create secret     |
| Job never starts / no pods                     | Runner cannot authenticate           | Check token, namespace, and RBAC permissions                         |

---

## **Step 8 (Optional): Install Runner Inside Kubernetes (Stable Approach)**

```bash
helm repo add gitlab https://charts.gitlab.io
helm repo update
kubectl create namespace gitlab-runner

helm install gitlab-runner gitlab/gitlab-runner \
  --namespace gitlab-runner \
  --set gitlabUrl="https://<PRIVATE_GITLAB>" \
  --set runnerRegistrationToken="<PROJECT_REGISTRATION_TOKEN>" \
  --set rbac.create=true \
  --set runners.tags=k8s \
  --set runners.image="alpine:latest"
```

* Pros: no TLS issues, more stable, no VM dependency.

---

✅ **Lab Complete:**

* You now have a GitLab Runner with Kubernetes executor, tested for **self-signed certs, token issues, nil pointer panics, and VM vs in-cluster setups**.

