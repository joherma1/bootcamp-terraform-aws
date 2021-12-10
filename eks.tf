module "eks" {
  source                 = "terraform-aws-modules/eks/aws"
  version                = "17.24.0"
  cluster_name           = var.cluster_name
  cluster_version        = "1.21"
  subnets                = module.vpc.private_subnets
  write_kubeconfig       = false
  worker_ami_name_filter = "amazon-eks-node-1.21-v20210830"
  # IRSA (IAM Roles for Service Accounts) allow for Kubernetes ServiceAccounts
  #   to be mapped to AWS IAM Roles through Kubernetes standard annotations,
  #   in a similar fashion to GCP's Workload Identity Management
  enable_irsa = true

  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      name = "worker-group-1"
      # burstable
      instance_type                 = "t3.medium"
      asg_desired_capacity          = 3
      asg_max_size                  = 6
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
  ]

  # Policies attached to all the instance, empty will block any user to access
  map_roles = []
  map_users = [{
    userarn  = "arn:aws:iam::268229342313:user/joherma1@gmail.com"
    username = "joherma1@gmail.com"
    groups   = ["system:masters"]
  }]
  map_accounts = []
}

# We need to initialize the K8s provider to modify parameters using the API
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Additional security groups for workers
resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  description = "Allow Incoming SSH from inside of the VPC"
  vpc_id      = module.vpc.vpc_id

  # Allow ingress traffic in the VPC to port 22 sources from 0.16.0.0 (subnet)
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/16",
    ]
  }
}
