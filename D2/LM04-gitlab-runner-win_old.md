Absolutely! Here’s a **step-by-step guide** for **setting up a GitLab Runner for GitLab running as Docker** on **Windows Docker Desktop**.

---

## **Scenario**

* You have GitLab CE/EE running in Docker on Windows via Docker Desktop.
* You want to add a GitLab Runner (could be Shell, Docker, or Docker-in-Docker executor).

---

# **Step-by-Step: Registering a GitLab Runner (Docker on Windows)**

---

## **1. Prepare GitLab Server Info**

* Make sure your GitLab instance is accessible from your Windows system, e.g., [http://localhost](http://localhost).
* Log in as an admin/maintainer to get the **registration token**:

  * **Go to:** `GitLab → Project → Settings → CI/CD → Runners section → Expand "Set up a specific Runner manually"`
  * Copy the **URL** (e.g., `http://localhost/`) and the **Registration Token**.

---

## **2. Install GitLab Runner**

### **Option 1: Use Docker (Recommended & Portable)**

1. **Open PowerShell or CMD**.

2. **Pull GitLab Runner image:**

   ```bash
   docker pull gitlab/gitlab-runner:latest
   ```

3. **Create a directory for Runner config (optional but good for persistence):**

   ```bash
   mkdir C:\gitlab-runner
   ```

4. **Run GitLab Runner container:**

   ```bash
   docker run -d --name gitlab-runner --restart always ^
     -v C:\gitlab-runner:/etc/gitlab-runner ^
     -v //var/run/docker.sock:/var/run/docker.sock ^
     gitlab/gitlab-runner:latest
   ```

   > Note: Replace `C:\gitlab-runner` with your preferred local folder.

---

## **3. Register the Runner**

1. **Run the registration command:**

   ```bash
   docker run --rm -it -v C:\gitlab-runner:/etc/gitlab-runner gitlab/gitlab-runner register
   ```

2. **Follow the prompts:**

   * **Enter the GitLab URL:**
     `http://localhost/`
   * **Enter the Registration Token:**
     *(Paste the token you copied)*
   * **Enter a description for the runner:**
     E.g., `windows-docker-runner`
   * **Enter tags for the runner (comma-separated):**
     E.g., `docker,windows`
   * **Enter the executor:**

     * For most use-cases: `docker`
     * For simple local script running: `shell`
   * **If Docker executor:**

     * **Enter default Docker image:**
       E.g., `alpine:latest` or `ubuntu:latest`
     * *(You can change this later in config)*

---

## ** Single command **

```
docker run --rm -t ^
  -v /srv/gitlab-runner/config:/etc/gitlab-runner ^
  gitlab/gitlab-runner:latest register ^
  --non-interactive ^
  --url "http://host.docker.internal:8080" ^ ## The hostname should be gitlab container ip 
  --registration-token "YOUR_REGISTRATION_TOKEN" ^
  --executor "docker" ^
  --description "docker-runner" ^
  --docker-image "alpine:latest"
```

## **4. Verify Runner Registration**

* Go to **GitLab → Project → Settings → CI/CD → Runners**.
* You should see your new runner listed as **online**.

---

## **5. Use the Runner in Your `.gitlab-ci.yml`**

Example `.gitlab-ci.yml` for a Docker runner:

```yaml
stages:
  - test

job1:
  stage: test
  script:
    - echo "GitLab Runner setup on Windows Docker Desktop!"
```

---

## **Summary Table**

| Step                   | Command/Action                                             |
| ---------------------- | ---------------------------------------------------------- |
| Pull runner image      | `docker pull gitlab/gitlab-runner:latest`                  |
| Start runner container | `docker run -d --name gitlab-runner ...`                   |
| Register runner        | `docker run --rm -it -v ... gitlab/gitlab-runner register` |
| Verify                 | Check in GitLab CI/CD Settings → Runners                   |

---

## **Troubleshooting Tips**

* If you get errors like "Runner not connecting", make sure Docker can reach your GitLab container (especially if using custom networks or ports).
* For **Docker-in-Docker** (DinD), you might need special configs (let me know if you want this setup).

---

**Let me know if you need a Shell executor, Docker-in-Docker details, or a complete `.gitlab-ci.yml` example!**
