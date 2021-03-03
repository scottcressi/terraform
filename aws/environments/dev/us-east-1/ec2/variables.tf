variable "environment" {
  description = <<EOT
  choices: local | shared | dev | etc.
  local - as many local as possible
  shared - cluster for shared resources such as jenkins, elasticsearch, grafana, etc.
  dev/etc - a non shared real environment cluster
  EOT
  type        = string

  validation {
    condition     = length(var.environment) > 0
    error_message = "The environment must not be blank."
  }
  default = "dev"
}

variable "region" {
  description = "ex. us-east-1"
  type        = string
  default     = "us-east-1"
}

variable "state_key" {
  description = "ex. us-east-1"
  type        = string
  default     = "dev/us-east-1/network/terraform.tfstate"
}

variable "state_bucket" {
  description = "ex. us-east-1"
  type        = string
  default     = "terraform-state-7ac65cd8-518c-40db-99a7-8948133592ca"
}

variable "zone" {
  description = "ex. 'example' if you own example.com"
  type        = string
  default     = "scottcressi"
}
