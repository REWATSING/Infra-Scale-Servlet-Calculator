source "amazon-ebs" "EBS-is-source" {
  region                 = "us-east-1"
  source_ami             = "ami-005fc0f236362e99f" # Base AMI (Ubuntu)
  instance_type          = "t2.micro"
  ssh_username           = "ubuntu" # Default for Ubuntu AMI
  ssh_keypair_name       = "ecdsakeypair" # Name of your key pair in AWS
  ssh_private_key_file   = "../../ecdsakeypair.pem" # Path to your private key file
  ami_name               = "tomcat-mvn-golden-ami-{{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.EBS-is-source"]

  provisioner "shell" {
    script = "./scripts/setup.sh" # Path to the external script
  }
}