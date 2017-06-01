# Load variables from variables.sh script
source ./scripts/variables.sh

# Pass positional parameters to variables
if [[ $# = 1 ]]; then echo "Must supply both a cluster alias and an AWS availability zone" && exit 1; fi

if [ -z $1 ]; then echo "Creating - Cluster Alias: ${CLUSTER_ALIAS} | Cluster Full Name: ${CLUSTER_FULL_NAME}"; else 
export CLUSTER_ALIAS="$1" && 
export CLUSTER_FULL_NAME="${CLUSTER_ALIAS}.${DOMAIN_NAME}" && 
echo "Creating - Cluster Alias: ${CLUSTER_ALIAS} | Cluster Full Name: ${CLUSTER_FULL_NAME}"; fi

if [ -z $2 ]; then echo "AWS Availability Zone: ${CLUSTER_AWS_AZ}"; else 
export CLUSTER_AWS_AZ="$2" && 
echo "AWS Availability Zone: ${CLUSTER_AWS_AZ}"; fi

# Pause for 3 seconds
sleep 3

# Create the S3 bucket used for Kubernetes cluster configuration storage
aws s3api create-bucket --bucket ${CLUSTER_FULL_NAME}-state

# Set KOPS_STATE_STORE to S3 bucket name
export KOPS_STATE_STORE="s3://${CLUSTER_FULL_NAME}-state"

# Create the Kubernetes cluster
kops create cluster \
--name=${CLUSTER_FULL_NAME} \
--master-zones=${CLUSTER_AWS_AZ} \
--zones=${CLUSTER_AWS_AZ} \
--master-size=${CLUSTER_MASTER_SIZE} \
--node-size=${CLUSTER_NODE_SIZE} \
--node-count=${CLUSTER_NODE_COUNT} \
--dns-zone=${DOMAIN_NAME} \
--ssh-public-key="${AWS_KEYPAIR_PUB_KEY_PATH}" \
--kubernetes-version=${K8S_VERSION}

kops edit cluster ${CLUSTER_FULL_NAME}
kops update cluster ${CLUSTER_FULL_NAME} --yes

# Create cluster context aliases
kubectl config set-context ${CLUSTER_ALIAS} --cluster=${CLUSTER_FULL_NAME} --user=${CLUSTER_FULL_NAME}

# Set current context to this cluster
kubectl config use-context ${CLUSTER_ALIAS}