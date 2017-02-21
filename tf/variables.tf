#################
# External vars #
#################

variable "region" {}

#################
# Internal vars #
#################

# DB credentials

variable "db_username" {
  default = "demouser"
}
variable "db_password" {
  default = "password"
}

# Networking...
#

variable "vpc_cidr" {
  description = "CIDR for the whole VPC"
  default     = "10.99.0.0/16"
}
