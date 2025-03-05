# 🚀 Kali Linux Essential Setup & LabSec Installation

## 📌 Overview
This repository contains two scripts for setting up a **Kali Linux** environment with essential tools and configuring the **LabSec** security lab.

### **1️⃣ setup_kali.sh**
- Installs essential packages and tools required for security research.
- Installs and configures **Docker**.
- Ensures required services like **Open VM Tools** and **Docker** are enabled.
- Installs **Metasploit Framework**, **Nmap**, **Tor Browser**, **Snort**, and **wordlists**.

### **2️⃣ setup_labsec.sh**
- Downloads the **LabSec security lab** from Google Drive.
- Extracts the lab files.
- Builds and runs the **LabSec** Docker container.

---

## 🛠️ Prerequisites
Before running the scripts, ensure you have:
- A fresh installation of **Kali Linux** (Rolling Release)
- Internet connection
- **Root (sudo) access**

---

## 📥 Installation & Usage

### **Step 1: Download the Scripts**
```bash
cd ~/Desktop
wget https://raw.githubusercontent.com/lukegcollins/SIT182-Essentials/main/setup_kali.sh
wget https://raw.githubusercontent.com/lukegcollins/SIT182-Essentials/main/setup_labsec.sh
```

### **Step 2: Make Scripts Executable**
```bash
chmod +x setup_kali.sh setup_labsec.sh
```

### **Step 3: Run the Essential Setup Script**
This script installs **all essential security tools**, Docker, and enables required services.
```bash
sudo ./setup_kali.sh
```

### **Step 4: Run the LabSec Setup Script**
This script downloads the **LabSec security lab**, builds the Docker image, and runs it. (Please wait until week 4's workshop to run this)
```bash
sudo ./setup_labsec.sh
```

---

## 📦 Installed Packages & Tools
The `setup_kali.sh` script installs:
- **System Utilities:** `htop`, `curl`, `vim`, `gedit`, `net-tools`
- **Security Tools:** `nmap`, `metasploit-framework`, `snort`, `torbrowser-launcher`
- **Wordlists:** Prepares `rockyou.txt` for use
- **Docker & Dependencies**
- **Open VM Tools** (for virtual environments like VMware & VirtualBox)

The `setup_labsec.sh` script:
- **Downloads LabSec from Google Drive**
- **Extracts lab files**
- **Builds the LabSec Docker image**
- **Runs the Docker container**

---

## 🛠️ Managing Docker (Optional)
### **List Docker Images**
```bash
docker images
```
### **Delete Docker Image**
```bash
docker rmi -f <image_id>
```
### **Stop Running Containers**
```bash
docker ps -a
sudo docker stop <container_id>
```

---

## ⚡ Notes
- If you receive a `Permission denied` error, ensure the script has execution permissions (`chmod +x script.sh`).
- If Docker does not start automatically, run:
  ```bash
  sudo systemctl start docker
  sudo systemctl enable docker
  ```
- If issues occur with Google Drive downloads, manually download the file and extract it into the working directory.

---

## ✅ Conclusion
By running these scripts, your **Kali Linux** setup will be fully prepared with **security tools**, **Docker**, and the **LabSec environment**. 🚀

Enjoy hacking responsibly! 🛡️
