# Scalable AWS Infrastructure Automation with Terraform

## Overview
This Terraform setup provisions an AWS infrastructure to create a highly available, secure, and scalable environment with the following components:
- **VPC** with public and private subnets
- **Internet Gateway & NAT Gateways** for internet access
- **Security Groups** for controlled access
- **Application Load Balancer (ALB)** for distributing traffic
- **Auto Scaling Group (ASG) & Launch Template** for dynamic scaling
- **IAM Role Assumption** for secure resource access

## Architecture Diagram
The following diagram illustrates the infrastructure setup:

![image](https://github.com/user-attachments/assets/9e1d7551-97d7-4215-8aef-46d866f97bba)


## Prerequisites
- Install **Terraform** and **AWS CLI**
- Ensure IAM permissions to create necessary AWS resources

## Setup
### Configure Environment
- Terraform variables are stored in environment-specific `tfvars` files (`dev`, `test`, `prod`) in respective env folder.
- Backend state is managed via `backend.env.conf` for S3 state storage for each env in respective env folder.

### Deployment Steps
1. **Initialize Terraform:**
   ```sh
   terraform init -backend-config=backend.env.conf
   ```
2. **Validate Configuration:**
   ```sh
   terraform validate
   ```
3. **Plan Deployment:**
   ```sh
   terraform plan -var-file=env/dev.tfvars
   ```
4. **Apply Changes:**
   ```sh
   terraform apply -var-file=env/dev.tfvars -auto-approve
   ```

### Destroy Infrastructure
To remove the deployed resources, run:
```sh
terraform destroy -var-file=env/dev.tfvars -auto-approve
```

## Notes
- Modify `tfvars` files to deploy different environments.
- Ensure AWS CLI authentication with `aws configure`.
- IAM role must have necessary permissions for Terraform execution.
- I have also set up Github Actions Pipeline for this. Do check that out. 

