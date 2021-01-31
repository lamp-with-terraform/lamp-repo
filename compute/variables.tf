variable "key_name" {
    default = "lamp_auth"
}

variable "public_key_path" {
    default = "/home/ec2-user/.ssh/id_rsa.pub"
}

variable "myvpc_public_subnet" {}

variable "web_security_group" {}
