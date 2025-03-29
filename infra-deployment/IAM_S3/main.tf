#### IAM-S3 Module

# Create S3 bucket
resource "aws_s3_bucket" "app_bucket" {
  bucket = "calculator-bucket-271271271271"
  tags = {
    Name = "CalculatorBucket"
  }
}

# Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "app_bucket_block" {
  bucket                  = aws_s3_bucket.app_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM Role for EC2
resource "aws_iam_role" "ec2_role" {
  name = "EC2-S3-Access-Role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach S3 read-only policy
resource "aws_iam_policy_attachment" "s3_readonly_attach" {
  name       = "s3-readonly-attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2-S3-InstanceProfile"
  role = aws_iam_role.ec2_role.name
}
