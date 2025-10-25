# Ansible Lab Manual: From Ad-Hoc Commands to Playbooks
## Lab Scenario: Web Server Configuration and Management

### Scenario Overview
You are a DevOps engineer tasked with configuring and managing multiple web servers for a new application deployment. You need to:
1. Verify connectivity to all servers
2. Install required packages (Apache/Nginx, Git, Python)
3. Create users with specific permissions
4. Configure web server settings based on OS type
5. Deploy application files conditionally

In this lab, you will start with Ansible ad-hoc commands for quick tasks, then convert them into a comprehensive playbook using variables, loops, and conditionals for better automation.

---

## Lab Environment Setup

### Prerequisites
- Ansible installed on control node (version 2.9 or higher)
- 3 target servers (Ubuntu/RHEL-based systems)
- SSH key-based authentication configured
- Sudo privileges on target servers

### Lab Infrastructure
```
Control Node (Ansible): 192.168.1.10
Web Server 1 (Ubuntu): 192.168.1.21
Web Server 2 (RHEL):    192.168.1.22
Web Server 3 (Ubuntu): 192.168.1.23
```

---

## Part 1: Creating Local Inventory File

### Step 1.1: Create the Inventory File
Create a local inventory file named `lab_inventory.ini`:

```ini
# lab_inventory.ini
[webservers]
web1 ansible_host=192.168.1.21 ansible_user=ubuntu
web2 ansible_host=192.168.1.22 ansible_user=rhel
web3 ansible_host=192.168.1.23 ansible_user=ubuntu

[ubuntu_servers]
web1 ansible_host=192.168.1.21 ansible_user=ubuntu
web3 ansible_host=192.168.1.23 ansible_user=ubuntu

[rhel_servers]
web2 ansible_host=192.168.1.22 ansible_user=rhel

[webservers:vars]
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```


* Actual Inventory file 
```ini
# lab_inventory.ini
[webservers]
web1 ansible_host=<respective host ip> ansible_user=<respective usr name>

[webservers:vars]
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_ssh_private_key_file=/home/<username>/key1.pem
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```


### Step 1.2: Test Inventory
```bash
# List all hosts in inventory
ansible-inventory -i lab_inventory.ini --list

# List hosts in specific group
ansible-inventory -i lab_inventory.ini --list webservers
```

---

## Part 2: Ansible Ad-Hoc Commands

### Step 2.1: Connectivity Testing
```bash
# Test connectivity to all web servers
ansible -i lab_inventory.ini webservers -m ping

# Check uptime of all servers
ansible -i lab_inventory.ini webservers -a "uptime"
```

**Expected Output:**
```
web1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
web2 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### Step 2.2: System Information Gathering
```bash
# Check disk space on all servers
ansible -i lab_inventory.ini webservers -a "df -h"

# Check memory usage
ansible -i lab_inventory.ini webservers -a "free -m"

# Get OS information
ansible -i lab_inventory.ini webservers -m setup -a "filter=ansible_distribution*"
```

### Step 2.3: Package Management
```bash
# Update package cache on Ubuntu servers
ansible -i lab_inventory.ini ubuntu_servers -m apt -a "update_cache=yes" --become

# Install Apache on Ubuntu servers
ansible -i lab_inventory.ini ubuntu_servers -m apt -a "name=apache2 state=present" --become

# Install Apache on RHEL servers
ansible -i lab_inventory.ini rhel_servers -m yum -a "name=httpd state=present" --become

# Start and enable web server service on all servers
ansible -i lab_inventory.ini webservers -m service -a "name=apache2 state=started enabled=yes" --become --limit ubuntu_servers
ansible -i lab_inventory.ini webservers -m service -a "name=httpd state=started enabled=yes" --become --limit rhel_servers
```

### Step 2.4: User Management
```bash
# Create a web admin user
ansible -i lab_inventory.ini webservers -m user -a "name=webadmin groups=sudo shell=/bin/bash" --become

# Create application directory
ansible -i lab_inventory.ini webservers -m file -a "path=/opt/webapp state=directory mode=0755 owner=webadmin" --become
```

### Step 2.5: File Operations
```bash
# Copy a sample index.html file
ansible -i lab_inventory.ini webservers -m copy -a "content='<h1>Welcome to My Web Server</h1>' dest=/var/www/html/index.html mode=0644" --become

