provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "demo-server" {
    ami = "ami-051f7e7f6c2f40dc1"
    instance_type = "t2.micro"
    key_name = "devops"
    security_groups = [ "demo-sg" ]
    for_each = toset(["jenkins_master", "jenkins_slave", "ansible_server"])
    tags = {
        Name = "${each.key}"
    }

  
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH-access"


  ingress {
    description      = "SSH-access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "SSH-access"
  }
}