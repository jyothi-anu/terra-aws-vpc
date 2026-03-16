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
 final_public_route_table_tags = merge(
      local.common_tags,
      {
            Name = "${var.project}-${var.environment}-public"
      },
      var.public_route_table_tags
 )
 final_private_route_table_tags = merge(
      local.common_tags,
      {
            Name = "${var.project}-${var.environment}-private"
      },
      var.private_route_table_tags
 )
 final_database_route_table_tags = merge(
      local.common_tags,
      {
            Name = "${var.project}-${var.environment}-database"
      },
      var.database_route_table_tags
 )
 final_eip_tags = merge(
      {
            Name = "${var.project}-${var.environment}"
      },
      local.common_tags,
      var.eip_tags
 )
 final_nat_gateway_tags =merge(
      {
            Name = "${var.project}-${var.environment}"
      },
      local.common_tags,
      var.nat_gateway_tags
 )
}