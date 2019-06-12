provider "aws" {
  region     = "ap-southeast-1"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"

  version = "~> 2.0"
}

#######################
# NETWORK
#######################

resource "aws_subnet" "myvpc_public_subnet" {
  vpc_id = "${var.aws_vpc_id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "ap-southeast-1a"
}

resource "aws_route_table_association" "public_subnet_routetable" {
  subnet_id      = "${aws_subnet.myvpc_public_subnet.id}"
  route_table_id = "${var.route_table_id}"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH traffic"
  vpc_id      = "${var.aws_vpc_id}"

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

#######################
# INSTANCE
#######################

resource "aws_key_pair" "admin" {
  key_name = "public-key"

  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDd98QYvKr7toHasiMJA1TOSCiQ75YcncMLnYkG+FTgRPcmSHZAq8499X7PAvi1CPiYYlNDY8qKpn8AqojDmaTU6jJU8QTolE6HsCDzZoohp781KETsb+EBtp2Ba1UHPAXPD1Uotg8lhfCyk3fgwYZO4hhOS82MXX/AoXV/frGFciI9WYEG9WjN01GhX8yJvRoLCxyke6es7eHV8bWUlGU68cOH+xyGUkt++rNmnxn0YZeUbDTEQChYdnH91OovRdHdXf+pXW2ZHwKiy1h0fSKc8vFzSQmiCOVHhBlZAX+xlRntUWTrCEvNtkMBeF+Wr6Td83EFAjkH8h2HMThQtDib pvchien@pvchien-comp"
}

resource "aws_instance" "master" {
  ami                     = "ami-0da0dfdf36db6e7e1"
  instance_type           = "t2.micro"
  vpc_security_group_ids  = ["${aws_security_group.allow_ssh.id}"]
  subnet_id               = "${aws_subnet.myvpc_public_subnet.id}"
  key_name                = "${aws_key_pair.admin.id}"
  user_data               = "${data.template_file.master_config.rendered}"

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

# resource "aws_volume_attachment" "ebs_att" {
#   device_name = "/dev/xvdh"
#   volume_id   = "${aws_ebs_volume.data.id}"
#   instance_id = "${aws_instance.master.id}"
# }

########################
# Cloud configuration
########################

data "template_file" "master_config" {
  template = "${file("${path.module}/../configs/ignition/master.json")}"

  vars = {
  }
}

# resource "null_resource" "master_config_update" {

#   triggers {
#     template_rendered = "${data.template_file.master_config.rendered}"
#   }

#   connection {
#     type = "ssh"
#     user = "core"
#     host = "${aws_instance.master.public_ip}"
#     private_key = "${file("~/.ssh/id_rsa")}"
#   }

#   provisioner "file" {
#     content     = "${data.template_file.master_config.rendered}"
#     destination = "/tmp/CustomData"
#   }

#   # To change to EC2 specific
#   # http://169.254.169.254/metadata/v1/user-data
#   # https://coreos.com/os/docs/latest/cloud-config-locations.html
#   provisioner "remote-exec" {
#     inline = [
#       "sudo diff /tmp/CustomData /var/lib/waagent/CustomData | tee /tmp/CustomData-diff",
#       "sudo cp /tmp/CustomData /var/lib/waagent/CustomData"
#     ]
#   }
# }
