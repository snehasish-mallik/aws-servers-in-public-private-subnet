# AWS ALB + Auto Scaling Group + Private/Public Subnets

## **Overview**
This Terraform setup creates a highly available architecture in AWS with the following components:

- **VPC** with private and public subnets across two availability zones.
- **Internet Gateway (IGW)** to allow internet access for the ALB.
- **NAT Gateway** to allow private instances to access the internet.
- **Application Load Balancer (ALB)** in public subnets, forwarding traffic to private EC2 instances.
- **Auto Scaling Group (ASG)** in private subnets to manage multiple EC2 instances.
- **Security Groups** to control inbound/outbound traffic.
- **EC2 Instances** with dynamic user data that displays instance details.

## **Architecture Diagram**

```plaintext
                                      Internet
                                          |
                                          |
                              +-----------V------------+
                              | Application Load Balancer |
                              |       (Public Subnet)      |
                              +-----------+------------+
                                          |
                          ---------------------------------
                          |                               |
                 Private Subnet 1                   Private Subnet 2
                     +-------+                          +-------+
                     | EC2-1 |                          | EC2-2 |
                     +-------+                          +-------+
                          |                               |
                      Auto Scaling Group (ASG)
                          |
                  VPC with NAT Gateway (for outbound traffic)
                          |
                      Internet Gateway (IGW)
```

## **Terraform Setup**

### **1. Prerequisites**
- Install Terraform
- Configure AWS CLI with credentials (`aws configure`)
- Ensure a key pair (`darth-vader`) exists in AWS

### **2. Clone Repository**
```sh
git clone <repository-url>
cd terraform-aws-alb-asg
```

### **3. Define Variables**
Create a `terraform.tfvars` file:
```hcl
aws_region = "us-east-1"
ami        = "ami-0c02fb55956c7d316"
key_pair   = "darth-vader"
```

### **4. Initialize Terraform**
```sh
terraform init
```

### **5. Plan and Apply**
```sh
terraform plan
terraform apply -auto-approve
```

## **Resources Created**

### **VPC and Subnets**
- **VPC** with CIDR `10.0.0.0/16`
- **2 Public Subnets** (for ALB)
- **2 Private Subnets** (for ASG)

### **Networking Components**
- **Internet Gateway (IGW)** for ALB
- **NAT Gateway** for private EC2 instances

### **Load Balancer & Auto Scaling Group**
- **Application Load Balancer (ALB)**
- **Target Group (TG)** forwarding requests to private EC2s
- **Auto Scaling Group (ASG)** with a launch template

### **Security Groups**
- **ALB SG**: Allows inbound HTTP traffic (port 80) from the internet
- **EC2 SG**: Allows traffic only from ALB

### **EC2 Instances (Auto Scaling Group)**
Each EC2 instance will:
- Install HTTP server (`httpd`)
- Display its **instance ID** and **availability zone** in `index.html`
- Auto-start the HTTP server on reboot

## **Testing & Accessing the Application**
1. Find the **ALB DNS Name**:
   ```sh
   terraform output alb_dns_name
   ```
2. Open the ALB URL in a browser:
   ```
   http://<alb-dns-name>
   ```
3. Refresh the page to see different EC2 instances responding.

## **Destroy Infrastructure**
```sh
terraform destroy -auto-approve
```

## **Future Enhancements**
- Add HTTPS with an ACM certificate.
- Implement auto-scaling policies based on CPU utilization.
- Store logs in an S3 bucket.

---
🚀 **Now your AWS ALB + Auto Scaling Group setup is ready to deploy!** 🚀

