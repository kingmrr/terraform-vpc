resource "aws_internet_gateway" "prod-igw" {
    vpc_id = "${aws_vpc.prod-vpc.id}"
    
    tags {
        Name = "prod-igw"
    }
}

resource "aws_route_table" "prod-public-crt" {
    vpc_id = "${aws_vpc.prod-vpc.id}"

    route {
        //associated subnet can reach everywhere
        cidr_block ="0.0.0.0./0"

        //CRT uses IGW to reacg internet
        gateway_id = "${aws_internet_gateway.prod-igw.id}"
    }

    tags {
        Name = "prod-public-crt"
    }
}
//Associate CRT and Subnet
resource "aws_route_table_association" "prod-crta-public-subnet-1" {
    subnet_id = "${aws_subnet.prod-subnet-public-1.id}"
    route_table_id = "${aws_route_table.prod-public-crt.id}"
}

//Create a security group
resource "aws_security_group" "ssh-allowed" {
    vpc_id = "${aws_vpc.prod-vpc.id}"

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = "[0.0.0.0/0]"
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"

        //Thus means all ip addresses are allowed to ssh
        //Do not do this in Prod
        cidr_blocks = "[0.0.0.0/0]"
    }
    
    //if you do not add this rule, you can not reach NGIX 
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = "[0.0.0.0/0]"
    }

    tags {
        Name = "ssh-allowed"
    }

}