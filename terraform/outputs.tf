output "instance_id" {
    description = "id of the EC2 instance"
    value = aws_instance.app_server.id
}

output "instance_private_ip" {
    description = "priveta ip addres of the EC2 instance"
    value = aws_instance.app_server.private_ip
}
output "instance_public_ip" {
    description = "priveta ip addres of the EC2 instance"
    value = aws_instance.app_server.public_ip
}