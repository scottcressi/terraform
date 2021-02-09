variable "environment" {
  description = <<EOT
  choices: local | shared | dev | etc.
  local - as many local as possible
  shared - cluster for shared resources such as jenkins, elasticsearch, grafana, etc.
  dev/etc - a non shared real environment cluster
  EOT
  type        = string
  default = "dev"
}

variable "zone" {
  description = "ex. 'example' if you own example.com"
  type        = string
  default = "scottcressi"
}

variable "region" {
  description = "ex. us-east-1"
  type        = string
  default = "us-east-1"
}

variable "jenkinsgithubuser" {
  description = "ex. example"
  type        = string
  default = "scottcressi"
}
