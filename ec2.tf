resource "aws_instance" "webserver" {
  ami           = var.ec2_ami
  instance_type = var.ec2_instance_type
  subnet_id     = aws_subnet.repick-vpc-public-subnet-1.id

  key_name               = aws_key_pair.web.id
  vpc_security_group_ids = [aws_security_group.repick-sg.id]

  associate_public_ip_address = true

  user_data = file("user_data.sh")

  tags = {
    Name = "repick-server"
  }

}

resource "aws_key_pair" "web" {
  public_key = file("~/.ssh/id_rsa.pub")
}

output "instance_id" {
  description = "The ID of the instance"
  value       = aws_instance.webserver.id
}

output "public_ip" {
  description = "The Public IP of the instance"
  value       = aws_instance.webserver.public_ip
}