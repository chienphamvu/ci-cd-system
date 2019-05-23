variable "aws_access_key" {
  description = "AWS access key"
  default     = ""
}

variable "aws_secret_key" {
  description = "AWS secret key"
  default     = ""
}

variable "aws_internet_gateway_id" {
  description = "AWS Internet Gateway ID"
}

variable "aws_vpc_id" {
  description = "AWS VPC ID"
}

variable "aws_private_subnet_id" {
  description = "AWS private subnet ID"
}

variable "aws_private_security_group_id" {
  description = "AWS private security group ID"
}