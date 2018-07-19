variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-1"
}

variable "source_account_id" {
  description = "The AWS account ID of the owner of the peer VPC"
  default     = "664061206716"
}

variable "hz_account_id" {
  description = "The AWS account ID of the HZ to peer VPC workspaces"
  default     = "548303330441"
}

variable "hz_netscaler_vpc" {
  description = "The AWS vpc of the HZ where Netscaler is located"
  default     = "vpc-f608c292"
}

variable "hz_netscaler_cidr" {
  description = "CIDR of HZ-PRZ"
  default = "10.187.120.0/21"
}

variable "hz_route_table" {
  description = "Route table of HZ-PRZ"
  default = "rtb-d51694b1"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-1"
}

variable "vpc_active_directory_cidr" {
  description = "VPC cidr for directory service partners access"
  default     = "10.187.140.0/24"
}

variable "vpc_active_directory_subnet1a" {
  description = "Subnet cidr for directory service subnet A"
  default     = "10.187.140.0/25"
}

variable "vpc_active_directory_subnet1b" {
  description = "Subnet cidr for directory service subnet B"
  default     = "10.187.140.128/25"
}

variable "vpc_workspaces_cidr" {
  description = "VPC cidr for directory service partners access"
  default     = "10.187.136.0/22"
}

variable "vpc_workspaces_subnet1a" {
  description = "Subnet cidr for Workspaces subnet A"
  default     = "10.187.136.0/23"
}

variable "vpc_workspaces_subnet1b" {
  description = "Subnet cidr for Workspaces subnet B"
  default     = "10.187.138.0/23"
}
