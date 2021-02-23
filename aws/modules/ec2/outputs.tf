output "public_ip" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = module.ec2_with_t3_unlimited.*.public_ip
}
