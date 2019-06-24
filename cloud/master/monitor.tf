# resource "aws_instance" "monitor" {
#   ami                     = "ami-0da0dfdf36db6e7e1"
#   instance_type           = "t2.micro"
#   vpc_security_group_ids  = ["${aws_security_group.allow_ssh.id}"]
#   subnet_id               = "${aws_subnet.myvpc_public_subnet.id}"
#   key_name                = "${aws_key_pair.admin.id}"
#   user_data               = "${data.template_file.monitor_config.rendered}"

#   tags = {
#     Name = "Monitor node"
#   }
# }

# data "template_file" "monitor_config" {
#   template = "${file("${path.module}/../../configs/ignition/monitor.json")}"

#   vars = {
#   }
# }
