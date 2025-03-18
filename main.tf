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
  tags = {
    Name : "IG Route Table"
  }

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
  tags = {
    Name : "NAT Route Table"
  }
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



# Security Groups
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "alb_sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "ec2_sg"
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ALB
resource "aws_lb" "alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.dv_vpc.id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# Launch Template for Auto Scaling Group
resource "aws_launch_template" "private_lt" {
  name_prefix            = "private-ec2-lt"
  image_id               = "ami-01816d07b1128cd2d"
  instance_type          = "t2.micro"
  key_name               = var.key_pair
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
              echo "<h1>Private EC2 - Instance ID: $INSTANCE_ID</h1>" > /var/www/html/index.html
              EOF
  )
}

# Auto Scaling Group
resource "aws_autoscaling_group" "private_asg" {
  vpc_zone_identifier = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  desired_capacity    = 2
  min_size            = 2
  max_size            = 3

  launch_template {
    id      = aws_launch_template.private_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.tg.arn]
}

# Public EC2 Instance
resource "aws_instance" "public_ec2" {
  ami             = "ami-01816d07b1128cd2d"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_subnet_1.id
  key_name        = var.key_pair
  security_groups = [aws_security_group.alb_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Public EC2</h1>" > /var/www/html/index.html
              EOF
}