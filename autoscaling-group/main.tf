provider "aws" {
	region = "us-west-2"
}

resource "aws_instance" "sourav-test" {
	ami = "ami-0bbe6b35405ecebdb"
	instance_type = "t2.micro"
	availability_zone = "us-west-2a"
	vpc_security_group_ids = ["${aws_security_group.sourav-sg.id}"]

	user_data = <<-EOF
		    #!/bin/bash
		    echo "Hello World!" > index.html
		    nohup busybox httpd -f -p "${var.server_port}" &
		    EOF
	tags {
		Name = "sourav-test"
		Purpose = "Test"
	}
}

resource "aws_security_group" "sourav-sg" {
	name = "sourav-sg"

	ingress {
		from_port = "${var.server_port}" 
		to_port   = "${var.server_port}"
		protocol  = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	lifecycle {
		create_before_destroy = true
	}
}

resource "aws_launch_configuration" "example" {
	image_id = "ami-0bbe6b35405ecebdb"
	instance_type = "t2.micro"
	security_groups = ["${aws_security_group.sourav-sg.id}"]

	user_data = <<-EOF
	            #!/bin/bash
		    echo "Hello, World" > index.html
		    nohup busybox httpd -f -p "${var.server_port}" &
		    EOF
	
	lifecycle {
		create_before_destroy = true
	}
}

data "aws_availability_zones" "all" {}

resource "aws_autoscaling_group" "example" {
	launch_configuration = "${aws_launch_configuration.example.id}"
	availability_zones = ["${data.aws_availability_zones.all.names}"]
	min_size = 2
	max_size = 10
	
	tag {
		key = "Name"
		value = "terraform-asg-example"
		propagate_at_launch = true
	}
}
 
