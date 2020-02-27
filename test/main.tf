provider "aws" {
  region     = "eu-central-1"
  access_key = "AKIAILASB4SVAHCO7G6A"
  secret_key = "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"
}

resource "aws_instance" "test" {
  ami                    = "ami-03d8059563982d7b0"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data     = <<-EOF
                  #!/bin/bash
                  echo "Hello, World" > index.html
                  nohup busybox httpd -f -p "${var.server_port}" &
                  EOF

  tags = {
    Name = "terraform-test"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-test-instance"
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

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

output "public_ip" {
  value       = aws_instance.test.public_ip
  description = "The public IP of the web server"
}