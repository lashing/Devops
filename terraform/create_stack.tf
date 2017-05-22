provider "aws" {
  region = "us-west-2"
}

# Create a new load balancer
resource "aws_elb" "bar" {
  name               = "Web-external-elb-1"
  subnets = ["subnet-4c8ad22b","subnet-8b0a79c2"]
  security_groups = ["${aws_security_group.webelb-sg.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  tags {
    Name = "Web-external-elb-1"
  }
}
#Create Web ELB security group
resource "aws_security_group" "webelb-sg" {
  name        = "webelb-sg"
  description = "Allow all inbound traffic"
  vpc_id = "vpc-aee0ecc9"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

}
#Create Web Instance Security Group
resource "aws_security_group" "webinstance-sg" {
  name        = "webinstance-sg"
  description = "Allow all inbound traffic"
  vpc_id = "vpc-aee0ecc9"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = ["${aws_security_group.webelb-sg.id}"]
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
#Create Web Instance
resource "aws_instance" "web" {
  ami           = "ami-6f68cf0f"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  vpc_security_group_ids = ["${aws_security_group.webinstance-sg.id}"]
  subnet_id = "subnet-4c8ad22b"
  user_data = "${data.template_file.ngxinit.rendered}"
  key_name = "web-dev"
  tags {
    Name = "Web-dev-ngx1"
  }
}

# Create a new load balancer attachment
resource "aws_elb_attachment" "ngx" {
  elb      = "Web-external-elb-1"
  instance = "${aws_instance.web.id}"
}

#Defining User data
data "template_file" "ngxinit" {
  template = "${file("ngx_setup.tpl")}"
  vars {
    cluster = "nginx"
  }
}
