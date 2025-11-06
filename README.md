# Practice Assignment on Testing, Linux and Servers


---

## Overview

This repository documents and automates the setup of a **secure, monitored, and well-maintained development environment** for two developers — **Sarah** (Apache server) and **Mike** (Nginx server) — under the supervision of **Rahul**, Senior DevOps Engineer at TechCorp.

The environment setup includes:

1. **System Monitoring** using `htop`, `df`, `du`, and automated metric logging.
2. **User Management & Access Control** with password complexity and expiration policy.
3. **Automated Backup Configuration** for Apache and Nginx web servers.

---

## 🧠 Table of Contents

1. [System Monitoring Setup (Task 1)](#task-1-system-monitoring-setup)
2. [User Management & Access Control (Task 2)](#task-2-user-management-and-access-control)
3. [Backup Configuration for Web Servers (Task 3)](#task-3-backup-configuration-for-web-servers)
4. [Verification & Logs](#verification--logs)
5. [Challenges & Notes](#challenges--notes)
6. [Repository Structure](#repository-structure)

---

## 🧩 **Task 1: System Monitoring Setup**

###  Objective

Monitor CPU, memory, and processes; track disk usage; and log metrics periodically.

### ⚙️ Steps

#### Install tools

```bash
sudo apt update
sudo apt install htop -y 
```
<img width="1902" height="1078" alt="1" src="https://github.com/user-attachments/assets/10c01c58-9d8c-405e-8438-c715d922e308" />



#### Manual Monitoring

* Run `htop` → live process view (CPU/memory load)
  <img width="1902" height="1078" alt="2" src="https://github.com/user-attachments/assets/4fef65b1-45d9-444d-b126-b61249498c53" />

```bash
sudo apt install nmon -y

Once launched, nmon displays various system statistics. You can enable or disable specific views by pressing corresponding keys:

c: CPU utilization
m: Memory and paging statistics
d: Disk statistics
n: Network interface view
t: Top processes
k: Kernel statistics
r: System resource view
h: Help screen (press again to hide)
q: Quit nmon

```
<img width="1850" height="1053" alt="3" src="https://github.com/user-attachments/assets/f8508855-32bf-4c84-afcd-d99e8b6aa524" />
<img width="1850" height="1053" alt="4" src="https://github.com/user-attachments/assets/da7056c4-3151-4115-8f25-b7f6006fd356" />
<img width="1850" height="1053" alt="5" src="https://github.com/user-attachments/assets/144db41c-44c8-4d92-ab24-81df709d1923" />

  
* Use `df -h` → check filesystem usage
 <img width="1850" height="1053" alt="6" src="https://github.com/user-attachments/assets/c48969cb-5c43-4086-8bd6-931329b39f4f" /> 


* Execute Cron daily at 8 
  <img width="1850" height="1053" alt="7" src="https://github.com/user-attachments/assets/59415daa-7283-4945-bf05-ddf8e4d7f036" />
* Use `ps -eo pid,cmd,%cpu,%mem --sort=-%cpu | head` → top CPU-consuming processes 

<img width="1850" height="1053" alt="8" src="https://github.com/user-attachments/assets/611b8405-d72f-4585-b8aa-48167d9a855c" />

  

#### Automated Monitoring Script

```bash
#!/bin/bash
LOGFILE="/var/log/system_monitor.log"
{
  echo "=============================="
  echo "Date: $(date)"
  echo "CPU & Memory Usage:"
  top -bn1 | head -n 10
  echo ""
  echo "Disk Usage:"
  df -h
  echo ""
  echo "Top 5 CPU-consuming Processes:"
  ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
  echo ""
  echo "Top 5 Memory-consuming Processes:"
  ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 6
  echo ""
} >> "$LOGFILE"
```

Make executable:

```bash
sudo chmod +x system_monitor.sh
/.system_monitor.sh
```
<img width="1850" height="1053" alt="9" src="https://github.com/user-attachments/assets/fe2f8f0e-d2c7-4c94-8440-dba4a248a0fc" />




## 👥 **Task 2: User Management and Access Control**

### 🎯 Objective

Create isolated user environments for **Sarah** and **Mike**, enforce password complexity and expiration.

### ⚙️ Steps

#### Create Users

```bash
sudo adduser Sarah --force-badname
sudo adduser Mike --force-badname
```

#### Create Isolated Workspaces

```bash
sudo mkdir -p /home/Sarah/workspace
sudo mkdir -p /home/Mike/workspace
sudo chown -R Sarah:Sarah /home/sarah/workspace
sudo chown -R Mike:Mike /home/mike/workspace
sudo chmod 700 /home/Sarah/workspace
sudo chmod 700 /home/Mike/workspace
#### Password Expiration Policy (30 days)
sudo chage -M 30 -W 5 Sarah
sudo chage -M 30 -W 5 Mike
```
<img width="1850" height="1053" alt="10" src="https://github.com/user-attachments/assets/acff3ce2-1232-4641-9f85-64051063fff4" />
<img width="1850" height="1053" alt="11" src="https://github.com/user-attachments/assets/b9e2476d-63fc-4cb9-89bd-d39165b61225" />




#### Password Complexity Policy

Edit `/etc/security/pwquality.conf`:<img width="1850" height="1053" alt="6" src="https://github.com/user-attachments/assets/c48969cb-5c43-4086-8bd6-931329b39f4f" />


```
minlen = 8
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
maxrepeat = 2
dictcheck = 1
```

Ensure PAM configuration (Ubuntu):
<img width="1850" height="1053" alt="12" src="https://github.com/user-attachments/assets/c2fe96b9-03d5-4d7a-ae8e-a5f0bb0f5242" />


```bash
sudo nano /etc/pam.d/common-password
```
<img width="1850" height="1053" alt="13" src="https://github.com/user-attachments/assets/ab70b302-627c-44e8-84e5-8aab8f91dd07" />

Add or confirm:

```
password requisite pam_pwquality.so retry=3 minlen=8 difok=3
```

Verify settings:

```bash
sudo chage -l Sarah
sudo passwd Sarah  # test weak vs strong password
```
<img width="1850" height="1053" alt="14" src="https://github.com/user-attachments/assets/69b8e2f3-18ee-4e74-bbd3-4d7f8a460134" />

---

## 💾 **Task 3: Backup Configuration for Web Servers**

### 🎯 Objective

Automate weekly compressed backups for Sarah’s Apache server and Mike’s Nginx server every **Tuesday at 12:00 AM**.

### ⚙️ Steps

#### Create Backup Directory

```bash
sudo mkdir -p /backups
sudo chmod 755 /backups
```

#### Apache Backup Script (Sarah)

```bash
#!/bin/bash
# Apache Backup Script for Sarah
# Runs every Tuesday at 00:00 (12:00 AM)
# Saves backups under /backups/apache_backup_YYYY-MM-DD.tar.gz

set -euo pipefail

BACKUP_DIR="/backups"
DATE=$(date +"%F")
OUTFILE="$BACKUP_DIR/apache_backup_${DATE}.tar.gz"
LOGFILE="$BACKUP_DIR/apache_backup_${DATE}.log"

# Detect correct Apache config directory (RHEL uses /etc/httpd, Ubuntu uses /etc/apache2)
if [ -d "/etc/httpd" ]; then
  APACHE_CONF="/etc/httpd"
elif [ -d "/etc/apache2" ]; then
  APACHE_CONF="/etc/apache2"
else
  echo "Apache config directory not found!" >&2
  exit 1
fi

DOC_ROOT="/var/www/html"

# Start logging
{
  echo "=== Apache Backup Started: $(date) ==="
  echo "Configuration Directory: $APACHE_CONF"
  echo "Document Root: $DOC_ROOT"
  echo "Target Archive: $OUTFILE"
  echo

  # Create compressed backup
  tar -czf "$OUTFILE" "$APACHE_CONF" "$DOC_ROOT"
  echo "Backup archive created successfully."
  echo

  # Verify archive integrity
  echo "Verifying backup contents (first 20 entries):"
  tar -tzf "$OUTFILE" | head -n 20
  echo

  echo "=== Apache Backup Completed: $(date) ==="
} >"$LOGFILE" 2>&1

# Keep only the last 8 backups
ls -1tr "$BACKUP_DIR"/apache_backup_*.tar.gz 2>/dev/null | head -n -8 | xargs -r rm --

```

#### Nginx Backup Script (Mike)

File: `/usr/local/bin/nginx_backup.sh`

```bash
#!/bin/bash
# /backups/nginx_backup.sh
# Nginx backup for Mike (config + docroot)
set -euo pipefail

BACKUP_DIR="/backups"
DATE=$(date +"%F")
OUTFILE="$BACKUP_DIR/nginx_backup_${DATE}.tar.gz"
LOGFILE="$BACKUP_DIR/nginx_backup_${DATE}.log"

# detect config path
if [ -d "/etc/nginx" ]; then
  NGINX_CONF="/etc/nginx"
else
  echo "Nginx config directory not found" >&2
  exit 1
fi

DOC_ROOT="/usr/share/nginx/html"

{
  echo "=== Nginx Backup Started: $(date) ==="
  echo "Config: $NGINX_CONF"
  echo "Doc root: $DOC_ROOT"
  echo "Archive: $OUTFILE"
  echo

  tar -czf "$OUTFILE" "$NGINX_CONF" "$DOC_ROOT"
  echo "Archive created: $OUTFILE"
  echo
  echo "Verifying archive contents (first 50 lines):"
  tar -tzf "$OUTFILE" | head -n 50
  echo
  echo "=== Nginx Backup Completed: $(date) ==="
} >"$LOGFILE" 2>&1

# rotate - keep last 8
ls -1tr "$BACKUP_DIR"/nginx_backup_*.tar.gz 2>/dev/null | head -n -8 | xargs -r rm --
```

Make both scripts executable:

```bash
sudo chmod +x /backups/apache_backup.sh
sudo chmod +x /backups/nginx_backup.sh
```

#### Schedule Cron Jobs

```bash
sudo crontab -e
```

Add:

```
0 0 * * 2 /backups//apache_backup.sh
0 0 * * 2 /backups//nginx_backup.sh
```

#### Verify Backups

```bash
ls -lh /backups/
cat /backups/apache_backup_log_$(date +%F).txt | head
cat /backups/nginx_backup_log_$(date +%F).txt | head
```

---

## 🔍 **Verification & Logs**

* `df -h`, `du -sh /var /home` → Disk usage tracking
* `ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head` → Identify heavy processes
* `sudo chage -l sarah` → Verify password expiration
* `sudo cat /backups/*_log_YYYY-MM-DD.txt` → Check backup integrity

---

## ⚠️ **Challenges & Notes**

* `/var/log/` and `/backups/` require root permissions.
* Ensure usernames are lowercase to comply with `NAME_REGEX`.
* Schedule cron as root to avoid `Permission denied`.
* Consider encrypting backups if moved offsite.

---

<img width="1850" height="1053" alt="15" src="https://github.com/user-attachments/assets/d2ee5eef-3773-41b6-97d0-7dca9da549bb" />
<img width="1850" height="1053" alt="16" src="https://github.com/user-attachments/assets/a2dd2cc7-84dd-4adf-88b1-75f3fc7ba380" />
<img width="1850" height="1053" alt="17" src="https://github.com/user-attachments/assets/6ca6d49c-0e28-4b51-9805-2ca78e00fb97" />
<img width="1850" height="1053" alt="18" src="https://github.com/user-attachments/assets/8ec913ee-fc90-4cb7-b6e6-c546108e1c8c" />
<img width="1850" height="1053" alt="19" src="https://github.com/user-attachments/assets/030d40cc-0e6f-43d7-89d7-16ab48de976c" />
<img width="1850" height="1053" alt="20" src="https://github.com/user-attachments/assets/adf3bfd7-eb70-4cf4-9717-f02214feafb1" />


## 📂 **Repository Structure**

```
/linux_commands_assignments/
├── backups/
│   ├── apache_backup.sh
│   └── nginx_backup.sh
└── systemmonitor.sh
└── README.md
```

---

## ✅ **Deliverables for Submission**

* Screenshots of terminal showing successful execution:

  * `htop`, `df`, `du`, `ps` output
  * `chage -l` verification
  * `/backups/` directory and log files
* GitHub Repository URL
* PDF Report (optional) with stepwise documentation and screenshots

---

## 🏁 **Conclusion**

└── README.md
This setup ensures that:

* System health is monitored continuously.
* User access is secure and compliant with password policies.
* Backups run automatically every week and are verified for integrity.

The environment is now **secure, reliable, and production-ready** for Sarah and Mike.

