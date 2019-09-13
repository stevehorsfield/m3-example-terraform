variable "environment" {
  description = "The environment name, used in tags and names"
  type        = "string"
  default     = "example"
}

variable "environment-short-name" {
  description = "The shortened version of the environment name which is used in some resources and state files"
  type        = "string"
  default     = "example"
}

variable "region" {
  description = "AWS region"
  type        = "string"
  default     = "us-east-1"
}

variable "remote-state-bucket" {
  description = "Name of bucket containing remote state"
  type        = "string"
  default     = "example-terraform-state-s3"
}

variable "remote-state-region" {
  description = "AWS region for remote state"
  type        = "string"
  default     = "us-east-1"
}

variable "access_key" {
  description = "AWS access key"
  type        = "string"
}

variable "secret_key" {
  description = "AWS secret key"
  type        = "string"
}



variable "internal-ingress-cert-arn" {
  type        = "string"
  description = "ARN of certificate for internal ingress ALB"
  default     = "arn:aws:acm:us-east-1:xxx:certificate/xxx"
}

variable "prometheus-configuration" {
  description = "Prometheus configuration"
  type = "map"
  default = {
    ami_id                   = "ami-0b898040803850657"
    ec2-key-name             = "some-ec2-ssh-key-name"
    spot_max_price           = "0.15"
    storage-size-gb          = "10"
    prometheus-binary-key    = "prometheus/prometheus-2.11.1.linux-amd64.tar.gz"
    node-exporter-binary-key = "prometheus/node_exporter-0.18.1.linux-amd64.tar.gz"
    yq-binary-key            = "yq/yq-2.7.2.tgz"

    other-account-discovery-role = "arn:aws:iam::xxx:role/prometheus-remote-access"
  }
}

variable "prometheus-spot-instance-types" {
  description = "list of instance types"
  type = "list"
  default = [
    "m5.xlarge",
    "m5d.xlarge",
    "m5a.xlarge",
    "m5ad.xlarge",
    "t2.xlarge",
    "t3a.xlarge",
    "t3.xlarge",
    "m4.xlarge",
    "c5.xlarge",
    "c5n.xlarge",
    "c4.xlarge",
    "r5.large",
    "r5a.large",
    "r4.xlarge"
  ]
}

variable "grafana-configuration" {
  description = "configuration of Grafana UI for Prometheus"
  type = "map"
  default = {
    grafana-ami-id          = "ami-0b898040803850657"
    grafana-ec2-key-name    = "some-ec2-ssh-key-name"
    grafana-pool-min-size   = "0"
    grafana-pool-max-size   = "3"
    grafana-spot-max-price  = "0.1"
    grafana-storage-size-gb = "10"
    grafana-binary-key      = "grafana/grafana-6.2.5.linux-amd64.tar.gz"
    grafana-hostname        = "grafana.example.com"

    node-exporter-binary-key = "node-exporter/node_exporter-0.18.1.linux-amd64.tar.gz"
  }
}

variable "grafana-spot-instance-types" {
  description = "list of instance types for Grafana nodes"
  type = "list"
  default = [
    "t3a.micro",
    "t3.micro",
  ]
}

variable "m3-configuration" {
  description = "configuration of Uber's M3 storage/query engine for Prometheus"
  type        = "map"
  default     = {
    etcd-instance-type            = "a1.medium"
    etcd-ami                      = "ami-07758d83078bf5e86"
    etcd-root-volume-gb           = "5"
    etcd-data-volume-gb           = "5"
    etcd-ec2-key-name             = "some-ec2-ssh-key-name"
    etcd-binary-key               = "etcd/etcd-v3.3.13-linux-arm64.tar.gz"
    etcd-node-exporter-binary-key = "node-exporter/node_exporter-0.18.1.linux-arm64.tar.gz"

    data-data-volume-gb = "500" # minimum for st1 volumes

    # The following cause instance changes which must be performed exactly one at a time
    data0-instance-type            = "r5.large"
    data0-ami                      = "ami-00b882ac5193044e4"
    data0-root-volume-gb           = "8"
    data0-ec2-key-name             = "some-ec2-ssh-key-name"
    data0-etcd-binary-key          = "etcd/etcd-v3.3.13-linux-arm64.tar.gz"
    data0-m3-binary-key            = "m3/m3_0.10.2_linux_amd64.tar.gz"
    data0-node-exporter-binary-key = "prometheus/node_exporter-0.18.1.linux-amd64.tar.gz"

    data1-instance-type            = "r5.large"
    data1-ami                      = "ami-00b882ac5193044e4"
    data1-root-volume-gb           = "8"
    data1-ec2-key-name             = "some-ec2-ssh-key-name"
    data1-etcd-binary-key          = "etcd/etcd-v3.3.13-linux-arm64.tar.gz"
    data1-m3-binary-key            = "m3/m3_0.10.2_linux_amd64.tar.gz"
    data1-node-exporter-binary-key = "prometheus/node_exporter-0.18.1.linux-amd64.tar.gz"

    data2-instance-type            = "r5.large"
    data2-ami                      = "ami-00b882ac5193044e4"
    data2-root-volume-gb           = "8"
    data2-ec2-key-name             = "some-ec2-ssh-key-name"
    data2-etcd-binary-key          = "etcd/etcd-v3.3.13-linux-arm64.tar.gz"
    data2-m3-binary-key            = "m3/m3_0.10.2_linux_amd64.tar.gz"
    data2-node-exporter-binary-key = "prometheus/node_exporter-0.18.1.linux-amd64.tar.gz"

    # M3 Query
    query-pool-min-size            = "0"
    query-pool-max-size            = "3"
    query-spot-max-price           = "0.1"
    query-ami                      = "ami-00b882ac5193044e4"
    query-ec2-key-name             = "some-ec2-ssh-key-name"
    query-node-exporter-binary-key = "prometheus/node_exporter-0.18.1.linux-amd64.tar.gz"
    query-m3-binary-key            = "m3/m3_0.10.2_linux_amd64.tar.gz"
    query-etcd-binary-key          = "etcd/etcd-v3.3.13-linux-amd64.tar.gz"

    # Coordinator
    coordinator-m3-binary-key      = "m3/m3_0.10.2_linux_amd64.tar.gz"
  }
}

variable "m3-query-spot-instance-types" {
  description = "list of instance types for M3 Query nodes"
  type = "list"
  default = [
    "m5.large",
    "m5d.large",
    "m5a.large",
    "m5ad.large",
    "t2.large",
    "t3a.large",
    "t3.large",
    "m4.large",
    "c5.large",
    "c5n.large",
    "c4.large",
    "r5.large",
    "r5a.large",
    "r4.large"
  ]
}

variable "all-internal-network-cidr-block" {
  type    = "string"
  default = "${var.all-internal-network-cidr-block}"
}