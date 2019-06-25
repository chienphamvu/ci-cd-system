variable "aws_vpc_id" {
  description = "AWS VPC ID"
  default = "vpc-02969966021438af7"
}

variable "aws_access_key" {
  description = "AWS access key"
  default     = ""
}

variable "aws_secret_key" {
  description = "AWS secret key"
  default     = ""
}

variable "aws_private_subnet" {
  description = "AWS private subnet"
  default     = "subnet-0ce0ee2572d14f970"
}

variable "aws_public_subnet" {
  description = "AWS public subnet"
  default     = "subnet-056dcf0ded5890bc3"
}

variable "node_count" {
  description = "Number of node to create"
  default     = 1
}