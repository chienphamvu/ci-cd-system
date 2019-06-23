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

variable "aws_public_subnet" {
  description = "AWS public subnet"
  default     = "subnet-056dcf0ded5890bc3"
}

variable "aws_ebs_volume" {
  description = "AWS EBS volume"
  default     = "vol-05d924d76df6cc777"
}
