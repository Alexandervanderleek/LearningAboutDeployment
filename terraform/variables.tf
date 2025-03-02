variable "db_password" {
    description = "The password for the RDS instance"
    type = string
    sensitive = true
}

variable "db_username" {
    description = "The username for the RDS instance"
    type = string
}

variable "db_instance_identifier" {
  description = "Database instance identifer"
  type = string
  default = "tstdbinstance"
}

variable "db_name" {
  description = "Database name"
  type = string
  default = "testdatabase"
}

variable "aws_region" {
  description = "AWS region"
  type = string
  default = "af-south-1"
}