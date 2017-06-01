# Load variables from variables.sh script
source ./scripts/variables.sh

# Pass positional parameters to variables
if [ -z $1 ]; then echo "Deploying Jenkins on Cluster: ${CLUSTER_ALIAS}"; else 
export CLUSTER_ALIAS="$1" && 
export CLUSTER_FULL_NAME="${CLUSTER_ALIAS}.${DOMAIN_NAME}" &&  
echo "Deploying Jenkins on Cluster: ${CLUSTER_ALIAS}"; fi

# Pause for 3 seconds
sleep 3

# Set Jenkins Docker image name in the jenkins-deploy.yaml file
sed -i -e "s|image: .*|image: ${JENKINS_DOCKER_IMAGE_TAG}|g" ./kubernetes/jenkins/jenkins-deploy.yaml

# Create Kubernetes objects
kubectl --context ${CLUSTER_ALIAS} create -f ./kubernetes/jenkins --record

# Wait for Jenkins ELB to be created
echo "Waiting for Jenkins ELB to be created (60 seconds)"
sleep 60

# Set the DNS record prefix & the Service name and then retrieve the ELB URL
export DNS_RECORD_PREFIX="jenkins"
export SERVICE_NAME="jenkins-leader-svc"
export JENKINS_ELB=$(kubectl --context=${CLUSTER_ALIAS} get services/${SERVICE_NAME} --template="{{range .status.loadBalancer.ingress}} {{.hostname}} {{end}}")

# Add to JSON file
sed -i -e 's|"Name": ".*|"Name": "'"${DNS_RECORD_PREFIX}.${DOMAIN_NAME}"'",|g' scripts/apps/dns-records/dns-record-single.json
sed -i -e 's|"Value": ".*|"Value": "'"${JENKINS_ELB}"'"|g' scripts/apps/dns-records/dns-record-single.json

# Create DNS record
aws route53 change-resource-record-sets --hosted-zone-id ${DOMAIN_NAME_ZONE_ID} --change-batch file://scripts/apps/dns-records/dns-record-single.json