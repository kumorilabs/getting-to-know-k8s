# Using Vagrant

There is a [Vagrantfile](../Vagrantfile) in the root of this repository, which will provision a Vagrant box that contains all the necessary tools needed to conduct the labs. You will need to have the following installed on your local host:

* [Vagrant](https://www.vagrantup.com/downloads.html)
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads/)
    * If using Windows, you will need to [disable Hyper-V](http://www.poweronplatforms.com/enable-disable-hyper-v-windows-10-8/) when running the Vagrant box
* [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
    * If using Windows, [install Git](http://git-scm.com/download/win) with the default settings and then use Git Bash for the steps below 


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

Before starting the Vagrant box, you need to set the environment variables below with the AWS API credentials of the AWS user account you will be using:

```bash
export AWS_ACCESS_KEY_ID="AWS Access Key ID"
export AWS_SECRET_ACCESS_KEY="AWS Secret Access Key"
```

Vagrant will automatically apply these environment variables to the Vagrant box during start-up.

If you are not familiar with how to retrieve these values for your existing AWS user account, refer to the [AWS documentation](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-set-up.html).


## Verify SSH Key Paths in Vagrantfile

Kops also requires a SSH public key file, which is used to create an AWS EC2 key pair for AWS instances that are created when creating a cluster.

If you don't have a SSH key available, refer to this [tutorial](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/#platform-mac) from GitHub on how to create one.

If your existing SSH key files are not located in the default location (`~/.ssh/id_rsa.pub` & `~/.ssh/id_rsa`), you will need to update the following lines in the [Vagrantfile](../Vagrantfile#L14-L15) before starting the Vagrant box:

```ruby
aws_keypair_pub_key_path = "~/.ssh/id_rsa.pub"
aws_keypair_pri_key_path = "~/.ssh/id_rsa"
```

Vagrant will automatically copy these files to the Vagrant box during start-up.


## Verify Versions of Tools

You can change the versions of the tools that will be installed on the Vagrant box. To do so, update the following variables in the [`/scripts/provision-vagrant.sh`](../scripts/provision-vagrant.sh#L2-L6) file before starting the Vagrant box:

```bash
# Vagrant installation variables
export KUBECTL_VERSION="1.7.6"
export KUBEFED_VERSION="1.7.6"
export KOPS_VERSION="1.7.0"
export HUGO_VERSION="0.27.1"
export TERRAFORM_VERSION="0.10.6"
```


## Start the Vagrant Box and Connect

From the root of the repository:

```bash
vagrant up
vagrant ssh
```


## Enjoy the Labs

You are ready to proceed with the labs.