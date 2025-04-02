packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "EBS-is-source" {
  region                 = "us-east-1"
  source_ami             = "ami-0f9de6e2d2f067fca" # Base AMI (Ubuntu)
  instance_type          = "t2.micro"
  ssh_username           = "ubuntu" # Default for Ubuntu AMI
  ssh_keypair_name       = "packerkey" # Name of your key pair in AWS
  ssh_private_key_file   = "~/packerkey.pem" # Path to your private key file
  ami_name               = "tomcat-mvn-golden-ami-{{timestamp}}"
  iam_instance_profile   = "packer-instance-profile-{{timestamp}}"

  # IAM Role & Instance Profile (Created Dynamically)
  temporary_iam_instance_profile_policy_document = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::calculator-bucket-271271271271",
          "arn:aws:s3:::calculator-bucket-271271271271/*"
        ]
      }
    ]
  }
  EOF
}

build {
  sources = ["source.amazon-ebs.EBS-is-source"]

  provisioner "shell" {
    script = "./scripts/setup.sh" # Path to the external script
  }
}
