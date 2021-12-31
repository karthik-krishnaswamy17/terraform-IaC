provider "aws" {
  region = "ap-south-1"
}

variable "vpc_cidr_block" {}
variable "subnet-1_cidr_block" {}
variable "app-name" {}
variable "env-type" {}
variable "my-ip" {}
variable "instance-type"{}
variable "avail-zone"{}

# VPC creation
resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    
    tags = {
      "Name" = "${var.app-name}-vpc"
      "Env"= "${var.env-type}"
    }
}

# Subnet creation to VPC
resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet-1_cidr_block
    

tags = {
      "Name" = "${var.app-name}-subnet-1"
      "Env"= "${var.env-type}"
    }
  
}

# Internet Gateway creation
resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id

  tags = {
      "Name" = "${var.app-name}-igw"
      "Env"= "${var.env-type}"
    }
}

# Route table creation and mapping to igw
resource "aws_route_table" "myapp-rt" {
    vpc_id = aws_vpc.myapp-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
      "Name" = "${var.app-name}-rt"
      "Env"= "${var.env-type}"
    }

}

# Map Route table to created subnet-1
resource "aws_route_table_association" "assoc-subnet"{
    subnet_id = aws_subnet.myapp-subnet-1.id
    route_table_id = aws_route_table.myapp-rt.id

}

#Security group creation with inbound and outboun rules

resource "aws_security_group" "aws-sg" {
  name="${var.app-name}-sg"
  vpc_id = aws_vpc.myapp-vpc.id
  
  //in-bound rules
    ingress {
        from_port = 22
        to_port = 22
        protocol = "TCP"
        cidr_blocks = var.my-ip
        description = "ssh"
       
    
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
  //outbound rules
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }
     tags = {
      "Name" = "${var.app-name}-sg"
      "Env"= "${var.env-type}"
    }
    
}
#Automate ssh key pair generation
resource "aws_key_pair" "ssh-key-pair" {
  key_name="myapp01-ssh-key-new-pair"
  public_key = "${file("/home/vagrant/.ssh/id_rsa.pub")}"
}

# Fetch latest ubuntu image
data "aws_ami" "latest-ubuntu-image"{
  most_recent = true
  owners = ["099720109477"]
  filter{
    name="architecture"
    values=["x86_64"]
  }
  filter{
    name="name"
    values=["ubuntu/images/hvm-ssd/ubuntu-focal-20*"]
  }
filter {
 name="virtualization-type" 
 values = ["hvm"]
}

}




# Creation of EC2 instance.

resource "aws_instance" "myapp01-server" {
  ami=data.aws_ami.latest-ubuntu-image.id
  instance_type = var.instance-type
  associate_public_ip_address = true
  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_security_group.aws-sg.id]
  availability_zone = var.avail-zone
  key_name = aws_key_pair.ssh-key-pair.id
  user_data = "${file("install.sh")}"
  tags = {
      "Name" = "${var.app-name}-ubuntu-ec2"
      "Env"= "${var.env-type}"
    }
    

  }

# To get instance details
data "aws_instance" "ec2-details"{
 instance_id = aws_instance.myapp01-server.id
}

# Print public ip after creation
output "aws_instance_details" {
  value = data.aws_instance.ec2-details.public_ip
  }

output "user_data_details"{
  value = aws_instance.myapp01-server.user_data
}