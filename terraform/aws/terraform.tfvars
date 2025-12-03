aws_region            = "us-east-1"
gcp_region            = "us-central1"
gcp_project_id        = "my-gcp-project-id"
gcp_network_cidr      = "10.128.0.0/20"

vpc_id                = "vpc-0123456789abcdef0"
subnet_ids            = ["subnet-0123456789abc001", "subnet-0123456789abc002"]

project_name          = "aws-gcp-interconnect"
environment           = "dev"

transit_gateway_asn   = 64512
log_retention_days    = 30
bandwidth_alert_threshold = 900000000000
