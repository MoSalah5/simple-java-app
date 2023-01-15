variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "ami" {
  type = string
  default = "ami-0b5eea76982371e91"
}

variable "tags" {
  type = map
}

variable "security_group_name" {
  type = string
}

variable "key_name" {
  type = string
}

variable "user_data" {
  type = string
}