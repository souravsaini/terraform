output "public_ip" {
	value = "${aws_instance.sourav-test.public_ip}"
}

output "elb_dns_name" {
	value = "${aws_elb.example.dns_name}"
}
