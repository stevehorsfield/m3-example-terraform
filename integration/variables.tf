variable "environment" {
  description = "The environment name, used in tags and names"
  type        = "string"
}

variable "environment-short-name" {
  description = "The shortened version of the environment name which is used in some resources and state files"
  type        = "string"
}

variable "remote-state-bucket" {
  description = "Name of bucket containing remote state"
  type        = "string"
}

variable "remote-state-region" {
  description = "AWS region for remote state"
  type        = "string"
}

variable "region" {
  description = "AWS region"
  type        = "string"
}

variable "access_key" {
  description = "AWS access key"
  type        = "string"
}

variable "secret_key" {
  description = "AWS secret key"
  type        = "string"
}