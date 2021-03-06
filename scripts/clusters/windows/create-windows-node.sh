# Load variables from variables.sh script
source ./scripts/variables.sh

# Set KOPS_STATE_STORE to S3 bucket name (leave as-is)
export KOPS_STATE_STORE="s3://${CLUSTER_FULL_NAME}-state"

# Check if the Linux node(s) are running
export AWS_AVAILABLE_NODE=$(aws ec2 describe-instances --region ${CLUSTER_AWS_REGION} --filters "Name=instance-state-name,Values=running" "Name=tag-value,Values=nodes.${CLUSTER_FULL_NAME}" | jq .Reservations[].Instances[].PrivateDnsName)

if [ -z $AWS_AVAILABLE_NODE ]; then echo "Waiting for Linux node(s) to be available" && sleep 60; fi 

# Set Terraform variables
echo "Setting Terraform variables"
export TF_VAR_k8s_kube_dns_ip=$(kops get clusters --full -o json | jq --raw-output .spec.kubeDNS.serverIP) && echo "K8s KubeDNS IP: ${TF_VAR_k8s_kube_dns_ip}"
export TF_VAR_k8s_non_masq_cidr=$(kops get clusters --full -o json | jq --raw-output .spec.nonMasqueradeCIDR) && echo "K8s Non-Masquerade CIDR: ${TF_VAR_k8s_non_masq_cidr}"
export TF_VAR_k8s_cluster_name=$(echo $CLUSTER_FULL_NAME) && echo "K8s Cluster Name: ${TF_VAR_k8s_cluster_name}"
export TF_VAR_k8s_keypair_name=$(aws ec2 describe-instances --region ${CLUSTER_AWS_REGION} --filters "Name=instance-state-name,Values=running" "Name=tag-value,Values=nodes.${CLUSTER_FULL_NAME}" | jq --raw-output .Reservations[].Instances[0].KeyName) && echo "K8s Keypair Name: ${TF_VAR_k8s_keypair_name}"
export TF_VAR_k8s_nodes_sg_id=$(aws ec2 describe-instances --region ${CLUSTER_AWS_REGION} --filters "Name=instance-state-name,Values=running" "Name=tag-value,Values=nodes.${CLUSTER_FULL_NAME}" | jq --raw-output .Reservations[].Instances[0].SecurityGroups[].GroupId) && echo "K8s Nodes Security Group ID: ${TF_VAR_k8s_nodes_sg_id}"
export TF_VAR_k8s_subnet_id=$(aws ec2 describe-instances --region ${CLUSTER_AWS_REGION} --filters "Name=instance-state-name,Values=running" "Name=tag-value,Values=nodes.${CLUSTER_FULL_NAME}" | jq --raw-output .Reservations[].Instances[0].SubnetId) && echo "K8s Subnet ID: ${TF_VAR_k8s_subnet_id}"

# Pause for 3 seconds
sleep 3

# Change to the Terraform directory and apply the Terraform configuration
cd terraform/k8s-windows-node-aws
rm -rf .terraform/
rm *terraform.tfstate*
terraform get
terraform init
terraform plan

echo "Run 'terraform apply' to deploy"