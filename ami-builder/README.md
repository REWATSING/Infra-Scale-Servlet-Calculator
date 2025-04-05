# 🚀 Packer AMI Builder – Tomcat + Maven + Java + AWS CLI

![Packer](https://img.shields.io/badge/packer-v1.9.4-blue?logo=packer&style=flat-square)
![Build Status](https://img.shields.io/badge/build-passing-brightgreen?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-yellow.svg?style=flat-square)

This repository contains Packer configuration and provisioning scripts for building a **golden Amazon Machine Image (AMI)** preconfigured with:

- **OpenJDK** (Java configured as `JAVA_HOME`)
- **Apache Tomcat**
- **Apache Maven**
- **AWS CLI**
- **Server-level configurations**
- **Permission and directory structure modifications**
- **IAM Role & Instance Profile setup** (for secure access during the Packer build process)

This AMI is ideal for Java-based application deployments, CI/CD pipelines, or autoscaling environments.

---

## 📁 Directory Structure & Files

| File / Directory                | Description |
|--------------------------------|-------------|
| `Tomcat_Maven_GoldenAMI.pkr.hcl` | Main Packer template file defining source AMI, builders, provisioners, and output config |
| `scripts/setup.sh`              | Shell provisioning script for installing and configuring software and system settings |
| `iam/packer-role.tf` *(optional)* | Terraform script to create the IAM role and instance profile for Packer (optional add-on) |

---

## 🧰 Features

- ✅ Java installation with `JAVA_HOME` export
- ✅ Apache Maven setup
- ✅ Apache Tomcat configuration
- ✅ AWS CLI installation
- ✅ Directory permission & system tuning for CI/CD
- ✅ IAM role + instance profile creation (optional with Terraform)
- ✅ Clean & repeatable image creation workflow

---

## 🚀 Build Process

### 🔧 Step 1: Validate the Packer Configuration

Ensure your Packer configuration is correct:

```bash
packer validate Tomcat_Maven_GoldenAMI.pkr.hcl
 
### 🔧 Step 1: Build the Packer Configuration

```bash
packer build Tomcat_Maven_GoldenAMI.pkr.hcl
