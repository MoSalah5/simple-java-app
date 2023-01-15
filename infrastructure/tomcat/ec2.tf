resource "aws_instance" "default" {
  instance_type = "t2.micro"
  ami           = "ami-0b5eea76982371e91"
  tags = {
    "Name" = "tomcat_server"
  }
  security_groups = [aws_security_group.default.name]
  key_name        = "devops_admin"

  user_data = <<EOF
      #!/bin/bash
      yum update -y
      yum install -y java-1.8*
      #Download tomcat binary
      cd /opt
      wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.0.27/bin/apache-tomcat-10.0.27.tar.gz
      tar -xvzf /opt/apache-tomcat-10.0.27.tar.gz
      mv apache-tomcat-10.0.27 tomcat ; rm -rf apache-tomcat-10.0.27.tar.gz
      chmod +x /opt/tomcat/bin/startup.sh 
      chmod +x /opt/tomcat/bin/shutdown.sh
      ln -s /opt/tomcat/bin/startup.sh /usr/local/bin/tomcatup
      ln -s /opt/tomcat/bin/shutdown.sh /usr/local/bin/tomcatdown
      tomcatup
  EOF
}

resource "aws_security_group" "default" {
  name        = "tomcat_sg"
  description = "tomcat_sg"
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
    Name = "tomcat_sg"
  }
}

output "instance_public_dns_name" {
  value = aws_instance.default.public_dns
}