# AWS Infrastructure Setup with Terraform

## Overview
This Terraform setup provisions an AWS infrastructure with:
- **VPC** (public & private subnets)
- **Internet & NAT Gateways**
- **Security Groups** (ALB & EC2)
- **Application Load Balancer (ALB)**
- **Auto Scaling Group (ASG) & Launch Template**
- **IAM Role Assumption** for secure resource access

## Prerequisites
- Terraform & AWS CLI installed
- IAM permissions to create resources

## Setup
### Configure Environment
Terraform variables are stored in environment-specific `tfvars` files (`dev`, `test`, `prod`). Backend state is managed via `backend.env.conf` for S3.

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
```sh
terraform destroy -var-file=env/dev.tfvars -auto-approve
```

## Notes
- Modify `tfvars` for different environments.
- Ensure AWS CLI authentication (`aws configure`).
- IAM role must have necessary permissions.

