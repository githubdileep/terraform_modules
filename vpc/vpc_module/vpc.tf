resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = var.tags
}

resource "aws_vpc" "main" {
  cidr_block          = var.vpc_cidr_block
  instance_tenancy    = "default"
  enable_dns_support  = true
  enable_dns_hostnames = true

  tags = var.tags
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr_block
  availability_zone = var.public_subnet_az

  tags = merge(var.tags, { Name = "${var.tags["Name"]}-public-subnet" })
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, { Name = "${var.tags["Name"]}-public-rt" })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr_block
  availability_zone = var.private_subnet_az

  tags = merge(var.tags, { Name = "${var.tags["Name"]}-private-subnet" })
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, { Name = "${var.tags["Name"]}-private-rt" })
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_subnet" "database_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidr_block
  availability_zone = var.database_subnet_az

  tags = merge(var.tags, { Name = "${var.tags["Name"]}-database-subnet" })
}

resource "aws_route_table" "database_route_table" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, { Name = "${var.tags["Name"]}-database-rt" })
}

resource "aws_route_table_association" "databse" {
  subnet_id      = aws_subnet.database_subnet.id
  route_table_id = aws_route_table.database_route_table.id
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(var.tags, { Name = "${var.tags["Name"]}-eip" })
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = merge(var.tags, { Name = "${var.tags["Name"]}-nat" })
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.gw.id
}

resource "aws_route" "database" {
  route_table_id         = aws_route_table.database_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.gw.id
}
