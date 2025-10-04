## 🧪 **Hands-On: Create a Job to Build & Push Docker Image to GitLab Registry**

---

### ✅ **Step 1: Sample App Setup**

1. Add a simple `Dockerfile` in your project root:

```dockerfile
# Sample Dockerfile (Java/Spring Boot example)
FROM openjdk:17
COPY target/demo-app.jar app.jar
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

---

### ✅ **Step 2: Create `.gitlab-ci.yml`**

```yaml
stages:
  - build

variables:
  DOCKER_HOST: tcp://docker:2375/
  DOCKER_TLS_CERTDIR: ""

build_and_push:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - echo "Logging into GitLab Registry..."
    - docker login -u "$CI_REGISTRY_USER" -p "$CI_REGISTRY_PASSWORD" $CI_REGISTRY
    - echo "Building Docker image..."
    - docker build -t "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA" .
    - echo "Pushing image to registry..."
    - docker push "$CI_REGISTRY_IMAGE:$CI_COMMIT_SHORT_SHA"
```

---

### ✅ **Step 3: Enable GitLab Container Registry**

In your project on GitLab:

* Go to **Settings > General > Visibility, project features, permissions**
* Enable ✅ **Container Registry**

---

### ✅ **Step 4: Add CI/CD Variables (If self-managed)**

Go to: **Settings > CI/CD > Variables**

| Key                    | Value                             | Type     |
| ---------------------- | --------------------------------- | -------- |
| `CI_REGISTRY_USER`     | your GitLab username              | Variable |
| `CI_REGISTRY_PASSWORD` | personal access token or password | Variable |

> These values will be used by the runner to log in to the registry.

---

### ✅ **Step 5: Commit & Push**

```bash
git add .gitlab-ci.yml Dockerfile
git commit -m "Add CI pipeline to build and push Docker image"
git push origin main
```

---

### ✅ **Step 6: Observe Pipeline Execution**

* Go to **CI/CD > Pipelines**
* Check the job log for:

  * ✅ Docker login success
  * ✅ Docker build success
  * ✅ Docker push success

---

### ✅ **Step 7: Verify Image in GitLab Registry**

* Navigate to **Packages & Registries > Container Registry** in your GitLab project
* Your image should appear there tagged as `$CI_COMMIT_SHORT_SHA`

---

### ✅ **(Optional) Pull the Image Locally**

```bash
docker login registry.gitlab.com
docker pull registry.gitlab.com/<group>/<project>:<commit-sha>
```

---

## ✅ Summary

| Step                     | Outcome                          |
| ------------------------ | -------------------------------- |
| `.gitlab-ci.yml` created | Defines build & push job         |
| GitLab runner (Docker)   | Executes job with DinD           |
| Registry enabled         | Stores images                    |
| CI variables added       | Secure login to registry         |
| Job pushed               | Image appears in GitLab Registry |

