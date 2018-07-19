variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "eu-west-1"
}

variable "bucket_import" {
  description = "#A changer - S3 bucket name where OVA will be uploaded by user environment"
  #default     = "importova-{zone}-{universe}-eu-west-1"
}

variable "bucket_lambda" {
  description = "Z3 bucket name where Lambda functions are uploaded"
  default     = "lambda-eu-west-1-production-hz"
}

variable "email_address" {
    type = "string"
    description = "Email alerting pour les notifications export OVA via lambda"
    default = "fr-tgs-aws-run@thalesgroup.com"
}

variable "display_name_first" {
    type = "string"
    default = "VMIE Start"
}

variable "display_name_second" {
    type = "string"
    default = "VMIE Ended"
}

variable "owner" {
    type = "string"
}

variable "protocol" {
    default = "email"
    type    = "string"
}

variable "stack_name_sns1" {
    type = "string"
}

variable "stack_name_sns2" {
    type = "string"
}

variable "kms_key_id" {
    type = "string"
}