* Assign the **Developer** role to the user in your project.
* (Optionally) Fine-tune branch protection and permissions.

---

## **1. Create a User in GitLab (Self-Managed Instance Only)**

> If using **GitLab.com**, users must self-register or be invited.

**As an admin (self-hosted only):**

* Go to **Admin Area → Overview → Users → New User**
* Fill in username, email, password
* Click **Create user**

---

## **2. Add User to Your Project With Developer Role**

1. **Go to your Project → Project information → Members**
2. **Invite member**
3. **Enter username/email**
4. **Select Role: `Developer`**

   * **Developer can:**

     * Push code to any branch they have access to
     * Run pipelines (manually or by pushing code)
     * Create and manage merge requests
   * **Developer cannot:**

     * Change project settings
     * Modify CI/CD settings or variables
     * Change branch protection rules

---

## **3. (Optional) Tighten Permissions With Protected Branches**

If you want even finer control:

* Go to **Repository → Branches → Protected Branches**
* Protect your main branch so only Maintainers can force-push or merge (but Developers can still push/merge to feature branches)

---

## **4. What Developers Can and Cannot Do**

| Action                        | Developer Role Allowed? |
| ----------------------------- | :---------------------: |
| Push code to repo             |          ✅ Yes          |
| Create and run jobs/pipelines |          ✅ Yes          |
| Change `.gitlab-ci.yml`       |    ✅ Yes (by push/MR)   |
| Edit CI/CD variables/settings |           ❌ No          |
| Edit project/Settings         |           ❌ No          |
| Manage branch protection      |           ❌ No          |

---

### **Summary**

* **Assign user Developer role** in your project.
* They can push and trigger pipelines, but **cannot change CI/CD or project settings**.
* For even more restrictions (e.g., code read-only), use the Reporter role—but then they cannot push or run jobs.

