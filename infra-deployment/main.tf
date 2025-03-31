terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-unique123"    # Replace with your bucket name
    key            = "terraform-project/terraform.tfstate" # Path to the state file
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table" # DynamoDB table for state locking
    encrypt        = true
  }
}

module "vpc" {
  source          = "./vpc"
  bastion_host_id = module.ec2.bastion_host_id
}

module "security_groups" {
  source     = "./security_groups"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.subnet_ids
}

module "alb" {
  source                   = "./alb"
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.subnet_ids
  alb_sg_id                = module.security_groups.security_group_ids[0]
  private_subnet_ids       = module.vpc.subnet_ids.private
  blue_launch_template_id  = module.ec2.blue_launch_template_id
  green_launch_template_id = module.ec2.green_launch_template_id
  acm_certificate_arn      = module.SSL.certificate_arn
}

module "SSL" {
  source       = "./SSL"
  alb_dns_name = module.alb.alb_dns_name # Pass ALB DNS name
  alb_zone_id  = module.alb.alb_zone_id  # Pass ALB Zone ID

}


module "ec2" {
  source                = "./ec2"
  vpc_id                = module.vpc.vpc_id
  bastion_sg_id         = module.security_groups.security_group_ids[1]
  private_sg_id         = module.security_groups.security_group_ids[2]
  private_subnet_ids    = module.vpc.subnet_ids.private
  public_subnet_id      = module.vpc.subnet_ids.public[0]
  instance_profile_name = module.IAM_S3.instance_profile_name
}

module "IAM_S3" {
  source = "./IAM_S3"
}

