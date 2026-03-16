resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = local.vpc_final_tags 
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id #attach vpc to internet gateway

  tags = local.igw_final_tags
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  count = length(var.public_subnet_cidr)
  cidr_block = var.public_subnet_cidr[count.index]
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      #roboshop-dev-public-us-east-1a/1b
       Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}"
    },
    var.public_subnet_tags
  )
}

resource "aws_subnet" "private" {
  vpc_id                 = aws_vpc.main.id
  count                  = length(var.private_subnet_cidr)
  cidr_block             = var.private_subnet_cidr[count.index]
  availability_zone      = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      #roboshop-dev-private-us-east-1a/1b
        Name = "${var.project}-${var.environment}-private-${local.az_names[count.index]}"
    },
    var.private_subnet_tags
  )
}
resource "aws_subnet" "database" {
  vpc_id                 = aws_vpc.main.id
  count                  = length(var.database_subnet_cidr)
  cidr_block             = var.database_subnet_cidr[count.index]
  availability_zone      = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      #roboshop-dev-database-us-east-1a/1b
        Name = "${var.project}-${var.environment}-database-${local.az_names[count.index]}"
    },
    var.database_subnet_tags
  )
}
#create route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = final_public_route_tables_tags
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = final_private_route_tables_tags
}
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = final_database_route_tables_tags
}
#create route for public
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.main.id
}
#allocate eip
resource "aws_eip" "nat" {
  domain   = "vpc"

  tags = local.final_eip_tags
}
#create nat gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = local.final_nat_gateway_tags

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_nat_gateway.main.id
}
resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_nat_gateway.main.id
}
#route association
resource "aws_route_table_association" "public" {
  count         = length(var.public_subnet_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  count         = length(var.private_subnet_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "database" {
  count         = length(var.database_subnet_cidr)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}


