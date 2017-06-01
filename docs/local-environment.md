# Preparing Your Local Host Environment

This guide will walk you through the preparation of your local environment if you chose to conduct the labs from your local host. As an alternative, you can go to the [Using Vagrant](/docs/using-vagrant.md) guide for the steps to create a Vagrant box with everything you need already installed.


## Installations

Below are the tools you need to install on your local host. The commands below are for Linux and you can visit the links for instructions for other platforms. If you are using Windows 10, [installing Bash for Windows](https://msdn.microsoft.com/en-us/commandline/wsl/install_guide) and then running the commands below is recommended:

* [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), [Jq](https://stedolan.github.io/jq/download/), [Unzip](http://www.brocade.com/content/html/en/software-installation-guide/SDN-Controller-2.1.0-Software-Installation/GUID-0E81C58A-6F32-4862-9B0C-84F2DC8BA238.html), [Wget](https://www.gnu.org/software/wget/), [Python](https://www.python.org/downloads/)

```bash
# apt-get
sudo apt-get install git jq unzip wget python -y

# yum
sudo yum install epel-release -y
sudo yum install git jq unzip wget python -y
```

* [AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/installing.html)

```bash
curl https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o awscli-bundle.zip
unzip awscli-bundle.zip
sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
rm -rf awscli-bundle/ awscli-bundle.zip
```

* [Docker](https://docs.docker.com/engine/installation/) (If using Bash for Windows, [install Docker for Windows](https://www.docker.com/docker-windows) instead of running the commands below)

```bash
sudo curl -sSL https://get.docker.com/ | sh
sudo usermod -aG docker ${USER}
```

* [Hugo](https://gohugo.io/overview/installing/)

```bash
export HUGO_VERSION="0.20"
wget https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz
tar -xf hugo_${HUGO_VERSION}_Linux-64bit.tar.gz
sudo chmod +x hugo_${HUGO_VERSION}_linux_amd64/hugo_${HUGO_VERSION}_linux_amd64
sudo mv hugo_${HUGO_VERSION}_linux_amd64/hugo_${HUGO_VERSION}_linux_amd64 /usr/local/bin/hugo
rm -rf hugo_${HUGO_VERSION}_linux_amd64/ hugo_${HUGO_VERSION}_Linux-64bit.tar.gz
```

* [Terraform](https://www.terraform.io/downloads.html)

```bash
export TERRAFORM_VERSION="0.9.6"
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
sudo chmod +x terraform
sudo mv terraform /usr/local/bin/terraform
rm -rf terraform_${TERRAFORM_VERSION}_linux_amd64.zip
```

* [Kubectl](https://kubernetes.io/docs/tasks/kubectl/install/)

```bash
export KUBECTL_VERSION="1.6.4"
wget https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
sudo chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl
```

* [Kubefed](https://kubernetes.io/docs/tutorials/federation/set-up-cluster-federation-kubefed/#getting-kubefed)

```bash
export KUBEFED_VERSION="1.6.4"
wget https://storage.googleapis.com/kubernetes-release/release/v${KUBEFED_VERSION}/bin/linux/amd64/kubefed
sudo chmod +x kubefed
sudo mv kubefed /usr/local/bin/kubefed
```

* [Kops](https://github.com/kubernetes/kops#installing)

```bash
export KOPS_VERSION="1.6.0"
wget https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64
sudo chmod +x kops-linux-amd64
sudo mv kops-linux-amd64 /usr/local/bin/kops
```


## Clone the Repository

```bash
git clone https://github.com/kumorilabs/getting-to-know-k8s
cd getting-to-know-k8s
```


## AWS API Credentials

[Kops](https://github.com/kubernetes/kops#kubernetes-operations-kops), which we will be using to create Kubernetes clusters, requires you to have AWS API credentials configured. 

You can use your existing AWS user account or you can choose to create a dedicated user account for Kops.

### Use an existing AWS user account

If you are using your existing AWS user account, you must have at a minimum the following [IAM policies attached](http://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_managed-using.html#policies_using-managed-console) to it (or you can use the `AdministratorAccess` policy which includes all of these permissions):

```console
AmazonEC2FullAccess
AmazonRoute53FullAccess
AmazonS3FullAccess
IAMFullAccess
AmazonVPCFullAccess
```

### Create a dedicated user account for Kops

To create a dedicated user account for Kops, you can either use the management console or the AWS CLI:

```bash
aws iam create-group --group-name kops

export arns="
arn:aws:iam::aws:policy/AmazonEC2FullAccess
arn:aws:iam::aws:policy/AmazonRoute53FullAccess
arn:aws:iam::aws:policy/AmazonS3FullAccess
arn:aws:iam::aws:policy/IAMFullAccess
arn:aws:iam::aws:policy/AmazonVPCFullAccess"

for arn in $arns; do aws iam attach-group-policy --policy-arn "$arn" --group-name kops; done

aws iam create-user --user-name kops

aws iam add-user-to-group --user-name kops --group-name kops

aws iam create-access-key --user-name kops
```

You should record the values for `SecretAccessKey` and `AccessKeyID` in the returned JSON output, which are the AWS API credentials.

## Set the Required Environment Variables

Before staring any of the labs, you need to set the environment variables below with the AWS API credentials of the AWS user account you will be using:

```bash
export AWS_ACCESS_KEY_ID="AWS Access Key ID"
export AWS_SECRET_ACCESS_KEY="AWS Secret Access Key"
```

If you are not familiar with how to retrieve these values for your existing AWS user account, refer to the [AWS documentation](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html).


## SSH Public Key Path

Kops also requires a SSH public key file, which is used to create an AWS EC2 key pair for AWS instances that are created when creating a cluster.

If you don't have a SSH key available, refer to this [tutorial](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/#platform-mac) from GitHub on how to create one.

If your existing SSH public key file is not located in the default location (`~/.ssh/id_rsa.pub`), you will need to modify the `--ssh-public-key="~/.ssh/id_rsa.pub"` configuration option whenever creating clusters with Kops.


## Enjoy the Labs

You are ready to proceed with the labs.