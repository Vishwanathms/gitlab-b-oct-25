## **Step 1: Update your system**

```bash
sudo apt update
sudo apt upgrade -y
```

---

## **Step 2: Add the GitLab Runner repository**

1. Install required dependencies:

```bash
sudo apt install -y curl gnupg
```

2. Add the GitLab official repository and GPG key:

```bash
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
```

---

## **Step 3: Install GitLab Runner**

```bash
sudo apt install gitlab-runner -y
```

---

## **Step 4: Verify the installation**

```bash
gitlab-runner --version
```

You should see something like:

```
Version: 16.x.x
```

---

## **Step 5: Register the Runner**

1. Get the **GitLab registration token** from your GitLab project:

   * Go to your project → Settings → CI/CD → Runners → “Set up a specific Runner”
2. Register the runner:

```bash
sudo gitlab-runner register
```

During registration, you’ll be asked for:

* GitLab instance URL → e.g., `https://gitlab.com/` or your self-hosted URL
* Registration token → from GitLab
* Description → e.g., `ubuntu-runner`
* Tags → optional, e.g., `docker, ubuntu`
* Executor → choose `shell` or `docker` (depending on your use case)

---

## **Step 6: Start and enable GitLab Runner**

```bash
sudo systemctl start gitlab-runner
sudo systemctl enable gitlab-runner
```

Check status:

```bash
sudo systemctl status gitlab-runner
```

---

## ✅ Optional: Use Docker executor

If you want to run builds in Docker containers, install Docker first:

```bash
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
```

Then choose `docker` as the executor during runner registration.

