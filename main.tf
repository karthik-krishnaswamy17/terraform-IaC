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
resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    
    tags = {
      "Name" = "${var.app-name}-vpc"
      "Env"= "${var.env-type}"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet-1_cidr_block
    

tags = {
      "Name" = "${var.app-name}-subnet-1"
      "Env"= "${var.env-type}"
    }
  
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id

  tags = {
      "Name" = "${var.app-name}-igw"
      "Env"= "${var.env-type}"
    }
}

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
resource "aws_route_table_association" "assoc-subnet"{
    subnet_id = aws_subnet.myapp-subnet-1.id
    route_table_id = aws_route_table.myapp-rt.id

}

resource "aws_security_group" "aws-sg" {
  name="${var.app-name}-sg"
  vpc_id = aws_vpc.myapp-vpc.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "TCP"
        cidr_blocks = var.my-ip
        description = "ssh"
       
    
    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }
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

output "aws_ami_image_details" {
  value = data.aws_ami.latest-ubuntu-image.id
}

resource "aws_instance" "myapp01-server" {
  ami=data.aws_ami.latest-ubuntu-image.id
  instance_type = var.instance-type
  associate_public_ip_address = true
  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_security_group.aws-sg.id]
  availability_zone = var.avail-zone
  key_name = "AWS-AP-Key_Pair"

  tags = {
      "Name" = "${var.app-name}-ubuntu-ec2"
      "Env"= "${var.env-type}"
    }
    

  }