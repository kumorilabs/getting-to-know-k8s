# Load variables from variables.sh script
source ./scripts/variables.sh

# Pass positional parameters to variables
if [ -z $1 ]; then echo "Deploying Heapster on Cluster: ${CLUSTER_ALIAS}"; else 
export CLUSTER_ALIAS="$1" && 
export CLUSTER_FULL_NAME="${CLUSTER_ALIAS}.${DOMAIN_NAME}" && 
echo "Deploying Heapster on Cluster: ${CLUSTER_ALIAS}"; fi

# Pause for 3 seconds
sleep 3

# Deploy Heapster Monitoring
kubectl --context ${CLUSTER_ALIAS} create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/monitoring-standalone/v1.2.0.yaml