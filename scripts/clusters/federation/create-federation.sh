# Load variables from variables.sh script
source ./scripts/variables.sh

# Pass positional parameters to variables
if [[ $# -gt 3 ]]; then echo "Only 3 clusters are supported" && exit 1; fi

if [[ -z $1 ]]; then echo "Must supply a host cluster alias and at least one additional cluster alias" && exit 1; else 
export HOST_CLUSTER_ALIAS="$1" && 
echo "Host Cluster: ${HOST_CLUSTER_ALIAS}"; fi

if [[ -z $2 ]]; then echo "Must supply a host cluster alias and at least one additional cluster alias" && exit 1; else 
export CLUSTER_2_ALIAS="$2" && 
echo "Cluster 2: ${CLUSTER_2_ALIAS}"; fi

if [[ -n $3 ]]; then 
export CLUSTER_3_ALIAS="$3" && 
echo "Cluster 3: ${CLUSTER_3_ALIAS}"; fi

# Pause for 3 seconds
sleep 3

# Initialize Federation
kubectl config use-context ${HOST_CLUSTER_ALIAS}

# Wait for Federation Controller & API to be deployed
echo "Creating the Federation Control Plane"
kubefed init ${FEDERATION_NAME} --host-cluster-context=${HOST_CLUSTER_ALIAS} --dns-provider=aws-route53 --dns-zone-name=${DOMAIN_NAME}

# Sleep for 5 minutes if using Kubernetes v1.5.x
if [[ ${K8S_VERSION} == *"1.5"* ]]; then
echo "Waiting for the Federation Control Plane to initialize (5 minutes)" &&
sleep 600
fi

# Join Clusters to Federation
kubectl config use-context ${FEDERATION_NAME}
kubefed join ${HOST_CLUSTER_ALIAS} --host-cluster-context=${HOST_CLUSTER_ALIAS} --cluster-context=${HOST_CLUSTER_ALIAS} --secret-name=${HOST_CLUSTER_ALIAS}cluster
kubefed join ${CLUSTER_2_ALIAS} --host-cluster-context=${HOST_CLUSTER_ALIAS} --cluster-context=${CLUSTER_2_ALIAS} --secret-name=${CLUSTER_2_ALIAS}cluster

if [[ -n $3 ]]; then 
kubefed join ${CLUSTER_3_ALIAS} --host-cluster-context=${HOST_CLUSTER_ALIAS} --cluster-context=${CLUSTER_3_ALIAS} --secret-name=${CLUSTER_3_ALIAS}cluster
fi

# Create default and federation namespaces in the Federation context
kubectl create ns default
kubectl create ns federation