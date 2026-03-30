resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name = "${var.name}-vpc"
    },
    var.tags
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.name}-igw"
    },
    var.tags
  )
}

# -------------------------
# Public subnets
# -------------------------
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[0]
  availability_zone       = var.azs[0]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name                     = "${var.name}-public-${var.azs[0]}"
      "kubernetes.io/role/elb" = "1"
    },
    var.cluster_name != "" ? {
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    } : {},
    var.tags
  )
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[1]
  availability_zone       = var.azs[1]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name                     = "${var.name}-public-${var.azs[1]}"
      "kubernetes.io/role/elb" = "1"
    },
    var.cluster_name != "" ? {
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    } : {},
    var.tags
  )
}

# -------------------------
# Private subnets
# -------------------------
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_subnet_cidrs[0]
  availability_zone       = var.azs[0]
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name                              = "${var.name}-private-${var.azs[0]}"
      "kubernetes.io/role/internal-elb" = "1"
    },
    var.cluster_name != "" ? {
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    } : {},
    var.tags
  )
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_subnet_cidrs[1]
  availability_zone       = var.azs[1]
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name                              = "${var.name}-private-${var.azs[1]}"
      "kubernetes.io/role/internal-elb" = "1"
    },
    var.cluster_name != "" ? {
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    } : {},
    var.tags
  )
}

# -------------------------
# Elastic IPs for NAT Gateways
# -------------------------
resource "aws_eip" "nat_a" {
  domain = "vpc"

  tags = merge(
    {
      Name = "${var.name}-nat-eip-${var.azs[0]}"
    },
    var.tags
  )
}

resource "aws_eip" "nat_b" {
  domain = "vpc"

  tags = merge(
    {
      Name = "${var.name}-nat-eip-${var.azs[1]}"
    },
    var.tags
  )
}

# -------------------------
# NAT Gateways
# Each NAT goes into a public subnet
# -------------------------
resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_a.id

  depends_on = [aws_internet_gateway.this]

  tags = merge(
    {
      Name = "${var.name}-nat-${var.azs[0]}"
    },
    var.tags
  )
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.public_b.id

  depends_on = [aws_internet_gateway.this]

  tags = merge(
    {
      Name = "${var.name}-nat-${var.azs[1]}"
    },
    var.tags
  )
}

# -------------------------
# Public route table
# -------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.name}-public-rt"
    },
    var.tags
  )
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# -------------------------
# Private route tables
# One per private subnet / AZ
# -------------------------
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.name}-private-rt-${var.azs[0]}"
    },
    var.tags
  )
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.name}-private-rt-${var.azs[1]}"
    },
    var.tags
  )
}

resource "aws_route" "private_a_internet" {
  route_table_id         = aws_route_table.private_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_a.id
}

resource "aws_route" "private_b_internet" {
  route_table_id         = aws_route_table.private_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_b.id
}

# -------------------------
# Associations
# -------------------------
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}
