provider "aws" {
  region     = "ap-southeast-1"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"

  version = "~> 2.0"
}

#######################
# NETWORK
#######################

resource "aws_security_group" "master_sc" {
  name        = "master_sc"
  description = "Allow some ports"
  vpc_id      = "${var.aws_vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 50000
    to_port     = 50000
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

#######################
# INSTANCE
#######################

resource "aws_instance" "master" {
  ami                     = "ami-0da0dfdf36db6e7e1"
  instance_type           = "t2.micro"
  vpc_security_group_ids  = ["${aws_security_group.master_sc.id}"]
  subnet_id               = "${var.aws_public_subnet}"
  key_name                = "jenkins"
  user_data               = "${data.template_file.master_config.rendered}"
  private_ip              = "10.0.1.20"

  tags = {
    Name = "Master node"
  }
}

# resource "aws_ebs_volume" "data" {
#   availability_zone = "ap-southeast-1a"
#   size              = 2

#   tags = {
#     Name = "HelloDisk"
#   }
# }

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/xvdh"
  volume_id   = "${var.aws_ebs_volume}"
  instance_id = "${aws_instance.master.id}"
}

########################
# Cloud configuration
########################

data "template_file" "master_config" {
  template = "${file("${path.module}/../../configs/ignition/master.json")}"

  vars = {
  }
}
