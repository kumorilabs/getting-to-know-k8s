# Load variables from variables.sh script
source ./scripts/variables.sh

# Pass positional parameters to variables
if [ -z $1 ]; then echo "Deploying Windows IIS (Default) on Cluster: ${CLUSTER_ALIAS}"; else 
export CLUSTER_ALIAS="$1" && 
export CLUSTER_FULL_NAME="${CLUSTER_ALIAS}.${DOMAIN_NAME}" &&  
echo "Deploying Windows IIS (Default) on Cluster: ${CLUSTER_ALIAS}"; fi

# Pause for 3 seconds
sleep 3

# Create Kubernetes objects
kubectl --context ${CLUSTER_ALIAS} create -f ./kubernetes/windows/iis-default --record

# Wait for Windows IIS (Default) ELB to be created
echo "Waiting for Windows IIS (Default) ELB to be created (60 seconds)"
sleep 60

# Set the DNS record prefix & the Service name and then retrieve the ELB URL
export DNS_RECORD_PREFIX="iis-default"
export SERVICE_NAME="iis-default-svc"
export HUGO_APP_ELB=$(kubectl --context=${CLUSTER_ALIAS} get services/${SERVICE_NAME} --template="{{range .status.loadBalancer.ingress}} {{.hostname}} {{end}}")

# Add to JSON file
sed -i -e 's|"Name": ".*|"Name": "'"${DNS_RECORD_PREFIX}.${DOMAIN_NAME}"'",|g' scripts/apps/dns-records/dns-record-single.json
sed -i -e 's|"Value": ".*|"Value": "'"${HUGO_APP_ELB}"'"|g' scripts/apps/dns-records/dns-record-single.json

# Create DNS record
aws route53 change-resource-record-sets --hosted-zone-id ${DOMAIN_NAME_ZONE_ID} --change-batch file://scripts/apps/dns-records/dns-record-single.json