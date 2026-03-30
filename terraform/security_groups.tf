resource "aws_instance" "app_server" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    key_name = aws_key_pair.mi_key.key_name
    vpc_security_group_ids = [aws_security_group.app_sg.id]
    tags = {
      Name = "gym_api_server"
    }
}

resource "aws_security_group" "app_sg" {
    name = "app_sg"
    description = "security group for gym api "
    vpc_id = data.aws_vpc.default.id
    tags = {
        Name= "app_sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
    security_group_id = aws_security_group.app_sg.id
    ip_protocol = "tcp"
    from_port = 22
    to_port = 22    
    cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "http" {
    security_group_id = aws_security_group.app_sg.id
    ip_protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "api" {
    security_group_id = aws_security_group.app_sg.id
    ip_protocol = "tcp"
    from_port = 5000
    to_port = 5000
    cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "all_out" {
    security_group_id = aws_security_group.app_sg.id
    ip_protocol = "-1"
    cidr_ipv4 = "0.0.0.0/0"
}


resource "aws_key_pair" "mi_key" {
    key_name = "terraform_ec2"
    public_key = file("~/.ssh/terraform_ec2.pub")
}