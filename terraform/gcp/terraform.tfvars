gcp_project_id   = "my-gcp-project-id"
gcp_region       = "us-central1"
project_name     = "aws-gcp-interconnect"

gcp_subnet_cidr  = "10.128.0.0/20"
gcp_router_asn   = 64513
vlan_tag         = 2000
customer_name    = "aws-gcp-cross-cloud-demo"

aws_vpc_cidr     = "10.0.0.0/16"

# To be set after AWS side is provisioned
activation_key   = ""
