
provider "aws" {
  access_key = "your-access-key"
  secret_key = "your-secret-key"
  region = "eu-north-1"
}


resource "aws_vpc" "example_vpc" {
  cidr_block = "10.0.0.0/16"
}


resource "aws_subnet" "example_subnet" {
  vpc_id = aws_vpc.example_vpc.id
  cidr_block = "10.0.0.0/24"
}


resource "aws_security_group" "example_sg" {
  name        = "example_sg"
  description = "Example Security Group"
  vpc_id      = aws_vpc.example_vpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "first_server" {
  ami                    = "ami-0a79730daaf45078a"  
  instance_type          = "t3.micro"
  key_name               = "yanasobol"
  vpc_security_group_ids = [aws_security_group.example_sg.id]
  subnet_id              = aws_subnet.example_subnet.id
  user_data              = <<-EOT
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo docker run -d -p 9090:9090 --name prometheus prom/prometheus
              sudo docker run -d -p 9100:9100 --name node_exporter prom/node-exporter
              EOT

connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("D:/Завантаження/yanasobol.pem")
    host = self.public_ip
}

  provisioner "remote-exec" {
    inline = [
      "sleep 30",  
      "echo 'Installation completed on Server 1'",
    ]
    

  }
  tags = {
    Name = "first_server"
  }
}


resource "aws_instance" "second_server" {
  ami                    = "ami-0a79730daaf45078a"
  instance_type          = "t3.micro"
  key_name               = "yanasobol"
  vpc_security_group_ids = [aws_security_group.example_sg.id]
  subnet_id              = aws_subnet.example_subnet.id
  user_data              = <<-EOT
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo docker run -d -p 9100:9100 --name node_exporter prom/node-exporter
    EOT

  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "echo 'Installation completed on Server 2'",
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("D:/Завантаження/yanasobol.pem")
    host        = self.public_ip
  }
  tags = {
    Name = "first_server"
  }
}
