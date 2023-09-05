provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "demo-server" {
    ami = "ami-051f7e7f6c2f40dc1"
    instance_type = "t2.micro"
    key_name = "devops"
    // security_groups = [ "demo-sg" ]
    vpc_security_group_ids = [ aws_security_group.demo-sg.id ]
    subnet_id = aws_subnet.demo-public-subnet-01.id
    for_each = toset(["jenkins_master", "jenkins_slave", "ansible_server"])
    tags = {
        Name = "${each.key}"
    }

  
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH-access"
  vpc_id = aws_vpc.demo-vpc.id


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

resource "aws_vpc" "demo-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    name = "demo.vpc"
  }
}

resource "aws_subnet" "demo-public-subnet-01" {
  
  vpc_id = aws_vpc.demo-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
  tags = {
    name = "demo-public-subnet-01" 
  }

}

resource "aws_subnet" "demo-public-subnet-02" {
  
  vpc_id = aws_vpc.demo-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1b"
  tags = {
    name = "demo-public-subnet-02" 
  }

}

resource "aws_internet_gateway" "demo-igw" {
   vpc_id = aws_vpc.demo-vpc.id
   tags = {
    name = "demo-igw" 
  }
}

resource "aws_route_table" "demo-rt" {
    vpc_id = aws_vpc.demo-vpc.id
    route  {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.demo-igw.id

    }
  
}

resource "aws_route_table_association" "demp-rta-public-subnet-01" {
    subnet_id = aws_subnet.demo-public-subnet-01.id
    route_table_id = aws_route_table.demo-rt.id
  
}

resource "aws_route_table_association" "demp-rta-public-subnet-02" {
    subnet_id = aws_subnet.demo-public-subnet-02.id
    route_table_id = aws_route_table.demo-rt.id
  
}