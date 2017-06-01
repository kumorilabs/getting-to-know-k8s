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

# Template file for User Data
data "template_file" "init" {
    template = "${file("init.tpl")}"

    vars {
      windows_admin_password = "${var.windows_admin_password}"
    }
}


# Create Instance for Windows Node 01
resource "aws_instance" "aws-k8s-win-host-01" {
  instance_type               = "${var.aws_instance_size}"
  ami                         = "${lookup(var.aws_amis, var.aws_region)}"
  key_name                    = "${var.k8s_keypair_name}"
  vpc_security_group_ids      = ["${var.k8s_nodes_sg_id}"]
  subnet_id                   = "${var.k8s_subnet_id}"
  iam_instance_profile        = "nodes.${var.k8s_cluster_name}"
  associate_public_ip_address = true
  source_dest_check           = false
  user_data                   = "${data.template_file.init.rendered}"
  tags {
      Name                    = "nodes.${var.k8s_cluster_name}"
      KubernetesCluster       = "${var.k8s_cluster_name}"
      "k8s.io/role/node"      = "1"
  }
  root_block_device {
    volume_size               = 60
    delete_on_termination     = true
  }
}

# Add Additional NIC to Windows Node 01
resource "aws_network_interface" "aws-k8s-win-host-01-nic2" {
  description       = "win-host-01"
  subnet_id         = "${var.k8s_subnet_id}"
  security_groups   = ["${var.k8s_nodes_sg_id}"]
  source_dest_check = false

  attachment {
    instance        = "${aws_instance.aws-k8s-win-host-01.id}"
    device_index    = 1
  }
}

# Provision Windows Node 01
resource "null_resource" "aws-k8s-win-host-01-provisioning" {
  depends_on = ["aws_instance.aws-k8s-win-host-01"]
  connection {
    type     = "winrm"
    user     = "administrator"
    password = "${var.windows_admin_password}"
    host     = "${aws_instance.aws-k8s-win-host-01.public_ip}"
    port     = "5985"
    timeout  = "20m"
  }
  provisioner "file" {
    source      = "~/.kube/config"
    destination = "c:/k8s/config"
  }
  provisioner "file" {
    source      = "files"
    destination = "c:/k8s"
  }  
  provisioner "remote-exec" {
    inline = [
    "powershell.exe -ExecutionPolicy Unrestricted -File C:/k8s/provision-k8s-windows.ps1 -AWSHostname ${aws_instance.aws-k8s-win-host-01.private_dns} -AWSHostPrivateIP ${aws_instance.aws-k8s-win-host-01.private_ip} -KubeDnsServiceIp ${var.k8s_kube_dns_ip} -NonMasqCIDR ${var.k8s_non_masq_cidr} -K8sVersion ${var.k8s_version}"
    ]
  }
}

# Post Deployment Tasks
resource "null_resource" "local-post-deployment-tasks-01" {
  depends_on = ["null_resource.aws-k8s-win-host-01-provisioning"]
  provisioner "local-exec" {
    command = "kubectl delete limitrange limits"
  }
  provisioner "local-exec" {
    command = <<EOF
    export K8S_WIN_NODE_POD_CIDR=$(kubectl get nodes ${aws_instance.aws-k8s-win-host-01.private_dns} -o custom-columns=podCidr:.spec.podCIDR --no-headers) &&
    export K8S_ROUTE_TABLE_ID=$(aws ec2 describe-route-tables --region $${CLUSTER_AWS_REGION} --filters Name=tag-value,Values=$${CLUSTER_FULL_NAME} | jq --raw-output '.RouteTables[0] .RouteTableId') &&
    aws ec2 create-route --region $${CLUSTER_AWS_REGION} --route-table-id $${K8S_ROUTE_TABLE_ID} --destination-cidr-block $${K8S_WIN_NODE_POD_CIDR} --network-interface-id ${aws_instance.aws-k8s-win-host-01.network_interface_id}
EOF
  }
}