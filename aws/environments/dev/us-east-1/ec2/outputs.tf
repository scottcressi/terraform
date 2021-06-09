output "public_ip" {
  value       = module.ec2.public_ip
}

output "ami_user" {
  value       = "ubuntu"
}
