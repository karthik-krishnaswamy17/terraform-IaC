provider "aws"{
    region="ap-south-1"
}


# data "aws_availability_zones" "azs"{}

module "myapp-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.11.2"
  # insert the 21 required variables here
  cidr = var.vpc_cidr_block
  name = "myapp-vpc"
  
  private_subnets= var.private_subnets_cidr_blocks
  public_subnets= var.public_subnets_cidr_blocks
  # azs = data.aws_availability_zones.azs.names
  azs= ["ap-south-1a","ap-south-1b"]

  enable_nat_gateway=true
  single_nat_gateway=true
  enable_dns_hostnames=true
  
  tags={
    "kubernetes.io/cluster/myapp-eks-cluster" ="shared"
  }
  public_subnet_tags={
  "kubernetes.io/cluster/myapp-eks-cluster" ="shared"
  "kubernetes.io/role/elb"=1
  }
  private_subnet_tags={
  "kubernetes.io/cluster/myapp-eks-cluster" ="shared"
  "kubernetes.io/role/internal-elb"=1
  }



}
