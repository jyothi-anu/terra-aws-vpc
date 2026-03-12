locals {
  common_tags = {
    Name = "${var.project}-${var.environment}"
    project = var.project
    environment = var.environment
  }
  vpc_final_tags = merge(
    local.common_tags,
    var.vpc_tags
  )
  igw_final_tags = merge(
    local.common_tags,
    var.igw_tags
  )
    az_names= slice(data.aws_availability_zones.available.names,0,2)
}