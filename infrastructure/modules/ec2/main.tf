resource "aws_instance" "default" {
  instance_type   = var.instance_type
  ami             = var.ami
  tags            = var.tags
  security_groups = [aws_security_group.default.name]
  key_name        = var.key_name
  user_data       = var.user_data
}