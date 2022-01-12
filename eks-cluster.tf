provider "kubernetes"{
    load_config_file=false
    host=data.aws_eks_cluster.myapp-cluster.endpoint
    token=data.aws_eks_cluster_auth.myapp-cluster.token
    cluster_ca_certificate=base64decode(data.aws_eks_cluster.myapp-cluster.certificate_authority.0.data)
}


data "aws_eks_cluster" "myapp-cluster"{
    name=module.eks.cluster_id
}

data "aws_eks_cluster_auth" "myapp-cluster"{
    name=module.eks.cluster_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.0.0"
  # insert the 11 required variables here
  
  cluster_name ="myapp-eks-cluster"
  cluster_version ="1.21"

  subnet_ids=module.myapp-vpc.private_subnets
  vpc_id=module.myapp-vpc.vpc_id  
 
 tags={
     environment="dev"
     application="my-test-app"
 }

 eks_managed_node_groups = [
     {
         create_launch_template = false
         launch_template_name   = ""
         instance_types =["t2.micro"]
         name ="worker-group-1"
         asg_desired_capacity=2
     },
     {
        create_launch_template = false
        launch_template_name   = ""
         instance_types =["t2.micro"]
         name ="worker-group-2"
         asg_desired_capacity=2
     }
 ]


#   eks_managed_node_groups = {
#     bottlerocket_default = {
#       create_launch_template = false
#       launch_template_name   = ""

#       ami_type = "BOTTLEROCKET_x86_64"
#       platform = "bottlerocket"
#     }
#   }

}