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
  default = "1.6.3"
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

variable "aws_amis" {
  description = "AMI IDs for Microsoft Windows Server 2016 Base with Containers"
  default = {
    us-east-1      = "ami-2dae053b"
    us-east-2      = "ami-9e2703fb"
    us-west-1      = "ami-8999c1e9"
    us-west-2      = "ami-95ed65f5"
    ca-central-1   = "ami-8f3588eb"
    eu-west-1      = "ami-2a8eb84c"
    eu-central-1   = "ami-fbb06694"
    eu-west-2      = "ami-6aa7b20e"
    ap-southeast-1 = "ami-c93183aa"
    ap-southeast-2 = "ami-f6828f95"
    ap-northeast-2 = "ami-c6cd1ea8"
    ap-northeast-1 = "ami-22a4f845"
    ap-south-1     = "ami-58e09037"
    sa-east-1      = "ami-7230501e"
  }
}