# Ansible Lab Manual: Advanced Scenario (Remaining Sections)

---

## Part 3: Converting to Ansible Playbook with Verification Tasks

### Step 3.1: Basic Playbook Structure
Create `webserver_setup.yml`:

```yaml
---
- name: Web Server Configuration Lab
  hosts: webservers
  become: yes
  gather_facts: yes

  vars:
    app_name: "MyWebApp"
    app_version: "1.0"
    admin_user: "webadmin"

  tasks:
    - name: Display server information
      debug:
        msg: "Configuring {{ inventory_hostname }} running {{ ansible_distribution }} {{ ansible_distribution_version }}"
    # Verification: Debug validates expected values

    - name: Ping all servers
      ping:
    # Verification: Register and show ping status
      register: ping_result

    - name: Verify ping status
      debug:
        var: ping_result
```

### Step 3.2: Adding Variables, OS-Specific Tasks, and Verification
Create tasks for OS-specific package installation and validate with checks:

```yaml
    - name: Update package cache (Ubuntu)
      apt:
        update_cache: yes
      when: ansible_distribution == "Ubuntu"
      register: apt_update_result

    - name: Verify apt update
      debug:
        var: apt_update_result

    - name: Install Apache on Ubuntu
      apt:
        name: apache2
        state: present
      when: ansible_distribution == "Ubuntu"
      register: apache_install_result

    - name: Verify Apache install (Ubuntu)
      command: which apache2
      when: ansible_distribution == "Ubuntu"
      register: apache_bin_result

    - name: Debug Apache path (Ubuntu)
      debug:
        var: apache_bin_result

    - name: Install HTTPD on RHEL
      yum:
        name: httpd
        state: present
      when: ansible_distribution == "RedHat"
      register: httpd_install_result

    - name: Verify HTTPD install (RHEL)
      command: which httpd
      when: ansible_distribution == "RedHat"
      register: httpd_bin_result

    - name: Debug HTTPD path (RHEL)
      debug:
        var: httpd_bin_result
```

### Step 3.3: Loops, Conditionals, and Register
Create users and verify creation, then manage services with confirmation:

```yaml
    - name: Create admin users
      user:
        name: "{{ item.name }}"
        groups: "{{ item.groups }}"
        shell: "/bin/bash"
      loop:
        - { name: "webadmin", groups: "sudo" }
        - { name: "developer", groups: "www-data" }
      register: user_create_results

    - name: Verify users exist
      command: id {{ item.name }}
      loop:
        - { name: "webadmin" }
        - { name: "developer" }
      register: user_id_results

    - name: Show user ID checks
      debug:
        var: user_id_results

    - name: Start Web Service
      service:
        name: "{{ 'apache2' if ansible_distribution == 'Ubuntu' else 'httpd' }}"
        state: started
        enabled: yes
      register: web_service_result

    - name: Check web service status
      shell: "systemctl status {{ 'apache2' if ansible_distribution=='Ubuntu' else 'httpd' }}"
      register: service_status_result

    - name: Debug service status
      debug:
        var: service_status_result.stdout_lines
```

---

## Part 4: Advanced Features, Error Handling, and Best Practices

### Step 4.1: Templates and File Operations with Verification

```yaml
    - name: Deploy custom index page
      template:
        src: index.html.j2
        dest: /var/www/html/index.html
      register: index_deploy_result

    - name: Check index file exists
      stat:
        path: /var/www/html/index.html
      register: index_stat_result

    - name: Debug index file stat
      debug:
        var: index_stat_result.stat.exists

    - name: Display deployed index
      command: cat /var/www/html/index.html
      register: index_cat_result
      changed_when: false

    - name: Debug index file content
      debug:
        var: index_cat_result.stdout
```

### Step 4.2: Error Handling and Debugging Patterns

```yaml
    - name: Try to install fake package
      package:
        name: notarealpackage
        state: present
      ignore_errors: yes
      register: fake_package_result

    - name: Report on fake package result
      debug:
        var: fake_package_result
```

---

## Part 5: Lab Exercises and Verification Tasks

### Exercise 1: Add RAM Check Before Installing Web Server
Create a conditional task using `ansible_memtotal_mb` fact and verify:

```yaml
    - name: Check memory requirement
      debug:
        msg: "Server {{ inventory_hostname }} has {{ ansible_memtotal_mb }}MB RAM"

    - name: Install Apache only if RAM > 2000MB
      apt:
        name: apache2
        state: present
      when:
        - ansible_distribution == "Ubuntu"
        - ansible_memtotal_mb > 2000
```

### Exercise 2: File Check and Creation Logic

```yaml
    - name: Stat test file
      stat:
        path: /tmp/testfile
      register: testfile_stat_result

    - name: Create test file if not exists
      file:
        path: /tmp/testfile
        state: touch
      when: not testfile_stat_result.stat.exists

    - name: Verify test file
      stat:
        path: /tmp/testfile
      register: verify_testfile

    - name: Debug test file stat
      debug:
        var: verify_testfile.stat.exists
```

---

## Summary

This advanced scenario extends the foundational lab manual, providing students with:
- Playbook patterns for all major tasks
- Rich verification after each action using Ansible's modules and Linux commands
- Sample exercises for developing conditional and loop logic
- Confidence checks to track and validate every change

**Download and use this file alongside the main manual for a complete Ansible training experience with iterative verification and deep technical insight.**
