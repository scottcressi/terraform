variable "location" {
  description = "choices: local | aws"
  type        = string
}

variable "environment" {
  description = "choices: local | shared | $ENV"
  type        = string
}

variable "zone" {
  description = "ex. 'example' if you own example.com"
  type        = string
}

variable "region" {
  description = "ex. us-east-1"
  type        = string
}

variable "jenkinsgithubuser" {
  description = "ex. example"
  type        = string
}
