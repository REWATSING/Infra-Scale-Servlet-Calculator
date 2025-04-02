terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-unique123"    # Replace with your bucket name
    key            = "terraform-packer-iam\terraform.tfstate" # Path to the state file
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table-packer" # DynamoDB table for state locking
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

# IAM Role for Packer
resource "aws_iam_role" "packer" {
  name = "PackerS3AccessRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM Policy to Allow S3 Access
resource "aws_iam_policy" "s3_read" {
  name        = "PackerS3ReadPolicy"
  description = "Allow Packer instances to read from S3"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["s3:GetObject", "s3:ListBucket"]
      Resource = [
        "arn:aws:s3:::calculator-bucket-271271271271",
        "arn:aws:s3:::calculator-bucket-271271271271/*"
      ]
    }]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "s3_attach" {
  role       = aws_iam_role.packer.name
  policy_arn = aws_iam_policy.s3_read.arn
}

# Create Instance Profile
resource "aws_iam_instance_profile" "packer_profile" {
  name = "PackerInstanceProfile"
  role = aws_iam_role.packer.name
}
