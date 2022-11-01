variable "main_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_cidr_blocks" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_cidr_blocks" {
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "container_port" {
  default = 3000
}
