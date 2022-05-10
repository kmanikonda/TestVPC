variable "vpc_cidr" {
  type        = string
  description = "Primary VPC CIDR Block"
  default     = "172.29.0.0/18"
}

variable "shared_public_cidrblock" {
  type    = string
  default = "172.29.0.0/22"
}

variable "shared_private_cidrblock" {
  type    = string
  default = "172.29.4.0/22"
}

variable "shared_internal_cidrblock" {
  type    = string
  default = "172.29.8.0/22"
}

variable "subnet_count_per_network" {
  type        = number
  description = "Number of subnets per network like Public/Private/Internal"
  default     = 3
}

# variable "network_type" {
#   type = map(list(string))
#   default = {
#     "public"   = ["172.29.0.0/24", "172.29.1.0/24", "172.29.2.0/24"]
#     "private"  = ["172.29.4.0/24", "172.29.5.0/24", "172.29.6.0/24"]
#     "internal" = ["172.29.8.0/24", "172.29.9.0/24", "172.29.10.0/24"]
#   }

# }

variable "network_type" {
  type = map(any)
  default = {
    "public"   = "172.29.0.0/24"
    "private"  = "172.29.4.0/24"
    "internal" = "172.29.8.0/24"
  }

}
