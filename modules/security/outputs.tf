output "ec2_role_arn" {
  description = "ARN of the EC2 IAM role"
  value       = aws_iam_role.ec2_role.arn
}

output "ec2_instance_profile_name" {
  description = "Name of the EC2 instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "web_security_group_id" {
  description = "ID of the web security group"
  value       = aws_security_group.web_sg.id
}

output "ssh_security_group_id" {
  description = "ID of the SSH security group"
  value       = aws_security_group.ssh_sg.id
}

output "db_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.db_sg.id
}

output "soc_security_group_id" {
  description = "ID of the SOC services security group"
  value       = aws_security_group.soc_sg.id
}
