# Print public ip after creation
output "aws_instance_details" {
  value = data.aws_instance.ec2-details.public_ip
  }

output "user_data_details"{
  value = aws_instance.myapp01-server.user_data
}
#test