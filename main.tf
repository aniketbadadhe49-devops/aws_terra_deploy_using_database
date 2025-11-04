#VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
     Name = "tf-vpc"
    }
}


#Subnet
resource "aws_subnet" "main" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.subnet_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "tf-subnet"
  }

}
#internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

#RouteTable
resource "aws_route_table" "rt"{
  vpc_id = aws_vpc.main.id
    route{
      cidr_block = "0.0.0.0/0"
      gateway_id = aws-internet_gateway.gw.id
    }
}

resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.main.id
  rout_table_id = aws_route_table.rt.id
}

# Securatygroup
resource "aws_security_group" "vm_sg" {
  name ="vm_sg"
  description = "Allow SSH and HTTP"
  vpc_id = aws_vpc.main.id

  ingress{
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =["0.0.0.0/0"]
  }

  ingress{
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks =["0.0.0.0/0"]
   } 
  egress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks =["0.0.0.0/0"]
   }  
}
# Generating a new ssh key pair
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

#Generating Aws key pair
resource "aws_key_pair" "deployer_key" {
  key_name ="tf-ec2-key"
  public_key = tls_private_key.key.public_key_openssh
}
# save the key locally
resource "local_file" "private_key" {
  content = tls_private_key.key.private_key_pem
  filename = "${path.module}/tf-ec2-key.pem"
}
# Get letest version of ubuntu Ami
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hmv-ssd/ubuntu-jammy-22.04-amd64-server-*"]

  }

  filter {
   name = "virtulization-type"
   value = ["hvm"]
  }
  owners = ["amazon"]
}

output "ubuntu_ami_id" {
value = data.aws_ami.ubuntu
}

# EC2
resource "aws_instance" "vm" {
  ami        = data_aws_ami.ubuntu.id
  instance_id = var.instance_type
  subnet_id   = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.vm_sg.id]
  key_name = aws_key_pair.deployer_key.key_name

  tags = {
    Name = "ubuntu-server"
  }

}
