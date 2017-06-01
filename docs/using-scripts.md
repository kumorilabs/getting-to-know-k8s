# Using Scripts

In addition to the step-by-step instructions provided for each lab, this repository also contains scripts to automate some of the activities being performed in the labs.

You will need to review the [script variables](/docs/script-variables.md) guide before running any of the provided scripts.

If you are using the Vagrant box together with Windows & Git Bash, you may run into a issue where the script files are not marked as executable due to the underlying Windows file system. The easiest workaround for this issue is to clone the repository to a different folder from within the Vagrant box and you should then be able to run the scripts there:

```bash
git clone https://github.com/kumorilabs/getting-to-know-k8s ~/getting-to-know-k8s-scripts
cd ~/getting-to-know-k8s-scripts
```

**Cluster Deployment**
* [Create Cluster](#create-cluster)
* [Delete Cluster](#delete-cluster)

**Cluster Add-ons**
* [Deploy Kubernetes Dashboard](#deploy-kubernetes-dashboard)
* [Deploy Heapster Monitoring](#deploy-heapster-monitoring)
* [Deploy Cluster Autoscaler](#deploy-cluster-autoscaler)

**Federation**
* [Create Federation](#create-federation)

**Application Deployment**
* [Deploy Hugo Site (Standalone)](#deploy-hugo-site-standalone)
* [Deploy Hugo Site (Federated)](#deploy-hugo-site-federated)
* [Deploy Hugo Site (Rolling Update)](#deploy-hugo-site-rolling-update)
* [Deploy Hugo Site (Blue-Green Deployment)](#deploy-hugo-site-blue-green-deployment)
* [Deploy Hugo Site (Canary Deployment)](#deploy-hugo-site-canary-deployment)
* [Deploy Jenkins](#deploy-jenkins)
* [Deploy Horizontal Pod Autoscaling Demo](#deploy-horizontal-pod-autoscaling-demo)


# Cluster Deployment


## Create Cluster

* Creates a S3 bucket which will be used by Kops for cluster configuration storage
* Creates a cluster
* Creates a cluster context alias
* Link to [Deploy a new cluster](https://kumorilabs.com/blog/k8s-1-deploy-kubernetes-cluster-aws-kops/#deploy-a-new-cluster) in [Lab #1: Deploy a Kubernetes Cluster in AWS with Kops](https://kumorilabs.com/blog/k8s-1-deploy-kubernetes-cluster-aws-kops/)

### Usage

```bash
./scripts/clusters/create-cluster.sh [CLUSTER_ALIAS] [CLUSTER_AWS_AZ]
```

* `[CLUSTER_ALIAS]` - Cluster context alias to use for the new cluster *(Optional)*
* `[CLUSTER_AWS_AZ]` - AWS availability zone where the new cluster will be deployed *(Optional)*

If you do provide the configuration options above for `[CLUSTER_ALIAS]` and `[CLUSTER_AWS_AZ]`, they will override the values specified in the variables.sh file.

### Example

The following will create two clusters, one with the values from the variables.sh file (default is `usa` & `us-east-1a`) and the other with a cluster alias of `eur`, which will be located in the `eu-west-1a` AWS availability zone:

```bash
./scripts/clusters/create-cluster.sh
./scripts/clusters/create-cluster.sh eur eu-west-1a
```


## Delete Cluster

* Deletes an existing cluster
* Deletes the S3 bucket used by Kops for cluster configuration storage
* Link to [Delete the cluster](https://kumorilabs.com/blog/k8s-1-deploy-kubernetes-cluster-aws-kops/#delete-the-cluster) in [Lab #1: Deploy a Kubernetes Cluster in AWS with Kops](https://kumorilabs.com/blog/k8s-1-deploy-kubernetes-cluster-aws-kops/)

### Usage

```bash
./scripts/clusters/delete-cluster.sh [CLUSTER_ALIAS]
```

* `[CLUSTER_ALIAS]` - Cluster context alias of an existing cluster *(Optional)*

If you do provide the configuration option above for `[CLUSTER_ALIAS]`, it will override the value specified in the variables.sh file.

### Example

The following will delete two clusters, one with the value from the variables.sh file (default is `usa`) and the other with cluster alias `eur`:

```bash
./scripts/clusters/delete-cluster.sh
./scripts/clusters/delete-cluster.sh eur
```


# Cluster Add-ons


## Deploy Kubernetes Dashboard

* Deploys the Kubernetes dashboard add-on to an existing cluster
* Link to [Deploy the Kubernetes dashboard](https://kumorilabs.com/blog/k8s-2-maintaining-your-kubernetes-cluster/#deploy-the-kubernetes-dashboard) in [Lab #2: Maintaining your Kubernetes Cluster](https://kumorilabs.com/blog/k8s-2-maintaining-your-kubernetes-cluster/)

### Usage

```bash
./scripts/addons/kubernetes-dashboard/deploy-dashboard.sh [CLUSTER_ALIAS]
```

* `[CLUSTER_ALIAS]` - Cluster context alias of an existing cluster *(Optional)*

If you do provide the configuration option above for `[CLUSTER_ALIAS]`, it will override the value specified in the variables.sh file.

### Example

The following will deploy the Kubernetes dashboard add-on to two clusters, `usa` (default in the variables.sh file) and `eur`:

```bash
./scripts/addons/kubernetes-dashboard/deploy-dashboard.sh
./scripts/addons/kubernetes-dashboard/deploy-dashboard.sh eur
```


## Deploy Heapster Monitoring

* Deploys the Heapster monitoring add-on to an existing cluster
* Link to [Deploy the Heapster Monitoring add-on](https://kumorilabs.com/blog/k8s-5-setup-horizontal-pod-cluster-autoscaling-kubernetes/#deploy-the-heapster-monitoring-add-on) in [Lab #5: Setup Horizontal Pod & Cluster Autoscaling in Kubernetes](https://kumorilabs.com/blog/k8s-5-setup-horizontal-pod-cluster-autoscaling-kubernetes/)

### Usage

```bash
./scripts/addons/heapster-monitoring/deploy-heapster-monitoring.sh [CLUSTER_ALIAS]
```

* `[CLUSTER_ALIAS]` - Cluster context alias of an existing cluster *(Optional)*

If you do provide the configuration option above for `[CLUSTER_ALIAS]`, it will override the value specified in the variables.sh file.

### Example

The following will deploy the Heapster monitoring add-on to two clusters, `usa` (default in the variables.sh file) and `eur`:

```bash
./scripts/addons/heapster-monitoring/deploy-heapster-monitoring.sh
./scripts/addons/heapster-monitoring/deploy-heapster-monitoring.sh eur
```


## Deploy Cluster Autoscaler

* Creates an IAM policy with permissions needed for the cluster autoscaler add-on
* Deploys the cluster autoscaler add-on to an existing cluster
* Link to [Deploy the Cluster Autoscaler add-on](https://kumorilabs.com/blog/k8s-5-setup-horizontal-pod-cluster-autoscaling-kubernetes/#deploy-the-cluster-autoscaler-add-on) in [Lab #5: Setup Horizontal Pod & Cluster Autoscaling in Kubernetes](https://kumorilabs.com/blog/k8s-5-setup-horizontal-pod-cluster-autoscaling-kubernetes/)

### Usage

```bash
./scripts/addons/cluster-autoscaler/deploy-cluster-autoscaler.sh [CLUSTER_ALIAS] [CLUSTER_AWS_REGION] [MIN_NODES] [MAX_NODES]
```

* `[CLUSTER_ALIAS]` - Cluster context alias of an existing cluster *(Mandatory)*
* `[CLUSTER_AWS_REGION]` - AWS region of the existing cluster *(Mandatory)*
* `[MIN_NODES]` - Minimum number of nodes to configure for the AWS autoscaling group *(Mandatory)*
* `[MAX_NODES]` - Maximum number of nodes to configure for the AWS autoscaling group *(Mandatory)*

### Example

The following will deploy the cluster autoscaler add-on to two clusters, one with cluster alias `usa` located in the `us-east-1` AWS region with a minimum of `3` nodes and a maximum of `5` nodes. And the other with cluster alias `eur` located in the `eu-west-1` AWS region with a minimum of `4` nodes and a maximum of `6` nodes:

```bash
./scripts/addons/cluster-autoscaler/deploy-cluster-autoscaler.sh usa us-east-1 3 5
./scripts/addons/cluster-autoscaler/deploy-cluster-autoscaler.sh eur eu-west-1 4 6
```


# Federation


## Create Federation

* Creates a Federation between two or three existing clusters
* Name of the Federation is specified as `FEDERATION_NAME` in the [`/scripts/variables.sh`](/scripts/variables.sh#L16) file
* Creates two federated namespaces called `default` and `federation`
* Link to [Create the Federation](https://kumorilabs.com/blog/k8s-10-setup-kubernetes-federation-different-aws-regions/#create-the-federation) in [Lab #10: Setup Kubernetes Federation Between Clusters in Different AWS Regions](https://kumorilabs.com/blog/k8s-10-setup-kubernetes-federation-different-aws-regions/)

### Usage

```bash
./scripts/clusters/federation/create-federation.sh [HOST_CLUSTER_ALIAS] [CLUSTER_2_ALIAS] [CLUSTER_3_ALIAS]
```

* `[HOST_CLUSTER_ALIAS]` - Cluster context alias of an existing cluster, which will host the Federation services *(Mandatory)*
* `[CLUSTER_2_ALIAS]` - Cluster context alias of a second existing cluster, which will join the Federation with the host cluster *(Mandatory)*
* `[CLUSTER_3_ALIAS]` - Cluster context alias of a third existing cluster, which will join the Federation with the host cluster *(Optional)*

### Example

The following will create a Federation between two clusters, `usa` & `eur`. The `usa` cluster will host the Federation services:

```bash
./scripts/clusters/federation/create-federation.sh usa eur
```

The following will create a Federation between three clusters, `frankfurt`, `sydney` & `mumbai`. The `frankfurt` cluster will host the Federation services:

```bash
./scripts/clusters/federation/create-federation.sh frankfurt sydney mumbai
```


# Application Deployments


## Deploy Hugo Site (Standalone)

* Creates a Deployment of the Hugo site in a single cluster
* Docker image of the Hugo site is specified as `HUGO_APP_DOCKER_IMAGE` in the [`/scripts/variables.sh`](/scripts/variables.sh#L19) file
* Docker image tag `1.0` will be used
* Creates a load balancer Service for the Deployment, which exposes port 80
* Creates a DNS record with the prefix `hugo` in your domain in Route 53 (ex: hugo.k8s.kumorilabs.com)
* Link to [Create the Kubernetes Deployment for the Hugo site](https://kumorilabs.com/blog/k8s-3-create-deployments-services-kubernetes/#create-the-kubernetes-deployment-for-the-hugo-site) in [Lab #3: Creating Deployments & Services in Kubernetes](https://kumorilabs.com/blog/k8s-3-create-deployments-services-kubernetes/)

### Usage

```bash
./scripts/apps/hugo-app/deploy-hugo-app.sh [CLUSTER_ALIAS]
```

* `[CLUSTER_ALIAS]` - Cluster context alias of an existing cluster *(Optional)*

If you do provide the configuration option above for `[CLUSTER_ALIAS]`, it will override the value specified in the variables.sh file.

### Example

The following will deploy the Hugo site to two clusters, `usa` (default in the variables.sh file) and `eur`:

```bash
./scripts/apps/hugo-app/deploy-hugo-app.sh
./scripts/apps/hugo-app/deploy-hugo-app.sh eur
```


## Deploy Hugo Site (Federated)

* Creates a federated Deployment of the Hugo site in a Federation with two to three clusters
* Docker image of the Hugo site is specified as `HUGO_APP_DOCKER_IMAGE` in the [`/scripts/variables.sh`](/scripts/variables.sh#L19) file
* Docker image tag `1.0` will be used
* Creates a load balancer Service in each cluster for the federated Hugo site Deployment, which exposes port `80`
* Creates a DNS record for each cluster in the Federation, which uses latency-based routing with the prefix `hugo-fed` in your domain in Route 53 (ex: hugo-fed.k8s.kumorilabs.com)
* Link to [Create the federated Deployment for the Hugo site](https://kumorilabs.com/blog/k8s-10-setup-kubernetes-federation-different-aws-regions/#create-the-federated-deployment-for-the-hugo-site) in [Lab #10: Setup Kubernetes Federation Between Clusters in Different AWS Regions](https://kumorilabs.com/blog/k8s-10-setup-kubernetes-federation-different-aws-regions/)

### Usage

```bash
./scripts/apps/hugo-app-federation/deploy-hugo-app-federation.sh [CLUSTER_1_ALIAS] [CLUSTER_1_AWS_REGION] [CLUSTER_2_ALIAS] [CLUSTER_2_AWS_REGION] [CLUSTER_3_ALIAS] [CLUSTER_3_AWS_REGION]
```

* `[CLUSTER_1_ALIAS]` - Cluster context alias of the first existing cluster in a Federation *(Mandatory)*
* `[CLUSTER_1_AWS_REGION]` - AWS region of the first existing cluster in a Federation *(Mandatory)*
* `[CLUSTER_2_ALIAS]` - Cluster context alias of the second existing cluster in a Federation *(Mandatory)*
* `[CLUSTER_2_AWS_REGION]` - AWS region of the second existing cluster in a Federation *(Mandatory)*
* `[CLUSTER_3_ALIAS]` - Cluster context alias of the third existing cluster in a Federation *(Optional)*
* `[CLUSTER_3_AWS_REGION]` - AWS region of the third existing cluster in a Federation *(Optional)*

### Example

The following will deploy the federated Hugo site to three clusters, `usa` in the `us-east-1` AWS region, `eur` in the `eu-west-1` AWS region and `tyo` in the `ap-northeast-1` AWS region:

```bash
./scripts/apps/hugo-app-federation/deploy-hugo-app-federation.sh usa us-east-1 eur eu-west-1 tyo ap-northeast-1
```


## Deploy Hugo Site (Rolling Update)

* Creates a rolling update Deployment scenario of the Hugo site in a single cluster
* Docker image of the Hugo site is specified as `HUGO_APP_DOCKER_IMAGE` in the [`/scripts/variables.sh`](/scripts/variables.sh#L19) file
* Docker image tags `red` & `yellow` will be used
* Creates a load balancer Service for the Deployment, which exposes port `80`
* Creates a DNS record with the prefix `hugo-rolling-update` in your domain in Route 53 (ex: hugo-rolling-update.k8s.kumorilabs.com)
* Link to [Rolling Updates](https://kumorilabs.com/blog/k8s-4-deployments-rolling-updates-canary-blue-green-kubernetes/#rolling-updates) in [Lab #4: Deployment Strategies: Rolling Updates, Canary & Blue-Green](https://kumorilabs.com/blog/k8s-4-deployments-rolling-updates-canary-blue-green-kubernetes/)

### Usage

```bash
./scripts/apps/hugo-app-rolling-update/deploy-hugo-app-rolling-update.sh [CLUSTER_ALIAS]
```

* `[CLUSTER_ALIAS]` - Cluster context alias of an existing cluster *(Optional)*

If you do provide the configuration option above for `[CLUSTER_ALIAS]`, it will override the value specified in the variables.sh file.

The initial Deployment will be using the `red` image. To kick-off the rolling update to the `yellow` image, run the following:

```bash
# Set your GitHub username
export GITHUB_USERNAME="smesch"
```
```bash
kubectl set image deploy/hugo-app-rolling-update \
        hugo-app=${DOCKER_HUB_USERNAME}/hugo-app:yellow
```

### Example

The following will deploy the Hugo site to two clusters, `usa` (default in the variables.sh file) and `eur`:

```bash
./scripts/apps/hugo-app-rolling-update/deploy-hugo-app-rolling-update.sh
./scripts/apps/hugo-app-rolling-update/deploy-hugo-app-rolling-update.sh eur
```


## Deploy Hugo Site (Blue-Green Deployment)

* Creates a blue-green Deployment scenario of the Hugo site in a single cluster
* Docker image of the Hugo site is specified as `HUGO_APP_DOCKER_IMAGE` in the [`/scripts/variables.sh`](/scripts/variables.sh#L19) file
* Docker image tags `blue` & `green` will be used
* Creates a load balancer Service for the Deployments, which exposes port `80`
* Creates a DNS record with the prefix `hugo-blue-green` in your domain in Route 53 (ex: hugo-blue-green.k8s.kumorilabs.com)
* Link to [Blue-Green Deployments](https://kumorilabs.com/blog/k8s-4-deployments-rolling-updates-canary-blue-green-kubernetes/#blue-green-deployments) in [Lab #4: Deployment Strategies: Rolling Updates, Canary & Blue-Green](https://kumorilabs.com/blog/k8s-4-deployments-rolling-updates-canary-blue-green-kubernetes/)

### Usage

```bash
./scripts/apps/hugo-app-blue-green/deploy-hugo-app-blue-green.sh [CLUSTER_ALIAS]
```

* `[CLUSTER_ALIAS]` - Cluster context alias of an existing cluster *(Optional)*

If you do provide the configuration option above for `[CLUSTER_ALIAS]`, it will override the value specified in the variables.sh file.

The initial Service will be using the `color: blue` selector. To change the selector to `color: green`, run the following:

```bash
kubectl set selector svc/hugo-app-blue-green-svc color=green
```

### Example

The following will deploy the Hugo site to two clusters, `usa` (default in the variables.sh file) and `eur`:

```bash
./scripts/apps/hugo-app-blue-green/deploy-hugo-app-blue-green.sh
./scripts/apps/hugo-app-blue-green/deploy-hugo-app-blue-green.sh eur
```


## Deploy Hugo Site (Canary Deployment)

* Creates a canary Deployment scenario of the Hugo site in a single cluster
* Docker image of the Hugo site is specified as `HUGO_APP_DOCKER_IMAGE` in the [`/scripts/variables.sh`](/scripts/variables.sh#L19) file
* Docker image tags `red` & `yellow` will be used
* Creates a load balancer Service for the Deployments, which exposes port `80`
* Creates a DNS record with the prefix `hugo-canary` in your domain in Route 53 (ex: hugo-canary.k8s.kumorilabs.com)
* Link to [Canary Deployments](https://kumorilabs.com/blog/k8s-4-deployments-rolling-updates-canary-blue-green-kubernetes/#canary-deployments) in [Lab #4: Deployment Strategies: Rolling Updates, Canary & Blue-Green](https://kumorilabs.com/blog/k8s-4-deployments-rolling-updates-canary-blue-green-kubernetes/)

### Usage

```bash
./scripts/apps/hugo-app-canary/deploy-hugo-app-canary.sh [CLUSTER_ALIAS]
```

* `[CLUSTER_ALIAS]` - Cluster context alias of an existing cluster *(Optional)*

If you do provide the configuration option above for `[CLUSTER_ALIAS]`, it will override the value specified in the variables.sh file.

The initial Deployments will be three replicas of the `red` image and one replica of the `yellow` image. To change the amount of replicas for the two Deployments, run the following:

```bash
kubectl scale deployment hugo-app-yellow --replicas=4
```
```bash
kubectl scale deployment hugo-app-red --replicas=2
```

### Example

The following will deploy the Hugo site to two clusters, `usa` (default in the variables.sh file) and `eur`:

```bash
./scripts/apps/hugo-app-canary/deploy-hugo-app-canary.sh
./scripts/apps/hugo-app-canary/deploy-hugo-app-canary.sh eur
```


## Deploy Jenkins

* Creates a Deployment of Jenkins in a single cluster
* Docker image of Jenkins is specified as `JENKINS_DOCKER_IMAGE` in the [`/scripts/variables.sh`](/scripts/variables.sh#L20) file
* Creates a persistent volume claim for the Jenkins home directory (`/var/jenkins_home`)
* Creates a load balancer Service for the Jenkins Deployment, which exposes ports `80`
* Creates a DNS record with the prefix `jenkins` in your domain in Route 53 (ex: jenkins.k8s.kumorilabs.com)
* Link to [Deploy and configure Jenkins](https://kumorilabs.com/blog/k8s-6-integrating-jenkins-kubernetes/#deploy-and-configure-jenkins) in [Lab #6: Integrating Jenkins and Kubernetes](https://kumorilabs.com/blog/k8s-6-integrating-jenkins-kubernetes/)


### Usage

```bash
./scripts/apps/jenkins/deploy-jenkins.sh [CLUSTER_ALIAS]
```

* `[CLUSTER_ALIAS]` - Cluster context alias of an existing cluster *(Optional)*

If you do provide the configuration option above for `[CLUSTER_ALIAS]`, it will override the value specified in the variables.sh file.

### Example

The following will deploy Jenkins to two clusters, `usa` (default in the variables.sh file) and `eur`:

```bash
./scripts/apps/jenkins/deploy-jenkins.sh
./scripts/apps/jenkins/deploy-jenkins.sh eur
```


## Deploy Horizontal Pod Autoscaling Demo

* Creates a Deployment of the horizontal pod autoscaling demo in a single cluster
* Creates a cluster internal Service (ClusterIP) for the horizontal pod autoscaling demo Deployment, which exposes port 80
* Configures horizontal pod autoscaling for the horizontal pod autoscaling demo Deployment
* Link to [Deploy the demo HPA site](https://kumorilabs.com/blog/k8s-5-setup-horizontal-pod-cluster-autoscaling-kubernetes/#deploy-the-demo-hpa-site) in [Lab #5: Setup Horizontal Pod & Cluster Autoscaling in Kubernetes](https://kumorilabs.com/blog/k8s-5-setup-horizontal-pod-cluster-autoscaling-kubernetes/)

### Usage

```bash
./scripts/apps/horizontal-pod-autoscaling/deploy-hpa-app.sh [CLUSTER_ALIAS]
```

* `[CLUSTER_ALIAS]` - Cluster context alias of an existing cluster *(Optional)*

If you do provide the configuration option above for `[CLUSTER_ALIAS]`, it will override the value specified in the variables.sh file.

After running the script, open up a second terminal (if using Vagrant, browse to the root of the repository from a second terminal and connect with vagrant ssh) and run the following:

```bash
kubectl run -i --tty load-generator --image=busybox /bin/sh
```
```bash
# Hit enter for command prompt
while true; do wget -q -O- http://php-apache.default.svc.cluster.local; done
```
```console
OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!
OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!
OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!...
```

### Example

The following will deploy the horizontal pod autoscaling demo to two clusters, `usa` (default in the variables.sh file) and `eur`:

```bash
./scripts/apps/horizontal-pod-autoscaling/deploy-hpa-app.sh
./scripts/apps/horizontal-pod-autoscaling/deploy-hpa-app.sh eur
```