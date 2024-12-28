variable region {
    default = "us-east-2"
}
variable vpc_cidr {
    default = "10.0.0.0/16"
}

variable subnet1_cidr {
    default = "10.0.1.0/24"
}

variable subnet2_cidr {
    default = "10.0.2.0/24"
}
variable ip_on_launch {
    type = bool
    default = true
}
variable instance_size {
    default = "t2.micro"
}
variable port {
    default = [22, 9090, 9100]
}