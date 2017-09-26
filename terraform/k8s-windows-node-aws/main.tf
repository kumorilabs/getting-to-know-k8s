# AWS K8s Windows Node
# Main Configuration File

# Specify AWS as the provider and the AWS region
provider "aws" {
  region = "${var.aws_region}"
}

# Add RDP & WinRM (HTTP) rules to existing K8s nodes security group
resource "aws_security_group_rule" "allow-RDP" {
  type        = "ingress"
  from_port   = 3389
  to_port     = 3389
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${var.k8s_nodes_sg_id}"
}

resource "aws_security_group_rule" "allow-WinRM" {
  type        = "ingress"
  from_port   = 5985
  to_port     = 5985
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${var.k8s_nodes_sg_id}"
}

# Create Instance(s) for Windows Node(s)
module "aws-k8s-win-host" {
  source                 = "./modules"
  aws_region             = "${var.aws_region}"
  aws_instance_size      = "${var.aws_instance_size}"
  windows_admin_password = "${var.windows_admin_password}"
  k8s_version            = "${var.k8s_version}"
  k8s_instance_count     = "${var.k8s_instance_count}"
  k8s_kube_dns_ip        = "${var.k8s_kube_dns_ip}" 
  k8s_non_masq_cidr      = "${var.k8s_non_masq_cidr}"
  k8s_cluster_name       = "${var.k8s_cluster_name}" 
  k8s_keypair_name       = "${var.k8s_keypair_name}"
  k8s_nodes_sg_id        = "${var.k8s_nodes_sg_id}" 
  k8s_subnet_id          = "${var.k8s_subnet_id}" 
}

# Post Deployment Tasks
resource "null_resource" "local-post-deployment-tasks" {
  depends_on = ["module.aws-k8s-win-host"]
  provisioner "local-exec" {
    command = "kubectl delete limitrange limits"
  }
}