#vpc
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${terraform.workspace}-${var.projectname}"
  }

}

# Setup public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.cidr_public_subnet
  availability_zone = var.availability_zone

  tags = {
    Name = "${terraform.workspace}-${var.projectname}-public"
  }

}

# Setup private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.cidr_private_subnet
  availability_zone = var.availability_zone

  tags = {
    Name = "${terraform.workspace}-${var.projectname}-private"
  }
}

# Setup Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${terraform.workspace}-${var.projectname}-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "${terraform.workspace}-${var.projectname}-public-rt"
  }
}

# Public Route Table and Public Subnet Association
resource "aws_route_table_association" "public_rt_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Private Route Table
resource "aws_route_table" "private_subnets" {
  vpc_id = aws_vpc.main.id
  #depends_on = [aws_nat_gateway.nat_gateway]
  tags = {
    Name = "${terraform.workspace}-${var.projectname}-private-rt"
  }
}

# Private Route Table and private Subnet Association
resource "aws_route_table_association" "private_rt_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_subnets.id
}
resource "aws_key_pair" "key" {
  key_name   = var.key_name
  public_key = var.public_key
}
# Ec2 Instances
resource "aws_instance" "main" {
  ami = var.ami_id
  instance_type = var.instance_type
  associate_public_ip_address = true
  subnet_id = aws_subnet.public_subnet.id
  security_groups = [ aws_security_group.main.id ]
  key_name = aws_key_pair.key.key_name
  tags = {
        Name = "${terraform.workspace}-${var.projectname}"
        Os = "ubuntu"
        Env = "${terraform.workspace}"

  }
}

# Security groups
resource "aws_security_group" "main" {
  name        = "tomcat"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id
  
    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "allow http port"
    }
    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "allow ssh port"
    }
    ingress {
      from_port = 8080
      to_port = 8080
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "allow tomact port"
    }
  
    egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

  tags = {
    Name = "${terraform.workspace}-${var.projectname}-sg"
  }
  
}

# resource "aws_security_group" "dynamic_sg" {
#   for_each = var.config
#   name = "${each.key}-sg"
#   description = "The security group for ${each.key}"
#   vpc_id = aws_vpc.main.id

#   dynamic "ingress" {
#     for_each = each.value.ports[*]
#     content {
#       from_port   =  ingress.value.from
#       to_port     =  ingress.value.to
#       protocol    = "tcp"
#       cidr_blocks = ingress.value.from != 1433 ? [ ingress.value.source] : null 
#       ipv6_cidr_blocks = ingress.value.source=="::/0" ? [ingress.value.source] : null
#       security_groups =   ingress.value.from == 1433 ? [ ingress.value.source] : null 
#     }
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = {
#     "Server" = "${each.key}"
#     "Provider" = "Terraform"
#   }
# }