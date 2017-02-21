# Define AWS Virtual Private Cloud
#
resource "aws_vpc" "demo" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags {
    Name = "lambda-demo-vpc"
  }
}

# Define AWS Subnet
#
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "demo" {
  count             = 2
  vpc_id            = "${aws_vpc.demo.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "${cidrsubnet(aws_vpc.demo.cidr_block, 8, count.index)}"
  tags {
    Name = "lambda-demo-subnet-${count.index}"
  }
  map_public_ip_on_launch = true
}

# Define Internet Gateway
#
resource "aws_internet_gateway" "demo" {
  vpc_id = "${aws_vpc.demo.id}"
  tags {
    Name = "lambda-demo-gw"
  }
}

# Define route tables
#
resource "aws_route_table" "demo" {
  vpc_id = "${aws_vpc.demo.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.demo.id}"
  }
  tags {
    Name = "lambda-demo-routing"
  }
}

resource "aws_route_table_association" "demo" {
  count          = 2
  subnet_id      = "${element(aws_subnet.demo.*.id, count.index)}"
  route_table_id = "${aws_route_table.demo.id}"
}

# Define internal security group for VPC
#
resource "aws_security_group" "demo" {
  name        = "lambda-demo-sg"
  vpc_id      = "${aws_vpc.demo.id}"
  description = "Security group for lambda-demo"
  tags {
    Name = "lambda-demo-sg"
  }
  ingress {
    protocol    = -1                  # no limit inside VPC
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.vpc_cidr}"]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}
