module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.11.0"

  name            = "${var.cluster_name}-eks-vpc"
  cidr            = "10.0.0.0/16"
  azs             = ["eu-west-3a", "eu-west-3b", "eu-west-3c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  # Scenario Single NAT Gateway for all (could be per subnet or per AZ)
  enable_nat_gateway = true
  single_nat_gateway = true # Only 1 NAT for all subnets
  # 1 EIP, 1 NAT Gateway and 1 Internet Gateway in us-west-2a for all vpc resources (routes)
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = false # We don't need DNS entries for the VPC hostnames

  tags = {
    Bloque    = "HerramientasOrquestacion"
    Terraform = "true"
    Usuario   = "joherma1"
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}
