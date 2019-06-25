terraform {
  backend "s3" {
    bucket = "chienpham-terraform-states"
    key    = "aws-node-terraform-states"
    region = "ap-southeast-1"
  }
}

provider "aws" {
  region     = "ap-southeast-1"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"

  version = "~> 2.0"
}

resource "aws_security_group" "node_sc" {
  name        = "node_sc"
  description = "Allow some ports"
  vpc_id      = "${var.aws_vpc_id}"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "node" {
  count                   ="${var.node_count}"
  ami                     = "ami-0da0dfdf36db6e7e1"
  instance_type           = "t2.micro"
  vpc_security_group_ids  = ["${aws_security_group.node_sc.id}"]
  subnet_id               = "${var.aws_public_subnet}"
  key_name                = "jenkins"
  user_data               = "${data.template_file.node_config.rendered}"

  tags = {
    Name = "Slave node"
  }
}

########################
# Cloud configuration
########################

data "template_file" "node_config" {
  template = "${file("${path.module}/../../configs/ignition/node.json")}"

  vars = {
  }
}