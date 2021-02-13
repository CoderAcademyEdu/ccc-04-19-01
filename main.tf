terraform {
  required_version = ">= 0.13.0"
}

provider "aws" {
    profile = "default"
    region = var.region
}

data "aws_availability_zones" "all" {}

resource "aws_autoscaling_group" "asg_terraform" {
    launch_configuration = aws_launch_configuration.lc_terraform.id
    availability_zones = data.aws_availability_zones.all.names
    load_balancers = [ aws_elb.terraform-elb.name ]
    min_size = 2
    max_size = 4
    tag {
        key = "Name"
        value = "terraform-asg-instances"
        propagate_at_launch = true
    }
}

resource "aws_launch_configuration" "lc_terraform" {
    image_id =  "ami-0d767dd04ac152743"  #"ami-0cfec0fe372e07deb"
    instance_type = "t2.micro"
    security_groups = [ aws_security_group.instance.id ]
    user_data = <<-EOF
              #!/bin/bash
              echo "Server working, terraform rules!" > index.html
              nohup busybox httpd -f -p "${var.port}" &
              EOF
  
}

resource "aws_security_group" "instance" {
    name = "terraform-firs-server-sg"
    ingress {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = var.port
      protocol = "tcp"
      to_port = var.port
    }
  
}

resource "aws_elb" "terraform-elb" {
    name = "terraform-elb"
    availability_zones = data.aws_availability_zones.all.names
    security_groups = [aws_security_group.elb.id ]
    listener {
      lb_port = 80
      lb_protocol = "http"
      instance_port = var.port
      instance_protocol = "http"
    }
  
}

resource "aws_security_group" "elb" {
    name = "terraform-elb-sc"
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress  {
      cidr_blocks = [ "0.0.0.0/0" ]
      from_port = 80
      protocol = "tcp"
      to_port = 80
    }
  
}
