account_no       = "463470958825"
assume_role_name = "deploy_role"
region           = "us-east-1"

vpc_name              = "dev_vpc"
public_subnet_1_name  = "dev_public_subnet_1"
public_subnet_2_name  = "dev_public_subnet_2"
private_subnet_1_name = "dev_private_subnet_1"
private_subnet_2_name = "dev_private_subnet_2"

vpc_cidr              = "10.0.0.0/16"
public_subnet_1_cidr  = "10.0.1.0/24"
public_subnet_2_cidr  = "10.0.2.0/24"
private_subnet_1_cidr = "10.0.3.0/24"
private_subnet_2_cidr = "10.0.4.0/24"

key_pair = "darth-vader"
ami      = "ami-01816d07b1128cd2d"