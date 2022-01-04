# Print public ip after creation
output "aws_instance_details" {
  value = module.module-webserver.aws_instance_details-ip
  }

# output "user_data_details"{
#   value = aws_instance.myapp01-server.user_data
# }
#test