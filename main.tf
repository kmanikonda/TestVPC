data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "myvpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    "Name" = "Digital-Shared-VPC-Dev"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    "Name" = "Digital-Dev-igw"
  }
}

resource "aws_subnet" "public_subnets" {
  count             = var.subnet_count_per_network
  vpc_id            = aws_vpc.myvpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.shared_public_cidrblock, 2, count.index)

  tags = {
    "Name" = "shared-public-${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = var.subnet_count_per_network
  vpc_id            = aws_vpc.myvpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.shared_private_cidrblock, 2, count.index)

  tags = {
    "Name" = "shared-private-${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_subnet" "internal_subnets" {
  count             = var.subnet_count_per_network
  vpc_id            = aws_vpc.myvpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(var.shared_internal_cidrblock, 2, count.index)

  tags = {
    "Name" = "shared-internal-${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_route_table" "shared_private_rtbs" {
  count  = var.subnet_count_per_network
  vpc_id = aws_vpc.myvpc.id

  tags = {
    "Name" = "shared-private-rtb-${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_route_table" "shared_public_rtb" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    "Name" = "shared-public-rtb"
  }
}

resource "aws_route_table" "shared_internal_rtb" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    "Name" = "shared-public-rtb"
  }
}

resource "aws_eip" "elastic_ips" {
  count = var.subnet_count_per_network
  vpc   = true

  tags = {
    "Name" = "nat-eip-${count.index}"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = var.subnet_count_per_network
  allocation_id = aws_eip.elastic_ips[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = {
    "Name" = "ngw-${data.aws_availability_zones.available.names[count.index]}"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_route_table_association" "public_subnets_association" {
  count          = var.subnet_count_per_network
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.shared_public_rtb.id
}

resource "aws_route_table_association" "internal_subnets_association" {
  count          = var.subnet_count_per_network
  subnet_id      = aws_subnet.internal_subnets[count.index].id
  route_table_id = aws_route_table.shared_internal_rtb.id
}

resource "aws_route_table_association" "private_subnets_associations" {
  count          = var.subnet_count_per_network
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.shared_private_rtbs[count.index].id
}

#ROUTES
resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.shared_public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route" "private_ngw" {
  count                  = var.subnet_count_per_network
  route_table_id         = aws_route_table.shared_private_rtbs[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway[count.index].id
}