# Check if the file exists
ansible -i lab_inventory.ini webservers -m stat -a "path=/var/www/html/index.html"
```

---

## Part 3: Converting to Ansible Playbook

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
```

**Run the basic playbook:**
```bash
ansible-playbook -i lab_inventory.ini webserver_setup.yml
```

### Step 3.2: Adding Variables and OS-Specific Tasks

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
    web_packages:
      - git
      - curl
      - vim
    ubuntu_web_service: "apache2"
    rhel_web_service: "httpd"
    
  tasks:
    - name: Display server information
      debug:
        msg: "Configuring {{ inventory_hostname }} running {{ ansible_distribution }} {{ ansible_distribution_version }}"

    - name: Update package cache (Ubuntu)
      apt:
        update_cache: yes
        cache_valid_time: 3600
      when: ansible_distribution == "Ubuntu"

    - name: Install web server on Ubuntu
      apt:
        name: apache2
        state: present
      when: ansible_distribution == "Ubuntu"

    - name: Install web server on RHEL/CentOS
      yum:
        name: httpd
        state: present
      when: ansible_distribution in ["RedHat", "CentOS"]

    - name: Install common packages using loop
      package:
        name: "{{ item }}"
        state: present
      loop: "{{ web_packages }}"

    - name: Start and enable web server service (Ubuntu)
      systemd:
        name: "{{ ubuntu_web_service }}"
        state: started
        enabled: yes
      when: ansible_distribution == "Ubuntu"

    - name: Start and enable web server service (RHEL)
      systemd:
        name: "{{ rhel_web_service }}"
        state: started
        enabled: yes
      when: ansible_distribution in ["RedHat", "CentOS"]
```

### Step 3.3: Advanced Playbook with Loops, Conditionals, and Register

```yaml
---
- name: Advanced Web Server Configuration Lab
  hosts: webservers
  become: yes
  gather_facts: yes
  
  vars:
    app_name: "MyWebApp"
    app_version: "1.0"
    admin_users:
      - name: "webadmin"
        groups: "sudo"
        shell: "/bin/bash"
      - name: "developer"
        groups: "www-data"
        shell: "/bin/bash"
      - name: "monitor"
        groups: "adm"
        shell: "/bin/bash"
    
    web_packages:
      Ubuntu:
        - apache2
        - git
        - python3
        - python3-pip
      RedHat:
        - httpd
        - git
        - python3
        - python3-pip
    
    web_directories:
      - path: "/opt/webapp"
        owner: "webadmin"
        group: "www-data"
        mode: "0755"
      - path: "/opt/webapp/logs"
        owner: "webadmin"
        group: "www-data"
        mode: "0755"
      - path: "/opt/webapp/config"
        owner: "webadmin"
        group: "www-data"
        mode: "0750"
    
  tasks:
    - name: Display server information
      debug:
        msg: |
          Server: {{ inventory_hostname }}
          OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
          Memory: {{ ansible_memtotal_mb }}MB
          CPU: {{ ansible_processor_count }} cores

    - name: Check disk space
      command: df -h /
      register: disk_space_result
      changed_when: false

    - name: Display disk space
      debug:
        msg: "Disk space on {{ inventory_hostname }}: {{ disk_space_result.stdout_lines[1] }}"

    - name: Fail if disk space is less than 1GB
      fail:
        msg: "Insufficient disk space on {{ inventory_hostname }}"
      when: 
        - disk_space_result.stdout is defined
        - "'100%' in disk_space_result.stdout"

    - name: Update package cache (Ubuntu)
      apt:
        update_cache: yes
        cache_valid_time: 3600
      when: ansible_distribution == "Ubuntu"

    - name: Install packages based on OS type
      package:
        name: "{{ item }}"
        state: present
      loop: "{{ web_packages[ansible_distribution] | default([]) }}"
      when: web_packages[ansible_distribution] is defined

    - name: Create application users with loop
      user:
        name: "{{ item.name }}"
        groups: "{{ item.groups }}"
        shell: "{{ item.shell }}"
        state: present
        create_home: yes
      loop: "{{ admin_users }}"

    - name: Create web application directories
      file:
        path: "{{ item.path }}"
        state: directory
        owner: "{{ item.owner }}"
        group: "{{ item.group }}"
        mode: "{{ item.mode }}"
      loop: "{{ web_directories }}"

    - name: Check if web server is running
      systemd:
        name: "{{ 'apache2' if ansible_distribution == 'Ubuntu' else 'httpd' }}"
        state: started
        enabled: yes
      register: web_service_result

    - name: Display web server status
      debug:
        msg: "Web server is {{ 'running' if web_service_result.state == 'started' else 'not running' }}"

    - name: Create custom index.html with variables
      template:
        src: index.html.j2
        dest: /var/www/html/index.html
        owner: root
        group: root
        mode: '0644'
      notify: restart webserver

    - name: Test web server response
      uri:
        url: "http://{{ ansible_default_ipv4.address }}"
        method: GET
        return_content: yes
      register: web_response
      delegate_to: localhost
      become: no

    - name: Display web server response
      debug:
        msg: "Web server response status: {{ web_response.status }}"
      when: web_response.status is defined

  handlers:
    - name: restart webserver
      systemd:
        name: "{{ 'apache2' if ansible_distribution == 'Ubuntu' else 'httpd' }}"
        state: restarted
