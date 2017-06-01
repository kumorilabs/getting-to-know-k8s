# Getting to Know K8s - A Blog Series About All Things Kubernetes

The repository for the [Getting to Know K8s blog series](https://kumorilabs.com/blog/k8s-0-introduction-blog-series-kubernetes/) on [KumoriLabs.com](https://kumorilabs.com):

* [Introduction: A Blog Series About All Things Kubernetes](https://kumorilabs.com/blog/k8s-0-introduction-blog-series-kubernetes/)
* [Lab #1: Deploy a Kubernetes Cluster in AWS with Kops](https://kumorilabs.com/blog/k8s-1-deploy-kubernetes-cluster-aws-kops/)
* [Lab #2: Maintaining your Kubernetes Cluster](https://kumorilabs.com/blog/k8s-2-maintaining-your-kubernetes-cluster/)
* [Lab #3: Creating Deployments & Services in Kubernetes](https://kumorilabs.com/blog/k8s-3-create-deployments-services-kubernetes/)
* [Lab #4: Deployment Strategies: Rolling Updates, Canary & Blue-Green](https://kumorilabs.com/blog/k8s-4-deployments-rolling-updates-canary-blue-green-kubernetes/)
* [Lab #5: Setup Horizontal Pod & Cluster Autoscaling in Kubernetes](https://kumorilabs.com/blog/k8s-5-setup-horizontal-pod-cluster-autoscaling-kubernetes/)
* [Lab #6: Integrating Jenkins and Kubernetes](https://kumorilabs.com/blog/k8s-6-integrating-jenkins-kubernetes/)
* [Lab #7: Continuous Deployment with Jenkins and Kubernetes](https://kumorilabs.com/blog/k8s-7-continuous-deployment-jenkins-kubernetes/)
* [Lab #8: Continuous Deployment with Travis CI and Kubernetes](https://kumorilabs.com/blog/k8s-8-continuous-deployment-travis-ci-kubernetes/)
* [Lab #9: Continuous Deployment with Wercker and Kubernetes](https://kumorilabs.com/blog/k8s-9-continuous-deployment-wercker-kubernetes/)
* [Lab #10: Setup Kubernetes Federation Between Clusters in Different AWS Regions](https://kumorilabs.com/blog/k8s-10-setup-kubernetes-federation-different-aws-regions/)


# Getting Started

All of the posts in the blog series are structured as individual labs and although it is not required to go through them sequentially, it is recommended.

### Prerequisites

**AWS Account:** Amazon will be the IaaS provider we will be using and therefore you will need to have an AWS account. If you don't have an account, you can [sign-up for an AWS Free Tier account](https://aws.amazon.com/free/), which will give you a certain amount of usage of specific AWS resources for free each month for 12 months.

**AWS Route 53 Domain:** In addition to the AWS account, you will also need to have a public domain hosted in AWS Route 53, which is a requirement to deploy clusters with Kops. If you don't already have a domain in Route 53 that you can use, refer to the [Kops documentation](https://github.com/kubernetes/kops/blob/master/docs/aws.md#configure-dns) for instructions on how to setup one of the three supported scenarios.

**GitHub Account:** We will be creating a demo website with [Hugo](https://gohugo.io/), which will be used in multiple labs. The source for the Hugo site will need to be stored in a GitHub repository owned by you. If you don't already have a GitHub account, you can create a free account [here](https://github.com/join).

**Docker Hub Account:** The Docker images for the Hugo site need to be stored in a Docker Hub repository owned by you. If you don't already have a Docker Hub account, you can create a free account [here](https://hub.docker.com/).

### Lab Environment

For the execution of the labs, you can choose to use the provided [Vagrantfile](Vagrantfile) to provision a Vagrant box which has everything you will need already installed or you can install the required tools on your local host:

* [Using Vagrant](/docs/using-vagrant.md)
* [Using your local host](/docs/local-environment.md)