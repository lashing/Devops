provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

variable "web_whitelist" {
  type = list(string)
}
variable "web_ami" {
  type = string
}
variable "web_instance_type" {
  type = string
}
variable "web_desired_capacity" {
  type = number
}
variable "web_max_size" {
  type = number
}
variable "web_min_size" {
  type = number
}

resource "aws_s3_bucket" "prod_tf_bucket" {
  bucket  = "prod-tf-cource-09-8-2021"
  acl     = "private"
}

resource "aws_default_vpc" "default" {
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-west-2a"
  tags              = {
    "Terraform"  :  "True"
  }
}

resource "aws_default_subnet" "default_az2" {
  availability_zone  = "us-west-2b"
  tags               = {
    "Terraform"  : "True"
  }
}

resource "aws_security_group" "prod_web" {
  name        = "prod_web"
  description = "Allow standard http and https ports"
  ingress {
    from_port   =  80
    to_port     =  80
    protocol    =  "tcp"
    cidr_blocks = var.web_whitelist
  }
  ingress {
    from_port   =  443
    to_port     =  443
    protocol    =  "tcp"
    cidr_blocks = var.web_whitelist
  }
  egress {
    from_port  = 443
    to_port    = 443
    protocol   = "-1"
  }

  tags = {
    "Terraform" :  "True"
  }
}
resource "aws_instance" "prod_web" {
  ami           = var.web_ami
  count         = 2
  instance_type = var.web_instance_type
  vpc_security_group_ids = [ aws_security_group.prod_web.id ]
  tags          = {
    "Terraform" : "True"
    }
}

resource "aws_eip_association" "prod_web" {
  allocation_id  = aws_eip.prod_web.id
  instance_id    = aws_instance.prod_web.0.id
}

resource "aws_eip" "prod_web" {
  tags      = {
    "Terraform" : "True"
    }
}

resource "aws_elb" "prod_web_nonasg" {
  name            = "prod-web-nonasg"
  instances       = aws_instance.prod_web.*.id
  security_groups = [aws_security_group.prod_web.id]
  subnets         = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  tags  = {
  "Terraform" : "True"
  }

}
## From this section below ,using module to create an elb,asg and attachment. variables to module
##will be passed from here.

module "web_app" {
  source                 = "./modules/web_app"

  web_whitelist          = var.web_whitelist
  web_ami                = var.web_ami
  web_instance_type      = var.web_instance_type
  web_desired_capacity   = var.web_desired_capacity
  web_max_size           = var.web_max_size
  web_min_size           = var.web_min_size
  security_groups        = [aws_security_group.prod_web.id]
  subnets                = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  web-app                = "prod-hurray"

}
