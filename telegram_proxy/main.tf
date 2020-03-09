provider "aws" {
  region = "eu-central-1"
}

variable "key_name" {
  description = "The ssh key name to generate"
  type        = string
  default     = "telegram_proxy_key"
}

variable "server_port" {
  description = "The port the server will use for HTTPS requests"
  type        = number
  default     = 443
}

resource "tls_private_key" "telegram_proxy_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.telegram_proxy_key.public_key_openssh
}

resource "aws_instance" "telegram_proxy" {
  ami                    = "ami-03d8059563982d7b0"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.telegram_proxy_sg.id]
  key_name               = aws_key_pair.generated_key.key_name

  tags = {
    Name = "telegram_proxy"
  }
}

resource "aws_security_group" "telegram_proxy_sg" {
  name = "telegram_proxy_sg"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value       = aws_instance.telegram_proxy.public_ip
  description = "The public IP of the telegram_proxy server"
}