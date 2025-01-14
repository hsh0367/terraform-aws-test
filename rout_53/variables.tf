variable "region" {
    description = "The AWS region"
    type        = string
}

variable "profile" {
    description = "The AWS profile"
    type        = string
}

variable "hosted_zone_name" {
    description = "The name of the hosted zone"
    type        = string
}

variable "subdomain_name" {
    description = "The name of the IAM user"
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

variable "record_value" {
    description = "The value of the record"
    type        = string
}
