# terraform-aws-vpc

A Terraform module to provision a production-ready **AWS VPC** with public, private, and database subnets, NAT Gateway, Internet Gateway, route tables, and optional VPC Peering with the default VPC.

---

## 📐 Architecture Overview

```
                          ┌─────────────────────────────────────────┐
                          │               AWS VPC (Custom)           │
                          │                                          │
                          │  ┌────────────┐    ┌────────────┐       │
                          │  │ Public Sub │    │ Public Sub │       │
                          │  │  (AZ-1)   │    │  (AZ-2)   │       │
                          │  └─────┬──────┘    └────────────┘       │
                          │        │ NAT GW + EIP                    │
                          │  ┌─────▼──────┐    ┌────────────┐       │
                          │  │Private Sub │    │Private Sub │       │
                          │  │  (AZ-1)   │    │  (AZ-2)   │       │
                          │  └────────────┘    └────────────┘       │
                          │  ┌────────────┐    ┌────────────┐       │
                          │  │Database Sub│    │Database Sub│       │
                          │  │  (AZ-1)   │    │  (AZ-2)   │       │
                          │  └────────────┘    └────────────┘       │
                          └──────────────────┬──────────────────────┘
                                             │ (Optional VPC Peering)
                                    ┌────────▼────────┐
                                    │  Default VPC     │
                                    └─────────────────┘
```

---

## ✅ Resources Created

| Resource | Description |
|---|---|
| `aws_vpc` | Main VPC with DNS hostnames enabled |
| `aws_internet_gateway` | Internet Gateway attached to the VPC |
| `aws_subnet` (public) | Public subnets — one per AZ, auto-assign public IP |
| `aws_subnet` (private) | Private subnets — one per AZ |
| `aws_subnet` (database) | Database subnets — one per AZ |
| `aws_route_table` (public/private/database) | Separate route tables for each subnet type |
| `aws_route` (public) | Routes public traffic `0.0.0.0/0` → Internet Gateway |
| `aws_route` (private/database) | Routes outbound traffic `0.0.0.0/0` → NAT Gateway |
| `aws_eip` | Elastic IP for NAT Gateway |
| `aws_nat_gateway` | NAT Gateway placed in first public subnet |
| `aws_route_table_association` | Associates subnets with their route tables |
| `aws_vpc_peering_connection` | (Optional) Peers custom VPC with default VPC |
| `aws_route` (peering) | (Optional) Routes for peering across all 3 route tables + default VPC |

---

## 📦 Usage

```hcl
module "vpc" {
  source = "github.com/manojkumar-tech267/terraform-aws-vpc.git"

  project     = "myapp"
  environment = "dev"

  vpc_cidr               = "10.0.0.0/16"
  public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs   = ["10.0.11.0/24", "10.0.12.0/24"]
  database_subnet_cidrs  = ["10.0.21.0/24", "10.0.22.0/24"]

  is_peering_required = false
}
```

### With VPC Peering Enabled

```hcl
module "vpc" {
  source = "github.com/manojkumar-tech267/terraform-aws-vpc.git"

  project     = "myapp"
  environment = "prod"

  vpc_cidr               = "10.0.0.0/16"
  public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs   = ["10.0.11.0/24", "10.0.12.0/24"]
  database_subnet_cidrs  = ["10.0.21.0/24", "10.0.22.0/24"]

  is_peering_required = true

  vpc_peering_tags = {
    Purpose = "default-vpc-access"
  }
}
```

---

## 📥 Input Variables