```

### Step 3.4: Create Template File
Create `templates/index.html.j2`:

```html
<!DOCTYPE html>
<html>
<head>
    <title>{{ app_name }} - {{ app_version }}</title>
</head>
<body>
    <h1>Welcome to {{ app_name }}</h1>
    <h2>Version: {{ app_version }}</h2>
    <p>Server: {{ inventory_hostname }}</p>
    <p>OS: {{ ansible_distribution }} {{ ansible_distribution_version }}</p>
    <p>IP Address: {{ ansible_default_ipv4.address }}</p>
    <p>Deployed on: {{ ansible_date_time.date }} at {{ ansible_date_time.time }}</p>
    
    {% if ansible_distribution == "Ubuntu" %}
    <p>Web Server: Apache2 (Ubuntu)</p>
    {% else %}
    <p>Web Server: Apache HTTP Server (RHEL/CentOS)</p>
    {% endif %}
    
    <h3>Administrators:</h3>
    <ul>
    {% for user in admin_users %}
        <li>{{ user.name }} ({{ user.groups }})</li>
    {% endfor %}
    </ul>
</body>
</html>
```

---

## Part 4: Running and Testing the Playbook

### Step 4.1: Execute the Complete Playbook
```bash
# Run the playbook with verbose output
ansible-playbook -i lab_inventory.ini webserver_setup.yml -v

# Run with specific tags (if defined)
ansible-playbook -i lab_inventory.ini webserver_setup.yml --tags "users,directories"

# Dry run to check what would change
ansible-playbook -i lab_inventory.ini webserver_setup.yml --check

# Run on specific hosts only
ansible-playbook -i lab_inventory.ini webserver_setup.yml --limit ubuntu_servers
```

### Step 4.2: Verification Commands
```bash
# Check if services are running
ansible -i lab_inventory.ini webservers -a "systemctl status apache2" --limit ubuntu_servers
ansible -i lab_inventory.ini webservers -a "systemctl status httpd" --limit rhel_servers

# Verify users were created
ansible -i lab_inventory.ini webservers -a "id webadmin"

# Check directories
ansible -i lab_inventory.ini webservers -a "ls -la /opt/webapp"

# Test web server response
curl http://192.168.1.21
curl http://192.168.1.22
curl http://192.168.1.23
```

---

## Part 5: Advanced Features and Best Practices

### Step 5.1: Using External Variable Files
Create `group_vars/webservers.yml`:

```yaml
---
# Web server configuration variables
app_settings:
  name: "ProductionWebApp"
  version: "2.0"
  environment: "production"
  
security_settings:
  enable_firewall: true
  allowed_ports:
    - 80
    - 443
    - 22

backup_settings:
  enabled: true
  schedule: "0 2 * * *"
  retention_days: 30
