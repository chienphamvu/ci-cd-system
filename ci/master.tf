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

  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1sMXLSKzHuttc17xEWglupc1xreH7CVmNvJJuYSnROcNmy0lw2AAQpNL4M0JzeFyW+KJvz7hOdlD4HysDucyLa+1BZp3zpzMbSHy7McYyu5WgFGamf4PT6Ei6GPTezdGevn/x0NLl/P0a61aDn28xBOY01OMMxaFFG0ZBfBee/QgrgIDrR3xU2LGOc3YWbdShojDv49wXXZlbd13d8eWE/OYWbG4oMX2+Xa5AyjIEH73WGXAYqiQzcD+YecK+F9NlsArHZxIfygAHWrFx53Llx+Bxreq6uHIkufWUFnG/DTQTobPpCnzzinq1cXbXObVNYzhuOAhYPlgRhXpTlbYwe7o0PoWsyH0N4zAaWdJNWVSJIIFtAEHFjU1W8VcBhdF1o9TuInLmQKfDGgIdZWZEHADspYmhPTuCfDX1hbamAmHbXBtdd3wxcAbNuVsEco4VGw9W90+/IvQyuIEN7vkQd0UQyWf5VbzYbDilck4qZpIkZ7l5l+pdoouYldOE4fM= chienpham@chienpham"
}

resource "aws_instance" "master" {
  ami                     = "ami-0da0dfdf36db6e7e1"
  instance_type           = "t2.micro"
  vpc_security_group_ids  = ["${aws_security_group.allow_ssh.id}"]
  subnet_id               = "${aws_subnet.myvpc_public_subnet.id}"
  key_name                = "${aws_key_pair.admin.id}"

  tags = {
    Name = "Master node"
  }
}

resource "aws_ebs_volume" "data" {
  availability_zone = "ap-southeast-1a"
  size              = 2

  tags = {
    Name = "HelloDisk"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/xvdh"
  volume_id   = "${aws_ebs_volume.data.id}"
  instance_id = "${aws_instance.master.id}"
}

########################
# Cloud configuration
########################

data "template_file" "master_config" {
  template = "${file("${path.module}/../configs/ignition/master.yml")}"

  vars = {
  }
}

resource "null_resource" "master_config_update" {

  triggers {
    template_rendered = "${data.template_file.master_config.rendered}"
  }

  connection {
    type = "ssh"
    user = "core"
    host = "${aws_instance.master.public_ip}"
    private_key = "${file("~/.ssh/id_rsa")}"
  }

  provisioner "file" {
    content     = "${data.template_file.master_config.rendered}"
    destination = "/tmp/CustomData"
  }

  # To change to EC2 specific
  # http://169.254.169.254/metadata/v1/user-data
  # https://coreos.com/os/docs/latest/cloud-config-locations.html
  provisioner "remote-exec" {
    inline = [
      "sudo diff /tmp/CustomData /var/lib/waagent/CustomData | tee /tmp/CustomData-diff",
      "sudo cp /tmp/CustomData /var/lib/waagent/CustomData"
    ]
  }
}