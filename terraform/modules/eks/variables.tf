variable "name" {
  description = "Base name used for naming resources"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.34"
}

variable "vpc_id" {
  description = "VPC ID where EKS will be deployed"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "cluster_subnet_ids" {
  description = "Subnet IDs for EKS cluster ENIs. Usually all worker-related subnets or at least private subnets across AZs."
  type        = list(string)
}

variable "private_subnet_a" {
  description = "Private subnet ID for node group A"
  type        = string
}

variable "private_subnet_b" {
  description = "Private subnet ID for node group B"
  type        = string
}

variable "endpoint_private_access" {
  description = "Whether the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Whether the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "node_instance_type" {
  description = "EC2 instance type for managed node group"
  type        = string
  default     = "c7i-flex.large"
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 1
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 2
}

variable "tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}
