
## 🧪 Hands-On Lab: GitLab – Wiki & Snippets

### 🧰 Prerequisites:

* A GitLab project (`sample-project`) created
* You must have **Developer** or higher access to the project

---

## 🎯 Lab Objectives:

1. Create a **Wiki page**
2. Add a **Table of Contents (ToC)** to the Wiki
3. Create a **Snippet** with a shell script

---

## ✅ Step-by-Step Instructions

---

### 🔹 Step 1: Create a Wiki Page

1. Navigate to your project (`sample-project`)
2. In the left sidebar, click **Wiki**
3. Click on **Create your first page**
4. Fill in:

   * **Title**: `Project Overview`
   * **Content**:

     ```markdown
     # Project Overview

     Welcome to the sample-project Wiki. This document explains the structure and components.

     ## Features
     - Authentication
     - CI/CD Integration
     - API endpoints

     ## Setup Instructions
     ```
   * You can use markdown formatting (`#`, `##`, `-`, etc.)
5. Click **Create page**

---

### 🔹 Step 2: Add Table of Contents to the Wiki Page

1. Edit the existing Wiki page (`Project Overview`)

2. Add the following line at the top of your content:

   ```markdown
   [[TOC]]
   ```

3. Example full content:

   ```markdown
   [[TOC]]

   # Project Overview

   Welcome to the sample-project Wiki. This document explains the structure and components.

   ## Features
   - Authentication
   - CI/CD Integration
   - API endpoints

   ## Setup Instructions
   - Install dependencies
   - Configure environment
   - Run the server

   ## Troubleshooting
   - Check logs
   - Restart services
   ```

4. Click **Save changes**

✅ You’ll now see a **clickable Table of Contents** generated from the headers.

---

### 🔹 Step 3: Create a Snippet for a Shell Script

1. From the left sidebar → Click **Snippets**
2. Click **New snippet**
3. Fill in:

   * **Title**: `Backup Script`
   * **File name**: `backup.sh`
   * **Visibility**: Private or Internal
   * **Content**:

     ```bash
     #!/bin/bash

     BACKUP_DIR="/var/backups"
     TIMESTAMP=$(date +%F_%T)
     FILENAME="project_backup_$TIMESTAMP.tar.gz"

     tar -czf $BACKUP_DIR/$FILENAME /home/gitlab/project

     echo "Backup created at $BACKUP_DIR/$FILENAME"
     ```
4. Click **Create snippet**

✅ Your shell script snippet is now stored and shareable via URL.

---

## 🧼 Cleanup (Optional)

* Delete test snippets or wiki pages if not needed

---

## 💡 Tips

* Use snippets to share code fragments across the team
* Wiki pages support **markdown**, **code blocks**, and **internal linking**
* You can create multiple wiki pages and link them like a knowledge base
