# Load variables from variables.sh script
source ./scripts/variables.sh

# Run the load-generator container and generate load against the php-apache deployment
kubectl --context ${CLUSTER_ALIAS} run -i --tty load-generator --image=busybox /bin/sh
while true; do wget -q -O- http://php-apache.default.svc.cluster.local; done