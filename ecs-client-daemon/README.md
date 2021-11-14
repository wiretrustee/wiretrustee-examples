# Wiretrustee client on ECS running as daemon on every EC2 instance
This example allows you to test Wiretrustee client configured as a daemon set in ECS. This allows you to connect to EC2 running on private subnets without the need to open firewall rules or configure bastion servers.

## Requirements
* Terraform > 1.0
* An Wiretrustee account with a Setup Key
* Another Wiretrustee client in your network to validate the connection. (possibly the same node you are running the example)
* The [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) installed.
* An [AWS account](https://aws.amazon.com/free/)
* Your AWS credentials. You can [create a new Access Key on this page](https://console.aws.amazon.com/iam/home?#/security_credentials)

## Getting started

Clone this repository and download and install Terraform following the guide [here](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started).

Login to https://app.wiretrustee.com and [add a new Peer](https://app.wiretrustee.com/add-peer), once you are done with the steps described there, copy your [Setup key](https://app.wiretrustee.com/setup-keys).

Using a text editor, edit the variables.tf file, and update the `wt_setup_key` variable with your setup key. Also, make sure that `ssh_public_key_path` variable is pointing to the correct public key path. If necessary, update the remaining variables according to your requirements.

Before continuing, you may also update the provider.tf to configure proper AWS region and default tags.

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
1. Run terraform plan with the flag `-destroy`
```shell
terraform plan -out plan.tf -destroy
```
2. Then execute the apply command:
```shell
terraform apply plan.tf
```
