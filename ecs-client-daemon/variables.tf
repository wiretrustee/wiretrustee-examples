variable "name" {
  default= "Wiretrustee"
  description = "Used to name resources and tags"
}

variable "wt_log_level" {
  default = "debug"
  description = "As example, this is set to debug mode by default"
}

variable "wt_setup_key" {
  default = "CHANGE_ME"
  description = "Wiretrustee setup key"
  sensitive = true
}

variable "docker_image" {
  default = "wiretrustee/wiretrustee:latest"
  description = "Wiretrustee's client docker image. Must support environment variables"
}

variable "vpc_cidr" {
    default = "10.0.0.0/16"
    description = "Example VPC range, all subnets must be within this range"
}

variable "private_subnets" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "Private network subnet ranges, used to launch your EC2 instances"
}

variable "public_subnets" {
  type = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
  description = "Public network subnet ranges, mainly used to create the Nat gateway for the private networks"
}

variable "instance_type" {
  default = "t3.small"
  description = "Autoscaling group instance type"
}

variable "ssh_public_key_path" {
  default = "~/.ssh/id_rsa.pub"
  description = "The local SSH Key file that will be used for connecting to the EC2 instances"
}

variable "ssh_key_name" {
  default = "ops"
  description = "SSH Key name used for connecting to the EC2 instances"
}
