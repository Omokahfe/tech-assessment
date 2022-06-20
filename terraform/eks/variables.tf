variable "region" {
  default     = "eu-west-1"
  description = "AWS region"
}

variable "cluster_name" {
  default     = "abn"
  description = "EKS Cluster name"
}

variable "cluster_version" {
  type        = string
  default     = "1.21"
  description = "Kubernetes version"
}

variable "instance_type" {
  type        = string
  description = "EKS node instance type"
}

variable "asg_min_size" {
  type        = number
  description = "EKS node count"
}

variable "asg_max_size" {
  type        = number
  description = "EKS node count"
}

variable "asg_desired_capacity" {
  type        = number
  description = "EKS node desired capacity"
}
