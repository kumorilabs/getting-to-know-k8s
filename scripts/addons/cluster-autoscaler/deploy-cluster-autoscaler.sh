# Load variables from variables.sh script
source ./scripts/variables.sh

# Pass positional parameters to variables
if [[ $# -lt 4 ]]; then echo "Must supply Cluster Alias, AWS Region, Min Nodes & Max Nodes" && exit 1; fi

export CLUSTER_ALIAS="$1" && echo "Cluster: ${CLUSTER_ALIAS}"
export CLUSTER_AWS_REGION="$2" && echo "AWS Region: ${CLUSTER_AWS_REGION}"
export MIN_NODES="$3" && echo "Min Nodes: ${MIN_NODES}"
export MAX_NODES="$4" && echo "Max Nodes: ${MAX_NODES}"
export CLUSTER_FULL_NAME="${CLUSTER_ALIAS}.${DOMAIN_NAME}"

# Pause for 3 seconds
sleep 3

# Create a new IAM policy for Cluster Autoscaler
aws iam put-role-policy --role-name nodes.${CLUSTER_FULL_NAME} --policy-name asg-nodes.${CLUSTER_FULL_NAME} --policy-document file://scripts/addons/cluster-autoscaler/policy-cluster-autoscaler.json

# Set min & max nodes, asg name and AWS region in the cluster-autoscaler-deploy.yaml file
sed -i -e "s|--nodes=.*|--nodes=${MIN_NODES}:${MAX_NODES}:nodes.${CLUSTER_FULL_NAME}|g" ./kubernetes/cluster-autoscaler/cluster-autoscaler-deploy.yaml
sed -i -e "s|value: .*|value: ${CLUSTER_AWS_REGION}|g" ./kubernetes/cluster-autoscaler/cluster-autoscaler-deploy.yaml

# Deploy Cluster Autoscaler
kubectl --context ${CLUSTER_ALIAS} apply -f ./kubernetes/cluster-autoscaler