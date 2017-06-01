# Script Variables

Before running any of the provided scripts, you need to update the [`/scripts/variables.sh`](/scripts/variables.sh) file. At a minimum, you must update the value for `DOMAIN_NAME` with the domain you have hosted in AWS Route 53:

```shell
# General variables
export DOMAIN_NAME="k8s.kumorilabs.com" # Must be updated

# Cluster variables
export CLUSTER_ALIAS="usa"
export CLUSTER_FULL_NAME="${CLUSTER_ALIAS}.${DOMAIN_NAME}" # Leave as-is
export CLUSTER_AWS_REGION="us-east-1"
export CLUSTER_AWS_AZ="us-east-1a"
export CLUSTER_MASTER_SIZE="t2.medium"
export CLUSTER_NODE_SIZE="t2.medium"
export CLUSTER_NODE_COUNT="2"
export AWS_KEYPAIR_PUB_KEY_PATH="~/.ssh/id_rsa.pub"
export K8S_VERSION="1.6.4"

# Federation variables
export FEDERATION_NAME="fed"

# Application variables
export HUGO_APP_DOCKER_IMAGE="smesch/hugo-app"
export JENKINS_DOCKER_IMAGE_TAG="smesch/jenkins-kubernetes-leader-custom:2.32.3"
export DOMAIN_NAME_ZONE_ID=$(aws route53 list-hosted-zones \
       | jq -r '.HostedZones[] | select(.Name=="'${DOMAIN_NAME}'.") | .Id' \
       | sed 's/\/hostedzone\///') # Leave as-is
```


### General Variables

* `DOMAIN_NAME` - **Must Change**: Your domain name that is hosted in AWS Route 53, where the DNS records for your cluster will be created. This **value must be updated** with your own domain; otherwise Kops will fail to create the cluster


### Cluster Variables

* `CLUSTER_ALIAS` - Friendly name to use as an alias for your cluster, such as `usa` or `eur`
* `CLUSTER_FULL_NAME` - **Leave as-is**: Calculated value will be the full DNS name of you cluster, which is the cluster alias combined with your domain name (ex: `usa.k8s.kumorilabs.com`, `eur.k8s.kumorilabs.com`) 
* `CLUSTER_AWS_REGION` - AWS region where the cluster will be created
* `CLUSTER_AWS_AZ` - AWS availability zone where the cluster will be created
* `CLUSTER_MASTER_SIZE` - EC2 instance size of the master instance(s) that will be created for the cluster
* `CLUSTER_NODE_SIZE` - EC2 instance size of the node instances that will be created for the cluster
* `CLUSTER_NODE_COUNT` - Number of nodes that will be deployed in the cluster
* `AWS_KEYPAIR_PUB_KEY_PATH` - If you are using Vagrant, you can leave this as-is. If running in your local environment, update this if your SSH public key file is not located in the default location `~/.ssh/id_rsa.pub`
* `K8S_VERSION` - Version of Kubernetes that will be installed when deploying a cluster with Kops


### Federation Variables

* `FEDERATION_NAME` - Friendly name to use for the Federation, such as `fed` or `federation`


### Application Variables

* `HUGO_APP_DOCKER_IMAGE` - Docker image that will be used for the Hugo site Deployments. Change this only if you are using your own Docker image
* `JENKINS_DOCKER_IMAGE_TAG` - Docker image (with tag) that will be used for the Jenkins Deployment. Change this only if you are using your own Docker image
* `DOMAIN_NAME_ZONE_ID` - **Leave as-is**: Calculated value will be the AWS Route 53 hosted zone ID for your domain, which will be retrieved and used when DNS records are created for Deployments