# AWS K8s Windows Node Variables
variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "aws_instance_size" {
  description = "AWS Instance Size for Windows Node"
  default     = "t2.medium"
}

variable "windows_admin_password" {
  description = "Password for Windows Administrator User"
  default = "Password12All4help!"
}

variable "k8s_version" {
  description = "K8s Version"
  default     = "1.7.6"
}

variable "k8s_instance_count" {
  description = "K8s Number of Instances"
  default     = "2"
}

variable "k8s_kube_dns_ip" {
  description = "K8s KubeDNS IP"
}

variable "k8s_non_masq_cidr" {
  description = "K8s Non-Masquerade CIDR"
}

variable "k8s_cluster_name" {
  description = "K8s Cluster Name"
}

variable "k8s_keypair_name" {
  description = "K8s Keypair Name"
}

variable "k8s_nodes_sg_id" {
  description = "K8s Nodes Security Group ID"
}

variable "k8s_subnet_id" {
  description = "K8s Subnet ID"
}