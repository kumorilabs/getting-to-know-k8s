# Specify AWS as the provider and the AWS region
# provider "aws" {
#   region = "${var.aws_region}"
# }

# Template file for User Data
data "template_file" "init" {
    template = "${file("init.tpl")}"

    vars {
      windows_admin_password = "${var.windows_admin_password}"
    }
}

data "aws_ami" "windows_server_2016_containers" {
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["Windows_Server-2016-English-Full-Containers*"]
  }

  most_recent = true
}

# Create Instance for Windows Node
resource "aws_instance" "aws-k8s-win-host" {
  instance_type               = "${var.aws_instance_size}"
  ami                         = "${data.aws_ami.windows_server_2016_containers.id}" // "${lookup(var.aws_amis, var.aws_region)}"
  key_name                    = "${var.k8s_keypair_name}"
  vpc_security_group_ids      = ["${var.k8s_nodes_sg_id}"]
  subnet_id                   = "${var.k8s_subnet_id}"
  iam_instance_profile        = "nodes.${var.k8s_cluster_name}"
  associate_public_ip_address = true
  source_dest_check           = false
  user_data                   = "${data.template_file.init.rendered}"
  count                       = "${var.k8s_instance_count}"
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

# Add NIC 2 to Windows Node
resource "aws_network_interface" "aws-k8s-win-host-nic2" {
  depends_on        = ["aws_instance.aws-k8s-win-host"]
  description       = "aws-k8s-win-host-nic2-docker"
  count             = "${var.k8s_instance_count}"
  subnet_id         = "${var.k8s_subnet_id}"
  security_groups   = ["${var.k8s_nodes_sg_id}"]
  source_dest_check = false

  attachment {
    instance        = "${element(aws_instance.aws-k8s-win-host.*.id, count.index)}"
    device_index    = 1
  }
}

# Add NIC 3 to Windows Node
resource "aws_network_interface" "aws-k8s-win-host-nic3" {
  depends_on        = ["aws_network_interface.aws-k8s-win-host-nic2"]
  description       = "aws-k8s-win-host-nic3-internal"
  count             = "${var.k8s_instance_count}"
  subnet_id         = "${var.k8s_subnet_id}"
  security_groups   = ["${var.k8s_nodes_sg_id}"]
  source_dest_check = false

  attachment {
    instance        = "${element(aws_instance.aws-k8s-win-host.*.id, count.index)}"
    device_index    = 2
  }
}

# Provision Windows Node(s)
resource "null_resource" "aws-k8s-win-host-provisioning" {
  depends_on = ["aws_instance.aws-k8s-win-host"]
  count      = "${var.k8s_instance_count}"
  connection {
    type     = "winrm"
    user     = "administrator"
    password = "${var.windows_admin_password}"
    host     = "${element(aws_instance.aws-k8s-win-host.*.public_ip, count.index)}"
    port     = "5985"
    timeout  = "20m"
  }
  provisioner "file" {
    source      = "~/.kube/config"
    destination = "c:/k8s/config"
  }
  provisioner "file" {
    source      = "provision"
    destination = "c:/k8s"
  }  
  provisioner "remote-exec" {
    inline = [
    "powershell.exe -ExecutionPolicy Unrestricted -File C:/k8s/provision-k8s-windows.ps1 -AWSHostname ${element(aws_instance.aws-k8s-win-host.*.private_dns, count.index)} -AWSK8sWinHostNic1 ${element(aws_instance.aws-k8s-win-host.*.private_ip, count.index)} -AWSK8sWinHostNic2 ${element(aws_network_interface.aws-k8s-win-host-nic2.*.private_ip, count.index)} -AWSK8sWinHostNic3 ${element(aws_network_interface.aws-k8s-win-host-nic3.*.private_ip, count.index)} -KubeDnsServiceIp ${var.k8s_kube_dns_ip} -NonMasqCIDR ${var.k8s_non_masq_cidr} -K8sVersion ${var.k8s_version}"
    ]
  }
}

# # Enable NAT on Windows Node(s)
# resource "null_resource" "aws-k8s-win-host-nat" {
#   depends_on = ["aws_instance.aws-k8s-win-host"]
#   count      = "${var.k8s_instance_count}"
#   connection {
#     type     = "winrm"
#     user     = "administrator"
#     password = "${var.windows_admin_password}"
#     host     = "${element(aws_instance.aws-k8s-win-host.*.public_ip, count.index)}"
#     port     = "5985"
#     timeout  = "20m"
#   }
#   provisioner "file" {
#     source      = "nat"
#     destination = "c:/k8s"
#   }  
#   provisioner "remote-exec" {
#     inline = [
#     "powershell.exe -ExecutionPolicy Unrestricted -File C:/k8s/enable-rras-nat.ps1"
#     ]
#   }
# }

# Post Deployment Tasks
resource "null_resource" "local-post-deployment-tasks" {
  depends_on = ["null_resource.aws-k8s-win-host-provisioning"]
  count      = "${var.k8s_instance_count}"
  provisioner "local-exec" {
    command = <<EOF
    export K8S_WIN_NODE_POD_CIDR=$(kubectl get nodes ${element(aws_instance.aws-k8s-win-host.*.private_dns, count.index)} -o custom-columns=podCidr:.spec.podCIDR --no-headers) &&
    export K8S_ROUTE_TABLE_ID=$(aws ec2 describe-route-tables --region $${CLUSTER_AWS_REGION} --filters Name=tag-value,Values=$${CLUSTER_FULL_NAME} | jq --raw-output '.RouteTables[0] .RouteTableId') &&
    aws ec2 create-route --region $${CLUSTER_AWS_REGION} --route-table-id $${K8S_ROUTE_TABLE_ID} --destination-cidr-block $${K8S_WIN_NODE_POD_CIDR} --network-interface-id ${element(aws_network_interface.aws-k8s-win-host-nic3.*.id, count.index)}
EOF
  }
}