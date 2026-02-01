output "VPC_ID" {
    description = "VPC ID"
    value = aws_vpc.App-vpc.id 
}

output "ec2_id" {
  description = "value of ec2 instance id"
  value = aws_instance.example.id
}

output "Ec2_state" {
  description = "Ec2 Instance state"
  value = aws_instance.example.instance_state
}