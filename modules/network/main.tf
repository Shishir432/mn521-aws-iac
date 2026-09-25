# ---------------------------------------------------------------------------
# Network module: VPC, 2 public + 2 private subnets across two AZs,
# Internet Gateway and route tables.
# ---------------------------------------------------------------------------

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  # Use the first two AZs in the region so the design survives an AZ outage.
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  # Map "a"/"b" -> { cidr, az } so resources are keyed by a stable name
  # (for_each) instead of a list index (count). Re-ordering will not
  # force subnets to be destroyed and recreated.
  public_subnets = {
    for idx, cidr in var.public_subnet_cidrs :
    element(["a", "b"], idx) => { cidr = cidr, az = local.azs[idx] }
  }
  private_subnets = {
    for idx, cidr in var.private_subnet_cidrs :
    element(["a", "b"], idx) => { cidr = cidr, az = local.azs[idx] }
  }
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.name_prefix}-vpc" }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = { Name = "${var.name_prefix}-igw" }
}

# ---------------------------- Subnets --------------------------------------

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name_prefix}-public-${each.key}"
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name_prefix}-private-${each.key}"
    Tier = "private"
  }
}

# -------------------------- Route tables -----------------------------------

# Public route table: default route to the Internet Gateway.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = { Name = "${var.name_prefix}-public-rt" }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private route table: only the implicit local VPC route, so instances in
# the private subnets are unreachable from, and cannot reach, the internet.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = { Name = "${var.name_prefix}-private-rt" }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
