variable "location" {
  description = "choices: local | aws"
  type        = string
}

variable "environment" {
  description = "choices: local | dev | shared | $ENV"
  type        = string
}

variable "zone" {
  description = "ex. 'example' if you own example.com"
  type        = string
}

variable "region" {
  description = "us-east-1"
  type        = string
  default     = "us-east-1"
}
