resource aws_vpc "App-vpc"{
    cidr_block = var.vpc_cidr
    tags = {
        Name = "App-vpc"
    }
}

resource "aws_subnet" "Pub-Subnet" {
    vpc_id = aws_vpc.App-vpc.id
    cidr_block = var.Public_subnet_cidr

    tags = {
        Name = "Public-Subnet"
    }
  
}

resource "aws_subnet" "Pri-Subnet" {
    vpc_id = aws_vpc.App-vpc.id
    cidr_block = var.Private_subnet_cidr

    tags = {
        Name = "Private-Subnet"
    }
  
}

resource "aws_internet_gateway" "App-IGW" {
    vpc_id = aws_vpc.App-vpc.id

    tags = {
        Name = "App-IGW"
    }
}

resource "aws_route_table" "Pub-RT" {
    vpc_id = aws_vpc.App-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.App-IGW.id
    }
    tags = {
        Name = "Public-RT"
    }
  
}

resource "aws_route_table_association" "Pub-Association" {
    subnet_id = aws_subnet.Pub-Subnet.id
    route_table_id = aws_route_table.Pub-RT.id 
}

resource "aws_instance" "example" {
   ami = "ami-00e42015cc6980619"
   instance_type = "t3.micro"
   disable_api_stop = false

}

resource "aws_ec2_instance_state" "state" {
    instance_id = aws_instance.example.id
    state = "stopped"
}

