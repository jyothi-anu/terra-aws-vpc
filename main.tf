resource "aws_vpc" "main" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = merge(
    {
        Name = "${var.project}-${var.environment}"
        project = var.project
        environment = var.environment
        terraform = true
    },
    var.vpc_tags
  )
  
}