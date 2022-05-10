resource "aws_network_acl" "shared_public_nacl" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    "Name" = "shared-public-nacl"
  }
}

resource "aws_network_acl" "shared_private_nacl" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    "Name" = "shared-private-nacl"
  }
}

resource "aws_network_acl" "shared_internal_nacl" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    "Name" = "shared-internal-nacl"
  }
}

resource "aws_network_acl_association" "public_nacl_association" {
  count          = var.subnet_count_per_network
  network_acl_id = aws_network_acl.shared_public_nacl.id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}

resource "aws_network_acl_association" "private_nacl_association" {
  count          = var.subnet_count_per_network
  network_acl_id = aws_network_acl.shared_private_nacl.id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}

resource "aws_network_acl_association" "internal_nacl_association" {
  count          = var.subnet_count_per_network
  network_acl_id = aws_network_acl.shared_internal_nacl.id
  subnet_id      = aws_subnet.internal_subnets[count.index].id
}