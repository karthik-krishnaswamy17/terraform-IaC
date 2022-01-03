provider "aws" {
  region = "ap-south-1"
}



# VPC creation
resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    
    tags = {
      "Name" = "${var.app-name}-vpc"
      "Env"= "${var.env-type}"
    }
}

module "module-subnet" {
  source = "./modules/subnet"
  subnet-1_cidr_block = var.subnet-1_cidr_block
  app-name=var.app-name
  env-type=var.env-type
  avail-zone=var.avail-zone
  myapp-vpc=aws_vpc.myapp-vpc

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
  subnet_id = module.module-subnet.subnet-out.id
  vpc_security_group_ids = [aws_security_group.aws-sg.id]
  availability_zone = var.avail-zone
  key_name = aws_key_pair.ssh-key-pair.id
  
    connection {
      type="ssh"
      host=self.public_ip
      user="ubuntu"
      private_key=file(var.key_location)
  }
    
     provisioner "file" {
      source="install.sh"
      destination="/home/ubuntu/install.sh"
      
    }


    provisioner "remote-exec" {
      inline=[
        "sudo chmod u+x install.sh",
        "$(pwd)/install.sh"
      ]
    
    }
   
    provisioner "local-exec" {
    
    command="echo ${self.public_ip} > public_ip.txt"
    }

    tags = {
      "Name" = "${var.app-name}-ubuntu-ec2"
      "Env"= "${var.env-type}"
    }
  
  }

  
  
  

# To get instance details
data "aws_instance" "ec2-details"{
 instance_id = aws_instance.myapp01-server.id
}

