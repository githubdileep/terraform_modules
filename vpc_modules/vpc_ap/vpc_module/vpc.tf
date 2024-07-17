# Virtual Private Cloud (VPC) Configuration
resource "aws_vpc" "main" {
  cidr_block          = var.vpc_cidr_block
  instance_tenancy    = "default"
  enable_dns_support  = true
  enable_dns_hostnames = true

  tags = var.tags
}

# Internet Gateway for the VPC
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = var.tags
}

# Public Subnets within the VPC
resource "aws_subnet" "public_subnet" {
  count            = var.public_subnet_count
  vpc_id           = aws_vpc.main.id
  cidr_block       = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  availability_zone = var.public_subnet_az

  tags = merge(var.tags, { Name = "${var.tags["Name"]}-public-subnet-${count.index}" })
}

# Private Subnets within the VPC
resource "aws_subnet" "private_subnet" {
  count            = var.private_subnet_count
  vpc_id           = aws_vpc.main.id
  cidr_block       = cidrsubnet(var.vpc_cidr_block, 8, var.public_subnet_count + count.index)
  availability_zone = var.private_subnet_az

  tags = merge(var.tags, { Name = "${var.tags["Name"]}-private-subnet-${count.index}" })
}

# Database Subnets within the VPC
resource "aws_subnet" "database_subnet" {
  count            = var.database_subnet_count
  vpc_id           = aws_vpc.main.id
  cidr_block       = cidrsubnet(var.vpc_cidr_block, 8, var.public_subnet_count + var.private_subnet_count + count.index)
  availability_zone = var.database_subnet_az

  tags = merge(var.tags, { Name = "${var.tags["Name"]}-database-subnet-${count.index}" })
}

# Route Table for Public Subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.tags, { Name = "${var.tags["Name"]}-public-rt" })
}

# Route Table for Private Subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, { Name = "${var.tags["Name"]}-private-rt" })
}

# Route Table for Database Subnets
resource "aws_route_table" "database_route_table" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, { Name = "${var.tags["Name"]}-database-rt" })
}

# Association of Public Subnets with Public Route Table
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Association of Private Subnets with Private Route Table
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

# Association of Database Subnets with Database Route Table
resource "aws_route_table_association" "database" {
  count = length(aws_subnet.database_subnet)
  subnet_id      = aws_subnet.database_subnet[count.index].id
  route_table_id = aws_route_table.database_route_table.id
}

# Elastic IP (EIP) for NAT Gateway (if enabled)
resource "aws_eip" "nat" {
  count = var.create_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = merge(var.tags, { Name = "${var.tags["Name"]}-eip" })
}

# NAT Gateway for Private Subnets (if enabled)
resource "aws_nat_gateway" "gw" {
  count = var.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = merge(var.tags, { Name = "${var.tags["Name"]}-nat" })
}

# Route for Private Subnets to use NAT Gateway (if enabled)
resource "aws_route" "private" {
  count = var.create_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.gw[0].id
}

# Route for Database Subnets to use NAT Gateway (if enabled)
resource "aws_route" "database" {
  count = var.create_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.database_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.gw[0].id
}
