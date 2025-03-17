provider "aws" {
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::${var.account_no}:role/${var.assume_role_name}"
  }

}

terraform {
  backend "s3" {

  }
}

//vpc

resource "aws_vpc" "dv_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name : var.vpc_name
  }
}

data "aws_availability_zones" "azs" {

}

//public subnet
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.dv_vpc.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name : var.public_subnet_1_name
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.dv_vpc.id
  cidr_block              = var.public_subnet_2_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.azs.names[1]
  tags = {
    Name : var.public_subnet_2_name
  }

}

//private subnet
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.dv_vpc.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = data.aws_availability_zones.azs.names[0]
  tags = {
    Name : var.private_subnet_1_name
  }

}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.dv_vpc.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = data.aws_availability_zones.azs.names[1]
  tags = {
    Name : var.public_subnet_2_name
  }

}


//IG
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.dv_vpc.id

}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.dv_vpc.id

}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id

}

resource "aws_route_table_association" "public_1" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnet_1.id

}

resource "aws_route_table_association" "public_2" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnet_2.id

}


# NAT Gateway for Private Subnets
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_1.id
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.dv_vpc.id
}

resource "aws_route" "private_nat_access" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}