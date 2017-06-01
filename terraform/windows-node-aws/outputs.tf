# AWS K8s Windows Node Outputs
output "Windows Node Hostname" {
    value = "${aws_instance.aws-k8s-win-host-01.private_dns}"
}