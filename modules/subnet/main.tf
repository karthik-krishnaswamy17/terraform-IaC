resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = var.myapp-vpc.id
    cidr_block = var.subnet-1_cidr_block
    availability_zone = var.avail-zone
    

tags = {
      "Name" = "${var.app-name}-subnet-1"
      "Env"= "${var.env-type}"
    }
  
}

# Internet Gateway creation
resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = var.myapp-vpc.id

  tags = {
      "Name" = "${var.app-name}-igw"
      "Env"= "${var.env-type}"
    }
}

# Route table creation and mapping to igw
resource "aws_route_table" "myapp-rt" {
    vpc_id = var.myapp-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
      "Name" = "${var.app-name}-rt"
      "Env"= "${var.env-type}"
    }

}
# Map Route table to created subnet-1
resource "aws_route_table_association" "assoc-subnet"{
    subnet_id = aws_subnet.myapp-subnet-1.id
    route_table_id = aws_route_table.myapp-rt.id

}