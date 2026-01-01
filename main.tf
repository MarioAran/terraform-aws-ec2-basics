terraform{
    required_providers{
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = "eu-west-1"
}

data "aws_ami" "ubuntu" {
    most_recent = true
    filter {
      name="name"
      values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    }
  owners = ["099720109477"] # Canonical

}


data "aws_vpc" "default" {
    default = true
  
}

resource "aws_instance" "app_server" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    key_name = aws_key_pair.mi_key.key_name
    vpc_security_group_ids = [aws_security_group.allow_ssh.id]
    tags = {
      Name = "learn-terraform"
    }
}

resource "aws_security_group" "allow_ssh" {
    name = "allow_ssh"
    description = "Allow ssh inbound traffic"
    vpc_id = data.aws_vpc.default.id
    tags = {
      Name = "allow_ssh"
    }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
    security_group_id = aws_security_group.allow_ssh.id
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
    cidr_ipv4 =  "0.0.0.0/0" 
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
    security_group_id = aws_security_group.allow_ssh.id
    from_port = 0
    to_port = 0
    ip_protocol = "-1"
    cidr_ipv4 =  "0.0.0.0/0" 
}

resource "aws_key_pair" "mi_key" {
    key_name = "terraform_ec2"
    public_key = file("~/.ssh/terraform_ec2.pub")
}

