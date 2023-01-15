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
      ###########################
      ## install git ##
      sudo yum install git -y
      ##########################
      ## install terraform
      sudo yum install -y yum-utils
      sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
      sudo yum -y install terraform
      ###########################
      ## install maven
      sudo cd /opt/
      sudo wget https://dlcdn.apache.org/maven/maven-3/3.8.7/binaries/apache-maven-3.8.7-bin.tar.gz
      sudo tar -xvf apache-maven-3.8.7-bin.tar.gz
      sudo mv apache-maven-3.8.7 maven
      sudo sed -i '$ d' ~/.bash_profile
      sudo echo "M2_HOME=/opt/maven  
        M2=/opt/maven/bin 
        JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.16.0.8-1.amzn2.0.1.x86_64" >> ~/.bash_profile
      sudo echo "PATH=$PATH:$HOME/bin:/opt/maven:/opt/maven/bin:/usr/lib/jvm/java-11-openjdk-11.0.16.0.8-1.amzn2.0.1.x86_64" >> ~/.bash_profile
      sudo echo "export PATH" >> ~/.bash_profile
      sudo source ~/.bash_profilex
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