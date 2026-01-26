variable "vpc_cidr" {
    description = "CIDR of VPC"
    type = string
    default = "10.0.0.0/16"
}

variable "Public_subnet_cidr" {
    description = "CIDR of Public Subnet"
    type = string
    default = "10.0.1.0/24"     
  
}

variable "Private_subnet_cidr" {
    description = "CIDR of Private Subnet"
    type = string
    default = "10.0.2.0/24"
}