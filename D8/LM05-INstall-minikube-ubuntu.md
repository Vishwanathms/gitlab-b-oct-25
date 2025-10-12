## 🧩 Step 1 — Update your system

```bash
sudo apt update -y && sudo apt upgrade -y
```

---

## 🧩 Step 2 — Install dependencies

Minikube needs some basic packages and a hypervisor (like Docker or KVM).

```bash
sudo apt install -y curl wget apt-transport-https ca-certificates conntrack
```

If you don’t have **Docker**, install it (recommended driver):

```bash
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
```

Then add your user to the Docker group (to run without `sudo`):

```bash
sudo usermod -aG docker $USER
newgrp docker
```

---

## 🧩 Step 3 — Install Minikube binary

Download and install:

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

✅ Verify installation:

```bash
minikube version
```

---

## 🧩 Step 4 — Install kubectl (Kubernetes CLI)

```bash
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
kubectl version --client
```

---

## 🧩 Step 5 — Start Minikube Cluster

Start with Docker as driver:

```bash
minikube start --driver=docker
```

If you want to specify Kubernetes version or memory:

```bash
minikube start --driver=docker --cpus=2 --memory=4096 --kubernetes-version=v1.29.0
```

---

## 🧩 Step 6 — Check Cluster Status

```bash
minikube status
kubectl get nodes
```

You should see something like:

```
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   1m    v1.29.0
```

---

## 🧩 Step 7 — Enable Kubernetes Dashboard (Optional)

```bash
minikube dashboard
```

This will open the Kubernetes dashboard UI in your browser.
If running on a server (without GUI), you can use:

```bash
minikube dashboard --url
```

and then access the URL from your local browser.

---

## 🧩 Step 8 — Stop or Delete Cluster

Stop the cluster:

```bash
minikube stop
```

Delete the cluster:

```bash
minikube delete
```

---

## ✅ Quick Summary

| Command                          | Description      |
| -------------------------------- | ---------------- |
| `minikube start --driver=docker` | Start cluster    |
| `minikube status`                | Check status     |
| `kubectl get pods -A`            | See all pods     |
| `minikube dashboard`             | Access dashboard |
| `minikube stop`                  | Stop cluster     |
| `minikube delete`                | Delete cluster   |

