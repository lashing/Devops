# Program to create multi layer web application using terraform
provider "aws" {
  region = "us-west-2"
}

# Create a new public load balancer for Nginx tier
resource "aws_elb" "ngx" {
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
# Create a new internal load balancer for application tier
resource "aws_elb" "app" {
  name               = "App-internal-elb-1"
  subnets = ["subnet-e3792284","subnet-e93042a0"]
  security_groups = ["${aws_security_group.appilb-sg.id}"]
  internal = "true"

  listener {
    instance_port     = 8081
    instance_protocol = "http"
    lb_port           = 8081
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8081/"
    interval            = 30
  }

  tags {
    Name = "App-internal-elb-1"
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
#Create App ILB security group
resource "aws_security_group" "appilb-sg" {
  name        = "appilb-sg"
  description = "Allow traffic from web nginx instance"
  vpc_id = "vpc-aee0ecc9"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = ["${aws_security_group.webinstance-sg.id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

}
#Create Web-nginx Instance Security Group
resource "aws_security_group" "webinstance-sg" {
  name        = "webinstance-sg"
  description = "Allow inbound traffic for web nginx instance"
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
#Create App Instance Security Group
resource "aws_security_group" "appinstance-sg" {
  name        = "appinstance-sg"
  description = "Allow in bound traffic from App ILB"
  vpc_id = "vpc-aee0ecc9"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = ["${aws_security_group.appilb-sg.id}"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = ["${aws_security_group.webinstance-sg.id}"]
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
  ami           = "ami-f9626b80"
  instance_type = "t2.micro"
  subnet_id = "subnet-4c8ad22b"
  associate_public_ip_address = "true"
  vpc_security_group_ids = ["${aws_security_group.webinstance-sg.id}"]
  user_data = "${data.template_file.ngxinit.rendered}"
  key_name = "web-dev"
  tags {
    Name = "Web-dev-ngx1"
  }
}

#Create App Instances
resource "aws_instance" "app" {
  ami           = "ami-6cc84a0c"
  subnet_id = "subnet-e3792284"
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  vpc_security_group_ids = ["${aws_security_group.appinstance-sg.id}"]
  user_data = "${data.template_file.nodejsinit.rendered}"
  key_name = "web-dev"
  tags {
    Name = "Wed-dev-app1"
  }
}

# Create a new load balancer attachment for Web Nginx
resource "aws_elb_attachment" "ngx" {
  elb      = "Web-external-elb-1"
  instance = "${aws_instance.web.id}"
}

# Create a new load balancer attachment for App tier
resource "aws_elb_attachment" "app" {
  elb      = "App-internal-elb-1"
  instance = "${aws_instance.app.id}"
}

#Defining User data
data "template_file" "ngxinit" {
  template = "${file("ngx_setup.tpl")}"
  vars {
    cluster = "nginx"
  }
}
data "template_file" "nodejsinit" {
  template = "${file("nodejs_setup.tpl")}"
  vars {
    cluster = "nodejs"
  }
}
