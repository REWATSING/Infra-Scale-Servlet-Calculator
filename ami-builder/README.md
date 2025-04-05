# Packer AMI Builder – Tomcat + Maven + Java Setup

This directory contains Packer configuration files used to automate the creation of a custom Amazon Machine Image (AMI). The resulting AMI includes Java (configured as `JAVA_HOME`), Apache Tomcat, Maven, AWS CLI, and all necessary system-level configurations for secure and scalable Java application deployments.

Additionally, this setup includes IAM role and instance profile creation code required by Packer for secure EC2 access during the build process.

---

## 📁 Files

- **Tomcat_Maven_GoldenAMI.pkr.hcl**  
  The main Packer configuration file that defines the source AMI, build steps, and provisioning flow.

- **scripts/setup.sh**  
  A provisioning shell script responsible for installing and configuring:
  - Java
  - Apache Maven
  - AWS CLI
  - Tomcat server
  - Directory permission and ownership changes
  - Environment variables and server-level configurations

---

## 🧰 Features

- OpenJDK installation with `JAVA_HOME` set
- Apache Maven setup
- Apache Tomcat installation and configuration
- AWS CLI installation
- Directory permission modifications for build/deploy pipelines
- Custom server configuration setups
- IAM role and instance profile provisioning code (used by Packer to build AMIs securely)

---

## 🚀 Usage

### 1. Validate the Packer Configuration

Before starting the AMI build, validate the configuration:

```bash
packer validate Tomcat_Maven_GoldenAMI.pkr.hcl
