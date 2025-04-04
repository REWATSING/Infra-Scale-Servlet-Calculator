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
  iam_instance_profile   = "PackerInstanceProfile"   # Use IAM profile already created by Terraform
}


build {
  sources = ["source.amazon-ebs.EBS-is-source"]

  provisioner "shell" {
    script = "./scripts/setup.sh" # Path to the external script
  }
}