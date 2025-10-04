
## **1. How to Create "Previous Job" Condition in GitLab CI/CD**

If you want a job to **run only after a previous job** (and depending on its result), you can use:

### **A. `needs` Keyword (Explicit Dependency Order)**

```yaml
job1:
  stage: build
  script: echo "Build step"

job2:
  stage: test
  script: echo "Test step"
  needs: [job1]   # job2 will wait for job1 (can be in same or previous stage)
```

* `needs` is useful for cross-stage or non-linear dependencies.

---

### **B. `when:` and `allow_failure:` (Control Run Condition and Status Handling)**

* `when:` controls **when** the job runs (`on_success`, `on_failure`, `always`, `manual`, etc.)
* `allow_failure: true` makes a job not block the pipeline if it fails.

#### **Example: Only Run If Previous Succeeded (default)**

```yaml
job1:
  script: exit 1   # Fails

job2:
  script: echo "I run only if job1 succeeds"
```

* By default, `job2` **does NOT run** if `job1` fails.

---

## **2. How to Ignore Previous Job Status ("Run Anyway")**

If you want to **run a job regardless of previous job’s success/failure**, use `when: always`.

```yaml
job1:
  script: exit 1   # Fails

job2:
  script: echo "I always run"
  when: always
```

* `job2` runs **even if `job1` fails**.

---

## **3. How to Ignore Previous Job Failure (Don't Fail Pipeline If Job Fails)**

If you want to **let a job fail but not fail the pipeline**, use `allow_failure: true`:

```yaml
test_job:
  script: exit 1   # Fails
  allow_failure: true

deploy_job:
  script: echo "Deploying..."
```

* Pipeline will **continue** even if `test_job` fails.

---

## **4. Summary Table**

| What You Want To Do                    | What To Use                     | Example Keyword/Code         |
| -------------------------------------- | ------------------------------- | ---------------------------- |
| Run only if previous job succeeds      | (Default) or `when: on_success` | `when: on_success` (default) |
| Run regardless of previous job status  | `when: always`                  | `when: always`               |
| Allow job failure without failing pipe | `allow_failure: true`           | `allow_failure: true`        |
| Run only if previous job fails         | `when: on_failure`              | `when: on_failure`           |

---

## **Practical Example**

```yaml
stages:
  - build
  - test
  - notify

build:
  stage: build
  script: exit 1   # simulate failure

test:
  stage: test
  script: echo "I only run if build succeeds"

notify:
  stage: notify
  script: echo "I always run (notification step)"
  when: always
```

* `test` will be **skipped** because `build` failed.
* `notify` **always runs**, even if previous jobs failed.

