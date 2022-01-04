output "aws_instance_details-ip" {
  value = data.aws_instance.ec2-details.public_ip
  }