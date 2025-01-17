variable "region" {
    description = "The AWS region"
    type        = string
}

variable "profile" {
    description = "The AWS profile"
    type        = string
}

variable "bucket_name" {
    description = "The name of the S3 bucket"
    type        = string   
}

variable "id_env" {
    description = "The environment for the resources"
    type        = string
}

variable "id_cat" {
    description = "The environment for the resources"
    type        = string
}

variable "id_group" {
    description = "The environment for the resources"
    type        = string
}

variable "id_service" {
    description = "The environment for the resources"
    type        = string
}

variable "hosted_zone_name"  {
    description = "The name of the hosted zone"
    type        = string
}

variable "subdomain_name" {
    description = "The name of the subdomain"
    type        = string
}

variable "record_type" {
    description = "The type of the record"
    type        = string
}
variable "ttl" {
    description = "The TTL of the record"
    type        = number
}