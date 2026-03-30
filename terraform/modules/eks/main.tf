# -----------------------------------
# IAM role for EKS control plane
# -----------------------------------
resource "aws_iam_role" "cluster" {
  name = "${var.name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    {
      Name = "${var.name}-eks-cluster-role"
    },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "cluster_amazon_eks_cluster_policy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# -----------------------------------
# IAM role for managed node group
# -----------------------------------
resource "aws_iam_role" "node_group" {
  name = "${var.name}-eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    {
      Name = "${var.name}-eks-node-group-role"
    },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "node_amazon_eks_worker_node_policy" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_amazon_ec2_container_registry_pull_only" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

resource "aws_iam_role_policy_attachment" "node_amazon_eks_cni_policy" {
  role       = aws_iam_role.node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# -----------------------------------
# Security group for EKS cluster
# -----------------------------------
resource "aws_security_group" "cluster" {
  name        = "${var.name}-eks-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    {
      Name = "${var.name}-eks-cluster-sg"
    },
    var.tags
  )
}

# Allow worker nodes to communicate with control plane on 443
resource "aws_security_group_rule" "cluster_ingress_https_from_vpc" {
  type              = "ingress"
  description       = "Allow Kubernetes API access from within VPC"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.cluster.id
}

# -----------------------------------
# EKS Cluster
# -----------------------------------
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.cluster_subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    security_group_ids      = [aws_security_group.cluster.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_amazon_eks_cluster_policy
  ]

  tags = merge(
    {
      Name = var.cluster_name
    },
    var.tags
  )
}

# -----------------------------------
# Managed Node Group
# Uses private subnets
# -----------------------------------

resource "aws_eks_node_group" "node_a" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.name}-managed-ng-a"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = [var.private_subnet_a]

  instance_types = [var.node_instance_type]
  capacity_type  = "ON_DEMAND"

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.node_amazon_ec2_container_registry_pull_only,
    aws_iam_role_policy_attachment.node_amazon_eks_cni_policy,
    aws_eks_cluster.this
  ]

  tags = merge(
    {
      Name = "${var.name}-managed-ng-a"
    },
    var.tags
  )
}

resource "aws_eks_node_group" "node_b" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.name}-managed-ng-b"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = [var.private_subnet_b]

  instance_types = [var.node_instance_type]
  capacity_type  = "ON_DEMAND"

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.node_amazon_ec2_container_registry_pull_only,
    aws_iam_role_policy_attachment.node_amazon_eks_cni_policy,
    aws_eks_cluster.this
  ]

  tags = merge(
    {
      Name = "${var.name}-managed-ng-b"
    },
    var.tags
  )
}
