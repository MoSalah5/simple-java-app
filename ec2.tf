resource "aws_instance" "default" {
  instance_type = "t2.micro"
  ami           = "ami-0b5eea76982371e91"
  tags = {
    "Name" = "jenkins_server"
  }
  security_groups = [aws_security_group.default.name]
  key_name        = "devops_admin"

  user_data = <<EOF
      #!/bin/bash
      sudo yum update -y
      sudo wget -O /etc/yum.repos.d/jenkins.repo \
        https://pkg.jenkins.io/redhat-stable/jenkins.repo
      sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
      sudo yum upgrade
      sudo amazon-linux-extras install java-openjdk11 -y
      sudo yum install jenkins -y
      sudo systemctl enable jenkins
      sudo systemctl start jenkins
  EOF
}

resource "aws_security_group" "default" {
  name        = "jenkins_sg"
  description = "jenkins_sg"
  vpc_id      = "vpc-01af46ea0ee710a46"
  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "jenkins_sg"
  }
}

output "instance_public_dns_name" {
  value = aws_instance.default.public_dns
}