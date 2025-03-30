# Packer Configuration
## Use ECDSA key for ssh into aws ami ; keep in mind 

This directory contains the Packer configuration files for building AMIs.

Packer use ##ECDSA key in AWS for SSH : Keep that in

## Files
- `Tomcat_Maven_GoldenAMI.pkr.hcl`: The main Packer configuration file.
- `scripts/setup.sh`: A sample provisioning script for installing basic software.

## Usage
1. Validate the Packer configuration:
   ```
   packer validate Tomcat_Maven_GoldenAMI.pkr.hcl
   ```

2. Build the AMI:
   ```
   packer build Tomcat_Maven_GoldenAMI.pkr.hcl
   ```

Ensure that your AWS credentials and private key are properly configured before running Packer.
