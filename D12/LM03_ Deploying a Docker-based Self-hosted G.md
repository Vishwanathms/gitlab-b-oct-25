# Lab Manual: Deploying a Docker-based Self-hosted GitHub Actions Runner (Option 1)

This lab manual provides a **comprehensive, step-by-step guide** to set up a self-hosted GitHub Actions runner inside a Docker container. This ensures job isolation and repeatable CI/CD environments. Suitable for both individual and organization repos.

## **Pre-requisites**

- GitHub repository (or org) admin access.
- Docker installed on your host (Linux or Windows).
- Ability to create a Personal Access Token (PAT) with required scopes ([`repo`, `workflow`, `admin:org`] if needed).
- Basic knowledge of Bash and Docker CLI.


## **Step 1: Create a Personal Access Token (PAT)**

1. Go to **GitHub** → **Settings** → **Developer Settings** → **Personal access tokens** (classic).
2. Click **Generate new token** and select the following scopes:
    - `repo` (for repository-level runner)
    - `workflow`
    - `admin:org` (if setting up at organization level)
3. Save and copy the token securely—**you’ll need it for runner registration**.

## **Step 2: Prepare GitHub Repo/Org for Self-hosted Runner**

1. **Navigate to your repository or organization** in GitHub.
2. Go to **Settings** → **Actions** → **Runners**.
3. Click **New self-hosted runner** and select your OS (`Linux x64`).
4. Collect the following info from the instructions page:
    - Repository URL (e.g., `https://github.com/<org>/<repo>`)
    - Example `config.sh` command with a temporary runner registration token.

**Note:** The registration token shown is single-use and expires quickly. You’ll use an automation-friendly approach with your PAT in a moment.

## **Step 3: Create the Dockerfile for Runner Container**

Create a directory (e.g., `github-runner-docker`) and in it, create `Dockerfile`:

```Dockerfile
FROM ubuntu:22.04

# Install required dependencies
RUN apt-get update && \
    apt-get install -y curl jq git sudo unzip libicu70 && \
    apt-get clean

# Create 'runner' user
RUN useradd -m runner && \
    mkdir -p /runner && \
    chown runner:runner /runner

WORKDIR /runner

USER runner

# Download and extract the GitHub Actions runner
RUN curl -o actions-runner.tar.gz -L https://github.com/actions/runner/releases/download/v2.312.0/actions-runner-linux-x64-2.312.0.tar.gz && \
    tar xzf actions-runner.tar.gz && \
    rm actions-runner.tar.gz

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
```


## **Step 4: Create the Runner Entrypoint Script**

In the same directory, create `entrypoint.sh`:

```bash
#!/bin/bash
set -e

./config.sh --unattended \
  --url https://github.com/<your-org-or-user>/<repo> \
  --token ${RUNNER_TOKEN} \
  --labels docker-runner \
  --name $(hostname)

cleanup() {
  echo "Removing runner..."
  ./config.sh remove --unattended --token ${RUNNER_TOKEN}
}
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh
```

- Replace `<your-org-or-user>/<repo>` with your actual GitHub org/user and repository.

Make the script **executable**:

```bash
chmod +x entrypoint.sh
```


## **Step 5: Build and Run Your Dockerized Runner**

### **a. Build the Docker Image**

From your `github-runner-docker` directory:

```bash
docker build -t my-github-runner .
```


### **b. Obtain a Fresh Runner Token**

- Go to your repo's **Settings → Actions → Runners → New self-hosted runner** to generate a new registration token or use the GitHub REST API to programmatically get one with your PAT if automating.


### **c. Run the Docker Container**

```bash
docker run -d --restart always \
  -e RUNNER_TOKEN=<your-runner-token> \
  --name github-docker-runner \
  my-github-runner
```

- Replace `<your-runner-token>` with the latest registration token from GitHub.

**Notes:**

- **The runner registers itself on startup.** If you stop/remove the container, unregister it from GitHub (handled via `cleanup()` on signal).
- You can mount volumes or customize the image further if persistent caching or extra tools are needed.


## **Step 6: Verify the Runner**

- Check under **GitHub repo/org → Settings → Actions → Runners**—the new runner should appear **online**.
- Trigger a workflow using the label `docker-runner` (added in `--labels`) to use this runner.

Example workflow job section:

```yaml
jobs:
  build:
    runs-on: [docker-runner]
    steps:
      - uses: actions/checkout@v3
      - run: echo "Hello from Dockerized Self-hosted Runner!"
```


## **Troubleshooting \& Best Practices**

- **Keep image updated**: Rebuild regularly for security patches.
- **Logs**: Use `docker logs github-docker-runner` for debugging runner/container issues.
- **Tokens expire**: Long-lived runners need refreshed registration tokens. Consider scripting automatic token retrieval if automating at scale.
- **Parallel runners**: Use unique container names and host directories for multiple runners on one host.
- **Cleanup**: Stopping the Docker container triggers runner deregistration.


## **Customization Ideas**

- Add your own build/test dependencies to the Dockerfile.
- Mount host directories or cache volumes as needed.
- Parameterize repo/org URL and labels using Docker environment variables for reusability.

With this setup, you now have a robust, isolated, and reproducible GitHub Actions runner inside Docker—ideal for custom build environments, secured workloads, and flexible CI/CD orchestration.

