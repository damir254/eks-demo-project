output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.this.arn
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "Security group ID used by the EKS cluster"
  value       = aws_security_group.cluster.id
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN for EKS cluster"
  value       = aws_iam_role.cluster.arn
}

output "node_group_iam_role_arn" {
  description = "IAM role ARN for managed node group"
  value       = aws_iam_role.node_group.arn
}

output "node_group_a_name" {
  description = "Managed node group A name"
  value       = aws_eks_node_group.node_a.node_group_name
}

output "node_group_b_name" {
  description = "Managed node group B name"
  value       = aws_eks_node_group.node_b.node_group_name
}
