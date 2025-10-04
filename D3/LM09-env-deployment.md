
## **Hands-On Lab: Review Apps & Auto-Deploy to Staging in GitLab CI/CD**

---

### **1. Pipeline Overview**

* When a **feature branch** or **merge request** is created, a **review app** is deployed.
* When code is merged to `main`, it’s **auto-deployed to staging**.
* You get environment tracking in GitLab UI.

---

### **2. Example `.gitlab-ci.yml`**

```yaml
stages:
  - build
  - review
  - staging

build-job:
  stage: build
  script:
    - echo "Building the app..."

# Review App for every feature branch / MR
review-app:
  stage: review
  environment:
    name: review/$CI_COMMIT_REF_NAME
    on_stop: stop-review-app
    url: https://$CI_COMMIT_REF_SLUG.review.example.com
  script:
    - echo "Deploying review app for $CI_COMMIT_REF_NAME"
  rules:
    # Run only for merge requests and branches other than main
    - if: '$CI_MERGE_REQUEST_ID'
      when: always
    - if: '$CI_COMMIT_BRANCH && $CI_COMMIT_BRANCH != "main"'
      when: always

stop-review-app:
  stage: review
  environment:
    name: review/$CI_COMMIT_REF_NAME
    action: stop
  script:
    - echo "Stopping review app for $CI_COMMIT_REF_NAME"
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
      when: manual

# Auto-deploy to Staging on main branch
deploy-staging:
  stage: staging
  environment:
    name: staging
    url: https://staging.example.com
  script:
    - echo "Deploying to STAGING environment"
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
      when: on_success
```

---

### **3. Step-by-Step Instructions**

#### **A. Configure Your GitLab Project**

1. **Go to your project** in GitLab.
2. Click **Settings → CI/CD → Expand “Environments”** to see the environment list.

#### **B. Set up Review App**

* The `review-app` job will create a new environment named `review/<branch-name>` for every MR or feature branch.
* The URL is dynamically set (update the domain if needed for your infra).

#### **C. Set up Staging Deployment**

* The `deploy-staging` job deploys automatically to staging whenever `main` is updated.

#### **D. See in Action**

1. **Create a new feature branch** and push changes.
2. **Create a merge request** – a **review app** is automatically deployed.
3. **Merge to `main`** – pipeline deploys automatically to **staging**.
4. View deployment status and environments in GitLab’s **Environments** dashboard.

#### **E. (Optional) Stop Review App**

* In the MR pipeline UI, run the manual `stop-review-app` job to remove the review environment.

---

### **4. Key Concepts**

* **Dynamic Environments**: `${CI_COMMIT_REF_NAME}` ensures every branch/MR gets its own environment.
* **`on_stop`**: Tells GitLab which job stops the environment.
* **`rules`**: Controls when jobs run (e.g., for feature branches, not `main`).
* **Environment URLs**: Make it easy to preview every branch (requires appropriate DNS/routing in your infra).

---

### **5. Tips**

* You can replace the `echo` lines with your actual deployment scripts/commands.
* If using Docker or Kubernetes, swap in your deployment logic.
* Document the workflow for your team in your project’s README.

