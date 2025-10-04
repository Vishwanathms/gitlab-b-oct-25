
## 🧪 Hands-On Lab: GitLab – Issues, Milestones & Boards

### 🧰 Prerequisites:

* A GitLab **group/project already created** (e.g., `demo-group/sample-project`)
* At least one **user with Developer or Maintainer access**
* Access to GitLab via browser

---

## 🎯 Lab Objectives:

1. Create one or more **Issues**
2. Create a **Milestone** and assign issues to it
3. Create a **Board** with custom **Stages (Columns)**

---

## ✅ Step-by-Step Instructions

### 🔹 Step 1: Create Issues

1. Navigate to your project → `sample-project`
2. In the left sidebar, click on **Issues** → `List`
3. Click **New issue**
4. Fill in:

   * **Title**: `Add login page`
   * **Description**: `Create a login page with username and password fields`
   * **Assignee**: (optional)
   * **Labels**: e.g., `frontend`, `UI`
5. Click **Create issue**

📝 Repeat to create 2–3 more issues:

* `Design database schema`
* `Set up CI pipeline`
* `Implement logout feature`

---

### 🔹 Step 2: Create a Milestone and Assign Issues

1. Go to **Issues** → `Milestones`
2. Click **New milestone**
3. Fill in:

   * **Title**: `v1.0 Release`
   * **Description**: `First stable release`
   * **Start date / Due date**: (optional)
4. Click **Create milestone**

**Assign Issues to Milestone**:

* Go to `Issues` → `List`
* Click on an issue → Edit
* Under **Milestone**, select `v1.0 Release`
* Save changes

📝 Repeat for all issues to assign them to the milestone.

---

### 🔹 Step 3: Set Up a Board with Stages

1. Go to **Issues** → `Board`

2. Click **Create board**

   * Use the default name or name it `Development Workflow`

3. By default, you’ll see:

   * **Open** and **Closed** columns

4. To add custom stages:

   * Click **Add list**
   * Select **Label** and create new labels as needed:

     * `To Do`
     * `In Progress`
     * `Code Review`
     * `Done`
   * After creating the labels, use them to add **columns** in the board.

Now the board looks like this:

| Column      | Backed by Label |
| ----------- | --------------- |
| To Do       | To Do           |
| In Progress | In Progress     |
| Code Review | Code Review     |
| Done        | Done            |

---

### 🔹 Step 4: Move Issues Across the Board

* Go to **Issues** → `Board`
* Drag issues from one column to another (e.g., from `To Do` → `In Progress`)
* The issue label updates accordingly

---

## 🧼 Cleanup (Optional)

* Delete dummy issues
* Reset or archive the milestone
* Clear test labels

---

## 📌 Notes for Trainer or Self-Practice:

* Demonstrate how labels drive board columns
* Showcase how milestone progress is auto-calculated
* Optionally enable Issue Weights for estimation practice
* Ask learners to map real tasks to stages

