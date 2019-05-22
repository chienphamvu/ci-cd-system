provider "aws" {
  region     = "us-east-1"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"

  version = "~> 2.0"
}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"

  tags {
    Name = "myvpc"
  }
}

resource "aws_internet_gateway" "mygateway" {
  vpc_id = "${aws_vpc.myvpc.id}"

  tags {
    Name  = "main"
  }
}

##################################
#          Public subnet
##################################

resource "aws_subnet" "myvpc-public-subnet" {
  vpc_id = "${aws_vpc.myvpc.id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-2a"

  tags {
    Name = "myvpc-public"
  }
}

resource "aws_route_table" "route-table-public" {
  vpc_id = "${aws_vpc.myvpc.id}"

  route {
    cidr_block = "10.0.1.0/24"
    gateway_id = "${aws_internet_gateway.mygateway.id}"
  }

  tags {
    Name = "my-route-table"
  }
}

resource "aws_route_table_association" "route-table-public-subnet" {
  subnet_id = "${aws_subnet.myvpc-public-subnet.id}"
  route_table_id = "${aws_route_table.route-table.id}"
}

##################################
#          Private subnet
##################################

resource "aws_subnet" "myvpc-private-subnet" {
  vpc_id = "${aws_vpc.myvpc.id}"
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = "false"
  availability_zone = "us-east-2a"

  tags {
    Name = "myvpc-private"
  }
}

resource "aws_eip" "my-eip" {
  vpc = true
}

resource "aws_nat_gateway" "my-nat-gateway" {
  allocation_id = "${aws_eip.my-eip.id}"
  subnet_id = "${aws_subnet.myvpc-public-subnet.id}"
  depends_on = ["aws_internet_gateway.mygateway"]
}

resource "aws_route_table" "route-table-private" {
  vpc_id = "{aws_vpc.myvpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.my-nat-gateway.id}"
  }

  tags {
    Name = "aws-route-table"
  }
}

resource "aws_route_table_association" "route-table-private-subnet" {
  subnet_id = "${aws_subnet.myvpc-private-subnet.id}"
  route_table_id = "${aws_route_table.route-table-private.id}"
}

##################################
#          Instance
##################################

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "master" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"

  tags = {
    Name = "Master node"
  }
}
