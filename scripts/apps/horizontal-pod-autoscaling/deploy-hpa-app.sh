# Load variables from variables.sh script
source ./scripts/variables.sh

# Pass positional parameters to variables
if [ -z $1 ]; then echo "Deploying HPA example app on Cluster: ${CLUSTER_ALIAS}"; else 
export CLUSTER_ALIAS="$1" && 
export CLUSTER_FULL_NAME="${CLUSTER_ALIAS}.${DOMAIN_NAME}" &&  
echo "Deploying HPA example app on Cluster: ${CLUSTER_ALIAS}"; fi

# Pause for 3 seconds
sleep 3

# Run the php-apache container and configure autoscaling for the deployment
kubectl --context ${CLUSTER_ALIAS} run php-apache --image=gcr.io/google_containers/hpa-example --requests=cpu=200m --expose --port=80
kubectl --context ${CLUSTER_ALIAS} autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10