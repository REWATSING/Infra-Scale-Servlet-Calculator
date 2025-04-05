# ⚙️ Infra-Scale-Servlet-Calculator

A **fully automated Infrastructure-as-Code DevOps project** deploying a **scalable Java Servlet application** using **Packer**, **Terraform**, and **GitHub Actions** — featuring **blue-green deployment**, **custom AMI creation**, **Tomcat server setup**, and end-to-end **AWS service integration** with real-time monitoring and alerting.

![GitHub last commit](https://img.shields.io/github/last-commit/REWATSING/Infra-Scale-Servlet-Calculator)
![GitHub repo size](https://img.shields.io/github/repo-size/REWATSING/Infra-Scale-Servlet-Calculator)
![GitHub language](https://img.shields.io/github/languages/top/REWATSING/Infra-Scale-Servlet-Calculator)
![GitHub workflow status](https://img.shields.io/github/actions/workflow/status/REWATSING/Infra-Scale-Servlet-Calculator/major-deploy.yml?label=Major%20Deploy)
![GitHub workflow status](https://img.shields.io/github/actions/workflow/status/REWATSING/Infra-Scale-Servlet-Calculator/minor-deploy.yml?label=Minor%20Deploy)

---

## 🚀 Project Overview

This project provisions and manages a **highly available and scalable** Java Servlet application using a full suite of AWS resources — all defined as code and fully automated with CI/CD workflows.

---

## 🔧 Key Features

- 🛠️ **AMI Creation** with Packer (Tomcat + WAR pre-installed)
- ☁️ **Infrastructure** via Terraform (VPC, Subnets, ALB, ASG, EC2, Route53, etc.)
- 🔁 **Blue/Green Deployment** using Launch Templates and ASGs
- 🚀 **CI/CD Pipelines** via GitHub Actions for both major & minor deployments
- 🛰️ **Route53 + ACM SSL** for secure custom domain routing
- 📦 **S3-integrated WAR** delivery during lightweight updates
- 🔐 **GitHub Secrets** used for secure pipeline operations
- 📊 **CloudWatch Metrics + Logs** for monitoring
- 🔔 **SNS Topic + Email Alerts** for EC2, ASG, and ALB issues

---

## ✅ How It Works

### 🔄 Major Update – Full Infra + WAR Deployment

**Branch:** `major-update`  
Rebuilds AMI → Creates full infrastructure → Blue-Green deployment

**Flow:**
1. GitHub Actions triggers Packer to build a fresh AMI with Tomcat and the WAR app.
2. Terraform uses this AMI to launch new Auto Scaling Groups (green).
3. ALB Target Groups are switched to point to green ASG.
4. The old (blue) ASG is terminated.

---

### ♻️ Minor Update – WAR-Only Update via S3

**Branch:** `minor-update`  
Dynamic WAR update via user data script → Zero-downtime deployment

**Flow:**
1. GitHub Actions builds WAR and uploads to S3.
2. Terraform triggers new EC2 launch with existing AMI.
3. EC2 instances use `user_data` to pull WAR from S3 and deploy on Tomcat.
4. ALB performs health checks and switches traffic to new target group.
5. Previous (blue) instances are terminated safely.

---

## 📣 SNS Alerts & Notifications

To ensure real-time observability, this project provisions **CloudWatch Alarms** and an **SNS Topic** for critical alerts:

### 🔔 Alerts Include:
- 🛑 ASG Unhealthy Instance thresholds
- 🌐 ALB 5xx response spikes
- 🧠 High CPU/memory usage
- ❗ Deployment rollbacks

### 🔧 SNS Setup via Terraform:
- Creates an SNS Topic
- Subscribes your email (via `terraform.tfvars`)
- CloudWatch Alarms are attached to critical AWS services
- Email alerts are sent immediately upon breach

> 📩 Confirm the subscription via email when Terraform runs!

---