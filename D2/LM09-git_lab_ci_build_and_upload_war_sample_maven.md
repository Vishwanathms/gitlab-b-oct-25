# GitLab CI - Build and Upload WAR (Sample Maven)

## Step-by-Step Lab Manual (Shell Runner Version)

### 1. **Pre-requisites**
- A Linux VM with Ubuntu/Debian/CentOS.
- GitLab installed or access to GitLab instance.
- A GitLab project created (import the `SampleMaven` repo: https://github.com/Vishwanathms/SampleMaven).
- Install the following dependencies on the runner machine:
  ```bash
  sudo apt update -y
  sudo apt install -y openjdk-11-jdk maven git
  ```
- Register a GitLab **Shell runner** on your VM:
  ```bash
  sudo gitlab-runner register
  ```
  - Enter your GitLab instance URL.
  - Provide the registration token from GitLab > Admin Area > Runners.
  - Choose **shell** executor.

---

### 2. **Create the GitLab CI File**
In the root of your project, create `.gitlab-ci.yml`:

```yaml
stages:
  - build
  - test
  - package

build-job:
  stage: build
  script:
    - echo "Building Maven project..."
    - mvn clean compile
  artifacts:
    paths:
      - target/*.class
    expire_in: 1 week

test-job:
  stage: test
  script:
    - echo "Running Maven tests..."
    - mvn test

package-job:
  stage: package
  script:
    - echo "Packaging WAR file..."
    - mvn package
  artifacts:
    paths:
      - target/*.war
    expire_in: 1 week
```

---

### 3. **Pipeline Flow**
1. **Build Stage**
   - Compiles Java source files.
   - Saves `.class` files as artifacts.

2. **Test Stage**
   - Runs unit tests.
   - Ensures project stability before packaging.

3. **Package Stage**
   - Creates `SampleMaven.war` inside `target/`.
   - Uploads `.war` as GitLab artifacts for download.

---

### 4. **Verification Steps**
- Push the `.gitlab-ci.yml` file to your GitLab repo.
- Navigate to **CI/CD > Pipelines**.
- Check each stage execution.
- Download the WAR file from **Job Artifacts**.

---

### 5. **Expected Outcome**
- Successful execution of **build → test → package** stages.
- `target/SampleMaven.war` available as a GitLab artifact.

---

✅ This setup uses a **shell runner**, so all jobs run directly on the VM without Docker overhead.

