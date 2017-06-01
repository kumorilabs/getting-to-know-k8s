# Load variables from variables.sh script
source ./scripts/variables.sh

# Pass positional parameters to variables
if [[ $# -gt 6 ]]; then echo "Only 3 cluster alias/aws region pairs are supported" && exit 1; fi

if [[ -z $1 ]]; then echo "Must supply at least 2 cluster alias/aws region pairs" && exit 1; else 
export CLUSTER_1_ALIAS="$1" && 
echo "Cluster 1 Name: ${CLUSTER_1_ALIAS}"; fi

if [[ -z $2 ]]; then echo "Must supply at least 2 cluster alias/aws region pairs" && exit 1; else 
export CLUSTER_1_AWS_REGION="$2" && 
echo "Cluster 1 AWS Region: ${CLUSTER_1_AWS_REGION}"; fi

if [[ -z $3 ]]; then echo "Must supply at least 2 cluster alias/aws region pairs" && exit 1; else 
export CLUSTER_2_ALIAS="$3" && 
echo "Cluster 2 Name: ${CLUSTER_2_ALIAS}"; fi

if [[ -z $4 ]]; then echo "Must supply at least 2 cluster alias/aws region pairs" && exit 1; else 
export CLUSTER_2_AWS_REGION="$4" && 
echo "Cluster 2 AWS Region: ${CLUSTER_2_AWS_REGION}"; fi

if [[ -n $5 ]]; then 
export CLUSTER_3_ALIAS="$5" && 
echo "Cluster 3 Name: ${CLUSTER_3_ALIAS}"; fi

if [[ -n $6 ]]; then 
export CLUSTER_3_AWS_REGION="$6" && 
echo "Cluster 3 AWS Region: ${CLUSTER_3_AWS_REGION}"; fi

# Pause for 3 seconds
sleep 3

# Set Hugo App image name in the hugo-app-federation-deploy.yaml file
sed -i -e "s|image: .*:|image: ${HUGO_APP_DOCKER_IMAGE}:|g" ./kubernetes/hugo-app-federation/hugo-app-federation-deploy.yaml

# Create Kubernetes objects
kubectl --context ${FEDERATION_NAME} create -f ./kubernetes/hugo-app-federation --record

# Wait for Hugo App ELBs to be created
echo "Waiting for Hugo App (Federation) ELBs to be created (90 seconds)"
sleep 90

# Create CNAME #1 record for Hugo
# Retreive ELB URL
export DNS_RECORD_PREFIX="hugo-fed"
export SERVICE_NAME="hugo-app-federation-svc"
export HUGO_APP_ELB_1=$(kubectl --context=${CLUSTER_1_ALIAS} get services/${SERVICE_NAME} --template="{{range .status.loadBalancer.ingress}} {{.hostname}} {{end}}")

# Add to JSON file
sed -i -e 's|"Name": ".*|"Name": "'"${DNS_RECORD_PREFIX}.${DOMAIN_NAME}"'",|g' scripts/apps/dns-records/dns-record-federation.json
sed -i -e 's|"Region": ".*|"Region": "'"${CLUSTER_1_AWS_REGION}"'",|g' scripts/apps/dns-records/dns-record-federation.json
sed -i -e 's|"SetIdentifier": ".*|"SetIdentifier": "'"${CLUSTER_1_AWS_REGION}"'",|g' scripts/apps/dns-records/dns-record-federation.json
sed -i -e 's|"Value": ".*|"Value": "'"${HUGO_APP_ELB_1}"'"|g' scripts/apps/dns-records/dns-record-federation.json

# Create DNS record
aws route53 change-resource-record-sets --hosted-zone-id ${DOMAIN_NAME_ZONE_ID} --change-batch file://scripts/apps/dns-records/dns-record-federation.json

# Create CNAME #2 record for Hugo
# Retreive ELB URL
export HUGO_APP_ELB_2=$(kubectl --context=${CLUSTER_2_ALIAS} get services/${SERVICE_NAME} --template="{{range .status.loadBalancer.ingress}} {{.hostname}} {{end}}")

# Add to JSON file
sed -i -e 's|"Name": ".*|"Name": "'"${DNS_RECORD_PREFIX}.${DOMAIN_NAME}"'",|g' scripts/apps/dns-records/dns-record-federation.json
sed -i -e 's|"Region": ".*|"Region": "'"${CLUSTER_2_AWS_REGION}"'",|g' scripts/apps/dns-records/dns-record-federation.json
sed -i -e 's|"SetIdentifier": ".*|"SetIdentifier": "'"${CLUSTER_2_AWS_REGION}"'",|g' scripts/apps/dns-records/dns-record-federation.json
sed -i -e 's|"Value": ".*|"Value": "'"${HUGO_APP_ELB_2}"'"|g' scripts/apps/dns-records/dns-record-federation.json

# Create DNS record
aws route53 change-resource-record-sets --hosted-zone-id ${DOMAIN_NAME_ZONE_ID} --change-batch file://scripts/apps/dns-records/dns-record-federation.json

if [[ -n $6 ]]; then 
# Create CNAME #3 record for Hugo
# Retreive ELB URL
export HUGO_APP_ELB_3=$(kubectl --context=${CLUSTER_3_ALIAS} get services/${SERVICE_NAME} --template="{{range .status.loadBalancer.ingress}} {{.hostname}} {{end}}")

# Add to JSON file
sed -i -e 's|"Name": ".*|"Name": "'"${DNS_RECORD_PREFIX}.${DOMAIN_NAME}"'",|g' scripts/apps/dns-records/dns-record-federation.json
sed -i -e 's|"Region": ".*|"Region": "'"${CLUSTER_3_AWS_REGION}"'",|g' scripts/apps/dns-records/dns-record-federation.json
sed -i -e 's|"SetIdentifier": ".*|"SetIdentifier": "'"${CLUSTER_3_AWS_REGION}"'",|g' scripts/apps/dns-records/dns-record-federation.json
sed -i -e 's|"Value": ".*|"Value": "'"${HUGO_APP_ELB_3}"'"|g' scripts/apps/dns-records/dns-record-federation.json

# Create DNS record
aws route53 change-resource-record-sets --hosted-zone-id ${DOMAIN_NAME_ZONE_ID} --change-batch file://scripts/apps/dns-records/dns-record-federation.json
fi