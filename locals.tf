locals {
    common_tags = {
        Project = var.project
        Environment = var.environment
        Terraform = true
    }
    vpc_final_tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}"
    },
    var.vpc_tags
    )
    igw_final_tags = merge(
    local.common_tags,
    {
    Name = "${var.project}-${var.environment}"
    },
    var.igw_tags
    )
    az_names = slice(data.aws_availability_zones.available.names,0,2)
    public_route_table_final_tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-public"
    },
    var.public_route_table_tags
  )
  private_route_table_final_tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-private"
    },
    var.private_route_table_tags
  )
  database_route_table_final_tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-database"
    },
    var.database_route_table_tags
  )
  elastic_ip_final_tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-nat"
    },
    var.elastic_ip_tags
  )
  nat_gateway_final_tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}"
    },
    var.nat_gateway_tags
  )
}