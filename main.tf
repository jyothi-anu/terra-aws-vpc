resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = local.vpc_final_tags 
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id #attach vpc to internet gateway

  tags = local.igw_final_tags
}

/* resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  count = length(var.cidr_subnet_block)
  cidr_block = var.cidr_subnet_block[count.index]
  availability_zone = 

  tags = {
    Name = "Main"
  }
} */
