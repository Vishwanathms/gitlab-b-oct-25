

## **All Possible `when:` Values in GitLab CI/CD**

| `when:` Value | Description / Behavior                                                                         |
| ------------- | ---------------------------------------------------------------------------------------------- |
| `on_success`  | (Default) Run this job only if all previous jobs succeeded.                                    |
| `on_failure`  | Run this job only if at least one previous job failed.                                         |
| `always`      | Run this job **regardless** of previous job results (success or failure).                      |
| `manual`      | Job is **triggered manually** by a user from the UI (requires a button click).                 |
| `delayed`     | Job is triggered **after a delay** (must also set `start_in:` with a time, e.g., `5 minutes`). |
| `never`       | Job **never runs** (used for conditional pipeline composition, rarely needed).                 |

---

### **Example Usage**

```yaml
job_success:
  script: echo "Runs if previous succeed"
  when: on_success      # Optional, this is the default

job_failure:
  script: echo "Runs if previous fail"
  when: on_failure

job_always:
  script: echo "Runs regardless"
  when: always

job_manual:
  script: echo "Runs only when user clicks"
  when: manual

job_delayed:
  script: echo "Runs after delay"
  when: delayed
  start_in: 5 minutes   # required for 'delayed'
```

---

### **Quick Reference Table**

| `when:` Value | Typical Use Case                                              |
| ------------- | ------------------------------------------------------------- |
| `on_success`  | Deploy/test if build was OK                                   |
| `on_failure`  | Send notification/report if something failed                  |
| `always`      | Cleanup, notify, or audit tasks that must run in any scenario |
| `manual`      | Human-approval, deploy-to-production, or optional steps       |
| `delayed`     | Staged deployment, waiting period before production rollout   |
| `never`       | Exclude jobs in certain pipeline conditions (advanced use)    |

---

**Tip:**
You can combine `when:` with `rules:` for advanced conditional job execution!

---

Let me know if you want real-world YAML samples for any scenario!
