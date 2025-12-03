variable "aws_region" {
  description = "AWS region for the interconnect"
  type        = string
  default     = "us-east-1"
  
  validation {
    condition     = contains(["us-east-1", "us-west-2", "eu-west-2", "eu-west-1"], var.aws_region)
    error_message = "AWS region must be one of the supported interconnect regions."
  }
}

variable "gcp_region" {
  description = "GCP region for the interconnect"
  type        = string
  default     = "us-central1"
}

variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_network_cidr" {
  description = "CIDR block of GCP VPC network"
  type        = string
  example     = "10.128.0.0/9"
}

variable "vpc_id" {
  description = "ID of the VPC to attach for multicloud connectivity"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for Transit Gateway attachment"
  type        = list(string)
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnets required for redundancy."
  }
}

variable "project_name" {
  description = "Project name (used for resource naming)"
  type        = string
  default     = "aws-gcp-interconnect"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "transit_gateway_asn" {
  description = "BGP ASN for Transit Gateway"
  type        = number
  default     = 64512
  
  validation {
    condition     = var.transit_gateway_asn >= 64512 && var.transit_gateway_asn <= 65534
    error_message = "ASN must be in private range (64512-65534)."
  }
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "bandwidth_alert_threshold" {
  description = "Bytes threshold for bandwidth alert"
  type        = number
  default     = 900000000000  # 900 GB
}
