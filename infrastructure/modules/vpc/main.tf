# Define the main VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Define the Internet Gateway for public traffic
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Create a public and private subnet for each availability zone
resource "aws_subnet" "public" {
  for_each          = toset(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  availability_zone = each.value
  cidr_block        = "10.0.${index(var.availability_zones, each.value) * 2}.0/24" # e.g., 10.0.0.0/24, 10.0.2.0/24

  tags = {
    Name = "${var.project_name}-public-subnet-${each.value}"
  }
}

resource "aws_subnet" "private" {
  for_each          = toset(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  availability_zone = each.value
  cidr_block        = "10.0.${index(var.availability_zones, each.value) * 2 + 1}.0/24" # e.g., 10.0.1.0/24, 10.0.3.0/24

  tags = {
    Name = "${var.project_name}-private-subnet-${each.value}"
  }
}

# Create an Elastic IP for each NAT Gateway
resource "aws_eip" "nat" {
  for_each = toset(var.availability_zones)
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-eip-nat-${each.value}"
  }
}

# Create a NAT Gateway in each public subnet
resource "aws_nat_gateway" "main" {
  for_each      = toset(var.availability_zones)
  allocation_id = aws_eip.nat[each.value].id
  subnet_id     = aws_subnet.public[each.value].id

  tags = {
    Name = "${var.project_name}-nat-${each.value}"
  }
  depends_on = [aws_internet_gateway.main]
}

# Define and associate the Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = toset(var.availability_zones)
  subnet_id      = aws_subnet.public[each.value].id
  route_table_id = aws_route_table.public.id
}

# Define and associate the Private Route Tables (one per AZ)
resource "aws_route_table" "private" {
  for_each = toset(var.availability_zones)
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[each.value].id
  }

  tags = {
    Name = "${var.project_name}-private-rt-${each.value}"
  }
}

resource "aws_route_table_association" "private" {
  for_each       = toset(var.availability_zones)
  subnet_id      = aws_subnet.private[each.value].id
  route_table_id = aws_route_table.private[each.value].id
}