variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region for the interconnect deployment"
  type        = string
  default     = "us-central1"
}

variable "project_name" {
  description = "Project name prefix for naming GCP resources"
  type        = string
  default     = "aws-gcp-interconnect"
}

variable "gcp_subnet_cidr" {
  description = "CIDR range for the main GCP subnet"
  type        = string
  default     = "10.128.0.0/20"
}

variable "gcp_router_asn" {
  description = "BGP ASN for GCP Cloud Router"
  type        = number
  default     = 64513
}

variable "vlan_tag" {
  description = "802.1Q VLAN tag to use for the interconnect attachment"
  type        = number
  default     = 2000
}

variable "customer_name" {
  description = "Customer name label for Cross-Cloud Interconnect"
  type        = string
  default     = "aws-gcp-cross-cloud-customer"
}

variable "aws_vpc_cidr" {
  description = "CIDR range of the AWS VPC that will connect to GCP"
  type        = string
  default     = "10.0.0.0/16"
}

variable "activation_key" {
  description = "Activation key provided from AWS Interconnect side"
  type        = string
  default     = ""
}
