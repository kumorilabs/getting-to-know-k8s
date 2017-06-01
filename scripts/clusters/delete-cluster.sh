# Load variables from variables.sh script
source ./scripts/variables.sh

# Pass positional parameters to variables
if [ -z $1 ]; then echo "Deleting Cluster: ${CLUSTER_ALIAS}"; else 
export CLUSTER_ALIAS="$1" && 
export CLUSTER_FULL_NAME="${CLUSTER_ALIAS}.${DOMAIN_NAME}" && 
echo "Deleting Cluster: ${CLUSTER_ALIAS}"; fi

# Pause for 3 seconds
sleep 3

# Set KOPS_STATE_STORE to S3 bucket name
export KOPS_STATE_STORE="s3://${CLUSTER_FULL_NAME}-state"

# Delete the Kubernetes cluster
kops delete cluster ${CLUSTER_FULL_NAME} --yes

# Delete the S3 bucket used for Kubernetes cluster configuration storage
aws s3api delete-bucket --bucket ${CLUSTER_FULL_NAME}-state