```

### Step 5.2: Conditional Tasks with Complex Logic
```yaml
tasks:
  - name: Configure firewall (Ubuntu)
    ufw:
      rule: allow
      port: "{{ item }}"
    loop: "{{ security_settings.allowed_ports }}"
    when: 
      - ansible_distribution == "Ubuntu"
      - security_settings.enable_firewall | bool

  - name: Configure firewall (RHEL)
    firewalld:
      port: "{{ item }}/tcp"
      permanent: true
      state: enabled
      immediate: true
    loop: "{{ security_settings.allowed_ports }}"
    when: 
      - ansible_distribution in ["RedHat", "CentOS"]
      - security_settings.enable_firewall | bool

  - name: Setup log rotation only if backup is enabled
    template:
      src: logrotate.conf.j2
      dest: /etc/logrotate.d/webapp
    when: backup_settings.enabled | bool
```

### Step 5.3: Error Handling and Debugging
```yaml
tasks:
  - name: Attempt to install package with error handling
    package:
      name: "{{ item }}"
      state: present
    loop: "{{ web_packages[ansible_distribution] | default([]) }}"
    register: package_install_result
    failed_when: false
    changed_when: package_install_result.rc == 0

  - name: Report failed package installations
    debug:
      msg: "Failed to install {{ item.item }} on {{ inventory_hostname }}"
    loop: "{{ package_install_result.results }}"
    when: 
      - item.rc is defined
      - item.rc != 0

  - name: Gather service facts
    service_facts:

  - name: Debug available services
    debug:
      msg: "Available services: {{ ansible_facts.services.keys() | list }}"
    when: ansible_facts.services is defined
```

---

## Part 6: Lab Exercises

### Exercise 1: Modify the Playbook
1. Add a new variable for application port (default: 8080)
2. Create a conditional task that only runs on servers with more than 2GB RAM
3. Add a loop to install additional Python packages

### Exercise 2: Create a New Playbook
Create a playbook that:
1. Checks if a specific file exists using `stat` module
2. Registers the result and uses it in a conditional
3. Creates the file only if it doesn't exist

### Exercise 3: Advanced Inventory
1. Add host-specific variables in the inventory file
2. Create a playbook that uses both group and host variables
3. Test variable precedence

---

## Part 7: Troubleshooting Common Issues

### Issue 1: SSH Connection Problems
```bash
# Test SSH connectivity manually
ssh -i ~/.ssh/id_rsa ubuntu@192.168.1.21

# Check SSH configuration
ansible -i lab_inventory.ini webservers -m ping -vvv
```

### Issue 2: Privilege Escalation
```bash
# Test sudo access
ansible -i lab_inventory.ini webservers -a "whoami" --become

# Check sudo configuration
ansible -i lab_inventory.ini webservers -a "sudo -l" -u ubuntu
```

### Issue 3: Variable Undefined Errors
```yaml
# Use default filters
- name: Safe variable usage
  debug:
    msg: "Value is {{ my_var | default('not defined') }}"

# Check if variable is defined
- name: Conditional task
  debug:
    msg: "Variable is defined"
  when: my_var is defined
```

---

## Summary

In this lab, you have learned:

1. **Ad-Hoc Commands**: Quick, one-time operations for immediate tasks
2. **Playbook Structure**: Converting ad-hoc commands into reusable playbooks
3. **Variables**: Using different types of variables for flexibility
4. **Loops**: Iterating over lists and dictionaries efficiently
5. **Conditionals**: Running tasks based on specific conditions
6. **Register Variables**: Capturing and reusing task outputs
7. **Templates**: Dynamic file generation using Jinja2
8. **Error Handling**: Managing failures and debugging issues

### Key Takeaways:
- **Ad-hoc commands** are perfect for quick tasks and testing
- **Playbooks** provide structure, reusability, and advanced features
- **Variables** make playbooks flexible and maintainable
- **Loops and conditionals** enable dynamic and efficient automation
- **Proper error handling** makes playbooks robust and reliable

### Next Steps:
- Explore Ansible roles for better organization
- Learn about Ansible Vault for sensitive data
- Practice with more complex inventory patterns
- Integrate with CI/CD pipelines

---

## Additional Resources

- [Ansible Official Documentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Jinja2 Template Documentation](https://jinja.palletsprojects.com/)
- [YAML Syntax Guide](https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html)