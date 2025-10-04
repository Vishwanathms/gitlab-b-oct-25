

## **Scenario:**

You are a DevOps Engineer for **Acme Corp**. You need to configure sensitive API keys for a deployment job in a GitLab project.

* The key must be secret (not visible in logs),
* Only available for protected branches/tags,
* And you want to compare how to set it at the project vs. group level.

---

# **Lab Manual: Managing Variables and Secrets in GitLab CI/CD**

---

## **Part 1: Setup**

**1.1 Prerequisites**

* Access to a running GitLab instance (self-hosted or gitlab.com)
* Maintainer or Owner permissions on a group and a project

---

## **Part 2: Project-Level Variables**

### **2.1 Add a Project Variable**

1. **Go to your project:**

   * Example: `http://localhost:8080/root/acme-app`

2. **Settings → CI/CD → Variables:**

   * Left sidebar → `Settings` → `CI/CD` → Expand the **Variables** section.

3. **Add Variable:**

   * Click **Add variable**.

   * **Key:** `API_KEY`

   * **Value:** `acme-project-api-key-123`

   * **Type:** Variable

   * **Protected:** ✔️ (Only available for protected branches/tags)

   * **Masked:** ✔️ (Will not show in job logs)

   * Click **Add variable**

   > **Note:** Protected variables are only passed to pipelines running on protected branches/tags. Masked variables cannot be displayed in logs.

### **2.2 Test in `.gitlab-ci.yml`**

1. In your project root, create/edit `.gitlab-ci.yml`:

   ```yaml
   stages:
     - deploy

   deploy-job:
     stage: deploy
     script:
       - echo "Deploying to production"
       - echo "The API Key is $API_KEY"
   ```

2. **Commit and push** to a **protected branch** (like `main`).

3. **Check the pipeline logs:**

   * You should see the line `The API Key is [MASKED]`.

---

## **Part 3: Group-Level Variables**

### **3.1 Add a Group Variable**

1. **Go to your group:**

   * Example: `http://localhost:8080/groups/acme`

2. **Settings → CI/CD → Variables:**

   * Left sidebar → `Settings` → `CI/CD` → Variables.

3. **Add Variable:**

   * **Key:** `GROUP_SECRET`
   * **Value:** `acme-group-level-secret-xyz`
   * **Protected:** ✔️
   * **Masked:** ✔️
   * Click **Add variable**

### **3.2 Test Group Variable in the Project**

1. Edit your `.gitlab-ci.yml` to also echo the group variable:

   ```yaml
   stages:
     - deploy

   deploy-job:
     stage: deploy
     script:
       - echo "Deploying to production"
       - echo "The API Key is $API_KEY"
       - echo "The Group Secret is $GROUP_SECRET"
   ```

2. **Commit and push** to a **protected branch**.

3. **Check the pipeline logs:**

   * The group variable should also appear as `[MASKED]`.

---

## **Part 4: Testing Variable Scope and Masking**

1. **Try pushing to a non-protected branch**

   * The protected variables will NOT be available.

2. **Remove Masked Option:**

   * Edit a variable and uncheck “Masked”.
   * Run the pipeline.
   * Now the variable value will be shown in the job logs.

---

## **Part 5: Clean-up**

* Remove any test variables to avoid exposing secrets.
* Reset variables as needed.

---

## **Summary Table**

| Variable Level | Where Set       | Example Key    | Available To              | Masked | Protected |
| -------------- | --------------- | -------------- | ------------------------- | ------ | --------- |
| Project        | Project → CI/CD | `API_KEY`      | That project only         | Yes/No | Yes/No    |
| Group          | Group → CI/CD   | `GROUP_SECRET` | All projects in the group | Yes/No | Yes/No    |

---

# **Key Takeaways**

* **Project-level variables** are for a single project.
* **Group-level variables** apply to all projects in the group.
* **Protected variables** only show up for protected branches/tags.
* **Masked variables** never show up in logs (great for secrets).

---

**Want this as a Word doc or need a screenshot checklist? Let me know!**
