output "master_public_ip" {
  value = "${aws_instance.master.public_ip}"
}

# output "monitor_public_ip" {
#   value ="${aws_instance.monitor.public_ip}"
# }