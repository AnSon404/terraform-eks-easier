provider "aws" {
  region = "ap-east-1"
  access_key=var.aws_access_key_id
  secret_key=var.aws_secret_access_key
}
resource "aws_instance" "web" {
  ami="ami-0a3f016a475b150ec"
  instance_type="t3.micro"
  subnet_id="subnet-00bfa6059ac835a99"
  security_groups = [ "sg-02678b7e94fe2f255" ]
  tags={
    Name="anson-terraform"
  }
}

# data "aws_availability_zones" "available" {}

# locals {
#   name   = basename(path.cwd)
#   region = "us-west-2"

#   vpc_cidr = "10.0.0.0/16"
#   azs      = slice(data.aws_availability_zones.available.names, 0, 3)

#   tags = {
#     Blueprint  = local.name
#     GithubRepo = "github.com/aws-ia/terraform-aws-eks-blueprints"
#   }
# }

################################################################################
# Cluster
################################################################################

#tfsec:ignore:aws-eks-enable-control-plane-logging
# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "~> 19.9"

#   cluster_name    = local.name
#   cluster_version = "1.24"

#   # EKS Addons
#   cluster_addons = {
#     coredns    = {}
#     kube-proxy = {}
#     vpc-cni    = {}
#   }

#   vpc_id     = module.vpc.vpc_id
#   subnet_ids = module.vpc.private_subnets

#   eks_managed_node_groups = {
#     initial = {
#       instance_types = ["m5.large"]

#       min_size     = 2
#       max_size     = 5
#       desired_size = 2
#     }
#   }

#   tags = local.tags
# }

################################################################################
# Supporting Resources
################################################################################

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "~> 3.0"

#   name = local.name
#   cidr = local.vpc_cidr

#   azs             = local.azs
#   private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]

#   enable_nat_gateway   = false
#   single_nat_gateway   = true
#   enable_dns_hostnames = true

#   # Manage so we can name
#   manage_default_network_acl    = true
#   default_network_acl_tags      = { Name = "${local.name}-default" }
#   manage_default_route_table    = true
#   default_route_table_tags      = { Name = "${local.name}-default" }
#   manage_default_security_group = true
#   default_security_group_tags   = { Name = "${local.name}-default" }

#   private_subnet_tags = {
#     "kubernetes.io/role/internal-elb" = 1
#   }

#   tags = local.tags
# }

# module "vpc_endpoints_sg" {
#   source  = "terraform-aws-modules/security-group/aws"
#   version = "~> 4.0"

#   name        = "${local.name}-vpc-endpoints"
#   description = "Security group for VPC endpoint access"
#   vpc_id      = module.vpc.vpc_id

#   ingress_with_cidr_blocks = [
#     {
#       rule        = "https-443-tcp"
#       description = "VPC CIDR HTTPS"
#       cidr_blocks = join(",", module.vpc.private_subnets_cidr_blocks)
#     },
#   ]

#   egress_with_cidr_blocks = [
#     {
#       rule        = "https-443-tcp"
#       description = "All egress HTTPS"
#       cidr_blocks = "0.0.0.0/0"
#     },
#   ]

#   tags = local.tags
# }

# module "vpc_endpoints" {
#   source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
#   version = "~> 3.0"

#   vpc_id             = module.vpc.vpc_id
#   security_group_ids = [module.vpc_endpoints_sg.security_group_id]

#   endpoints = merge({
#     s3 = {
#       service         = "s3"
#       service_type    = "Gateway"
#       route_table_ids = module.vpc.private_route_table_ids
#       tags = {
#         Name = "${local.name}-s3"
#       }
#     }
#     },
#     { for service in toset(["autoscaling", "ecr.api", "ecr.dkr", "ec2", "ec2messages", "elasticloadbalancing", "sts", "kms", "logs", "ssm", "ssmmessages"]) :
#       replace(service, ".", "_") =>
#       {
#         service             = service
#         subnet_ids          = module.vpc.private_subnets
#         private_dns_enabled = true
#         tags                = { Name = "${local.name}-${service}" }
#       }
#   })

#   tags = local.tags
# }