| Variable | Type | Default | Required | Description |
|---|---|---|---|---|
| `project` | `string` | — | ✅ Yes | Project name used for resource naming and tagging |
| `environment` | `string` | — | ✅ Yes | Environment name (e.g. `dev`, `prod`) |
| `vpc_cidr` | `string` | `"10.0.0.0/16"` | No | CIDR block for the VPC |
| `public_subnet_cidrs` | `list(string)` | `["10.0.1.0/24","10.0.2.0/24"]` | No | CIDR blocks for public subnets |
| `private_subnet_cidrs` | `list(string)` | `["10.0.11.0/24","10.0.12.0/24"]` | No | CIDR blocks for private subnets |
| `database_subnet_cidrs` | `list(string)` | `["10.0.21.0/24","10.0.22.0/24"]` | No | CIDR blocks for database subnets |
| `is_peering_required` | `bool` | `false` | No | If `true`, creates VPC peering with default VPC |
| `vpc_tags` | `map` | `{}` | No | Additional tags for the VPC |
| `igw_tags` | `map` | `{}` | No | Additional tags for the Internet Gateway |
| `public_subnet_tags` | `map` | `{}` | No | Additional tags for public subnets |
| `private_subnet_tags` | `map` | `{}` | No | Additional tags for private subnets |
| `database_subnet_tags` | `map` | `{}` | No | Additional tags for database subnets |
| `public_route_table_tags` | `map` | `{}` | No | Additional tags for the public route table |
| `private_route_table_tags` | `map` | `{}` | No | Additional tags for the private route table |
| `database_route_table_tags` | `map` | `{}` | No | Additional tags for the database route table |
| `elastic_ip_tags` | `map` | `{}` | No | Additional tags for the NAT Gateway Elastic IP |
| `nat_gateway_tags` | `map` | `{}` | No | Additional tags for the NAT Gateway |
| `vpc_peering_tags` | `map` | `{}` | No | Additional tags for the VPC Peering connection |

---

## 📤 Outputs

> ℹ️ The `outputs.tf` file is currently empty. You can add the following useful outputs:

```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "database_subnet_ids" {
  value = aws_subnet.database[*].id
}

output "nat_gateway_id" {
  value = aws_nat_gateway.main.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.main.id
}
```

---

## 🏷️ Tagging Strategy

Every resource in this module is automatically tagged with the following common tags:

```hcl
{
  Project     = var.project
  Environment = var.environment
  Terraform   = true
}
```

Each resource also gets a `Name` tag following the convention:

| Resource | Name Tag Pattern |
|---|---|
| VPC | `{project}-{environment}` |
| Internet Gateway | `{project}-{environment}` |
| Public Subnet | `{project}-{environment}-public-{az}` |
| Private Subnet | `{project}-{environment}-private-{az}` |
| Database Subnet | `{project}-{environment}-database-{az}` |
| Public Route Table | `{project}-{environment}-public` |
| Private Route Table | `{project}-{environment}-private` |
| Database Route Table | `{project}-{environment}-database` |
| Elastic IP | `{project}-{environment}-nat` |
| NAT Gateway | `{project}-{environment}` |
| VPC Peering | `{project}-{environment}-default` |

Additional custom tags can be passed per resource using the `*_tags` variables.

---

## 🔗 VPC Peering (Optional)

When `is_peering_required = true`, this module:

- Fetches the **default VPC** and its main route table using data sources
- Creates a **VPC Peering Connection** between the custom VPC and the default VPC (auto-accepted)
- Enables **DNS resolution** on both sides (`accepter` and `requester`)
- Adds peering routes in **all 4 route tables**: public, private, database, and default VPC

> ⚠️ This peering only works within the **same AWS account and region**.

---

## 🌐 Availability Zones

This module uses the `aws_availability_zones` data source to automatically discover available AZs in the region. It picks the **first 2 AZs** using:

```hcl
az_names = slice(data.aws_availability_zones.available.names, 0, 2)
```

Subnets are distributed across these 2 AZs based on the index of the CIDR list.

---

## 📋 Requirements

| Tool | Minimum Version |
|---|---|
| Terraform | `>= 1.0` |
| AWS Provider | `>= 4.0` |

---

## 📁 Module File Structure

```
terraform-aws-vpc/
├── main.tf        # Core resources: VPC, subnets, IGW, NAT, routes
├── variables.tf   # All input variable definitions
├── outputs.tf     # Output values (currently empty)
├── locals.tf      # Tag merging logic and AZ selection
├── data.tf        # Data sources: AZs, default VPC, default route table
└── peering.tf     # Optional VPC peering with default VPC
```

---

## 👤 Author

**Manoj Kumar**
GitHub: [manojkumar-tech267](https://github.com/manojkumar-tech267)