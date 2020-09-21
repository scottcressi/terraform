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
