
## 🐋 Step-by-Step: Install Docker on Ubuntu

### 1️⃣ Update your system

```bash
sudo apt update
sudo apt upgrade -y
```

---

### 2️⃣ Uninstall old Docker versions (if any)

```bash
sudo apt remove docker docker-engine docker.io containerd runc -y
```

```
# 1️⃣ Remove old key if it exists
sudo rm -f /etc/apt/keyrings/docker.gpg

# 2️⃣ Recreate keyring directory
sudo install -m 0755 -d /etc/apt/keyrings

# 3️⃣ Download Docker’s official GPG key (correct format)
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 4️⃣ Give read permissions
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 5️⃣ Re-add the Docker repository (important!)
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 6️⃣ Update package index
sudo apt update
```

---

### 6️⃣ Update and install Docker

```bash
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

---

### 7️⃣ Enable and start Docker

```bash
sudo systemctl enable docker
sudo systemctl start docker
```

---

### 8️⃣ Verify installation

```bash
sudo docker --version
sudo docker run hello-world
```

You should see:

```
Hello from Docker!
```

---

### 9️⃣ Run Docker without sudo

```bash
sudo usermod -aG docker $USER
newgrp docker
```

Then test:

```bash
docker ps
```

---

### ✅ Summary

| Step | Action                              |
| ---- | ----------------------------------- |
| 1    | Update system                       |
| 2    | Install dependencies                |
| 3    | Add Docker repo & GPG key           |
| 4    | Install Docker & plugins            |
| 5    | Start and verify Docker             |
| 6    | (Optional) Add user to docker group |

