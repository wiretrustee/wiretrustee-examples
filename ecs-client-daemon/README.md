# Wiretrustee client on ECS running as a daemon service on every EC2 instance (Terraform)
A common way to run containers in the AWS cloud is to use the service Elastic Container Service, which is a fully managed container orchestration service that makes it easy to deploy, manage, and scale containerized applications. It is best practice and common to run this infrastructure behind security guardrails like, strict security groups and private subnets.

Also, a routine for many System's administrators and Developers, is to connect to servers that run their company's software in order to troubleshoot, validate output and even install dependecies, and if you have your systems running in a secure network, you got a few options to allow communications to hosts in that private network:
* Add a [bastion host](https://en.wikipedia.org/wiki/Bastion_host) or [jump server](https://en.wikipedia.org/wiki/Jump_server)
* Connect a [site-2-site](https://en.wikipedia.org/wiki/Virtual_private_network#Types) VPN
* [Remote access](https://en.wikipedia.org/wiki/Virtual_private_network#Types) VPN
* Allow IP(s) address in the server's security group

All these options are valid and proved to work over the years, but they come with some costs that in short to mid term you start to deal with:
* Hard implementation
* Fragil firewall configuration
* Yet, another server to secure and maintain

In this example we will run Wiretrustee client configured as a daemon set in ECS. 

This allows you to:

* Run Wiretrustee as an ECS native service, you can manage and maintain it the same way you do with your other services
* Connect to EC2 running on private subnets without the need to open firewall rules or configure bastion servers
* Access other services connected to your Wiretrustee network and running anywhere.

## Requirements
* Terraform > 1.0
* A Wiretrustee account with a Setup Key
* Another Wiretrustee client in your network to validate the connection (possibly your laptop or a machine you are running this example on).
* The [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) installed.
* An [AWS account](https://aws.amazon.com/free/)
* Your AWS credentials. You can [create a new Access Key on this page](https://console.aws.amazon.com/iam/home?#/security_credentials)
## Notice
> Before getting started with this example, be aware that creating the resources from it may incur charges from AWS.

## Getting started

Clone this repository, download, and install Terraform following the guide [here](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started).

Login to https://app.wiretrustee.com and [add your machine as a peer](https://app.wiretrustee.com/add-peer), once you are done with the steps described there, copy your [Setup key](https://app.wiretrustee.com/setup-keys).

Using a text editor, edit the [variables.tf](variables.tf) file, and update the `wt_setup_key` variable with your setup key. Also, make sure that `ssh_public_key_path` variable is pointing to the correct public key path. If necessary, update the remaining variables according to your requirements and their descriptions.

Before continuing, you may also update the [provider.tf](provider.tf) to configure proper AWS region and default tags.

### Creating the resources with Terraform
Follow the steps below to run terraform and create your test environment:

1. From the root of the cloned repository, enter the ecs-client-daemon folder and run terraform init to download the modules and providers used in this example.
```shell
cd ecs-client-daemon
terraform init
```
2. Run terraform plan to get the estimated changes
```shell
terraform plan -out plan.tf
```
3. Run terraform apply to create your infrastructure
```shell
terraform apply plan.tf
``` 

### Validating the deployment
After a few minutes, the autoscaling group will launch an EC2 instance and there you will find the Wiretrustee's ECS Daemon service running. With that, we can go to our [Wiretrustee dashboard](https://app.wiretrustee.com) and pick the IP of the node that is running Wiretrustee, then we can connect to the node via ssh. For Unix(s) systems:
```shell
ssh ec2-user@100.64.0.200
``` 
Once you've login, you should be able to see the containers running by using the docker command:
```shell
sudo docker ps
```

### Deleting the infrastructure resources used in the example
Once you are done validating the example, you can remove the resources with the following steps:
1. Run terraform plan with the flag `-destroy`
```shell
terraform plan -out plan.tf -destroy
```
2. Then execute the apply command:
```shell
terraform apply plan.tf
```
