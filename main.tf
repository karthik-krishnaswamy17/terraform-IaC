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



module "module-webserver" {
  source = "./modules/webserver"
  app-name=var.app-name
  env-type=var.env-type
  avail-zone=var.avail-zone
  instance-type=var.instance-type
  my-ip=var.my-ip
  key_location=var.key_location
  myapp-vpc=aws_vpc.myapp-vpc
  subnet_id=module.module-subnet.subnet-out.id
  owners=var.owners
  image_name=var.image_name
  }
  


