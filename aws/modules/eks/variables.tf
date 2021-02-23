variable "environment" {
  description = <<EOT
  choices: local | shared | dev | etc.
  local - as many local as possible
  shared - cluster for shared resources such as jenkins, elasticsearch, grafana, etc.
  dev/etc - a non shared real environment cluster
  EOT
  type        = string
}

variable "region" {
  description = "ex. us-east-1"
  type        = string
}
