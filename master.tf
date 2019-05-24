provider "aws" {
  region     = "us-east-2"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"

  version = "~> 2.0"
}

# resource "aws_vpc" "myvpc" {
#   cidr_block = "10.0.0.0/16"
#   instance_tenancy = "default"

#   tags {
#     Name = "myvpc"
#   }
# }

# resource "aws_internet_gateway" "mygateway" {
#   vpc_id = "${aws_vpc.myvpc.id}"

#   tags {
#     Name  = "main"
#   }
# }

##################################
#          Public subnet
##################################

resource "aws_subnet" "myVPC-public-subnet" {
  vpc_id = "${var.aws_vpc_id}"
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-2a"

  tags {
    Name = "myvpc-public"
  }
}

# resource "aws_route_table" "route-table-public" {
#   vpc_id = "${aws_vpc.myvpc.id}"

#   route {
#     cidr_block = "10.0.1.0/24"
#     gateway_id = "${aws_internet_gateway.mygateway.id}"
#   }

#   tags {
#     Name = "my-route-table"
#   }
# }

# resource "aws_route_table_association" "route-table-public-subnet" {
#   subnet_id = "${aws_subnet.myvpc-public-subnet.id}"
#   route_table_id = "${aws_route_table.route-table.id}"
# }

##################################
#          Private subnet
##################################

# resource "aws_subnet" "myvpc-private-subnet" {
#   vpc_id = "${aws_vpc.myvpc.id}"
#   cidr_block = "10.0.3.0/24"
#   map_public_ip_on_launch = "false"
#   availability_zone = "us-east-2a"

#   tags {
#     Name = "myvpc-private"
#   }
# }

# resource "aws_eip" "my-eip" {
#   vpc = true
# }

# resource "aws_nat_gateway" "my-nat-gateway" {
#   allocation_id = "${aws_eip.my-eip.id}"
#   subnet_id = "${aws_subnet.myvpc-public-subnet.id}"
#   depends_on = ["aws_internet_gateway.mygateway"]
# }

# resource "aws_route_table" "route-table-private" {
#   vpc_id = "{aws_vpc.myvpc.id}"
#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = "${aws_nat_gateway.my-nat-gateway.id}"
#   }

#   tags {
#     Name = "aws-route-table"
#   }
# }

# resource "aws_route_table_association" "route-table-private-subnet" {
#   subnet_id = "${aws_subnet.myvpc-private-subnet.id}"
#   route_table_id = "${aws_route_table.route-table-private.id}"
# }

##################################
#          Instance
##################################

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH traffic"
  vpc_id      = "${var.aws_vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "ssh"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "admin" {
  key_name = "private-key"

  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDd98QYvKr7toHasiMJA1TOSCiQ75YcncMLnYkG+FTgRPcmSHZAq8499X7PAvi1CPiYYlNDY8qKpn8AqojDmaTU6jJU8QTolE6HsCDzZoohp781KETsb+EBtp2Ba1UHPAXPD1Uotg8lhfCyk3fgwYZO4hhOS82MXX/AoXV/frGFciI9WYEG9WjN01GhX8yJvRoLCxyke6es7eHV8bWUlGU68cOH+xyGUkt++rNmnxn0YZeUbDTEQChYdnH91OovRdHdXf+pXW2ZHwKiy1h0fSKc8vFzSQmiCOVHhBlZAX+xlRntUWTrCEvNtkMBeF+Wr6Td83EFAjkH8h2HMThQtDib pvchien@pvchien-comp"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "master" {
  ami                     = "${data.aws_ami.ubuntu.id}"
  instance_type           = "t2.micro"
  vpc_security_group_ids  = ["${aws_security_group.allow_ssh.id}"]
  subnet_id               = "${var.aws_private_subnet_id}"
  key_name                = "${aws_key_pair.admin.id}"

  tags = {
    Name = "Master node"
  }
}

resource "aws_instance" "bastion" {
  ami                     = "${data.aws_ami.ubuntu.id}"
  instance_type           = "t2.micro"
  vpc_security_group_ids  = ["${aws_security_group.allow_ssh.id}"]
  subnet_id               = "${aws_subnet.myVPC-public-subnet.id}"
  key_name                = "${aws_key_pair.admin.id}"

  tags = {
    Name = "Master node"
  }
}
