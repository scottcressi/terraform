variable "location" {
  type        = string
  default     = "local"
}

variable "environment" {
  type        = string
  default     = "local"
}

variable "zone" {
  type        = string
  default     = "example"
}

variable "nginx-ingress-certarn" {
  type        = map
  default = {
      local = "foo"
    }
}
