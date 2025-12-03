terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.20"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# ============================================================================
# GCP NETWORK SETUP
# ============================================================================

# VPC Network
resource "google_compute_network" "main" {
  name                    = "${var.project_name}-network"
  auto_create_subnetworks = false

  depends_on = []
}

# Subnet
resource "google_compute_subnetwork" "main" {
  name          = "${var.project_name}-subnet"
  ip_cidr_range = var.gcp_subnet_cidr
  region        = var.gcp_region
  network       = google_compute_network.main.id

  enable_flow_logs = true
}

# ============================================================================
# CROSS-CLOUD INTERCONNECT SETUP
# ============================================================================

# Cloud Router for BGP
resource "google_compute_router" "main" {
  name    = "${var.project_name}-router"
  region  = var.gcp_region
  network = google_compute_network.main.id

  bgp {
    asn = var.gcp_router_asn
  }
}

# Cross-Cloud Interconnect Connection
resource "google_compute_interconnect_attachment" "cross_cloud" {
  name                     = "${var.project_name}-cci-attachment"
  type                     = "PARTNER"
  router                   = google_compute_router.main.name
  interconnect             = google_compute_interconnect.cross_cloud.name
  admin_enabled            = true

  # BGP Configuration
  vlan_tag8021q = var.vlan_tag
}

# Cross-Cloud Interconnect Resource
resource "google_compute_interconnect" "cross_cloud" {
  name                     = "${var.project_name}-cross-cloud-cci"
  interconnect_type        = "PARTNER"
  customer_name            = var.customer_name
  location                 = google_compute_interconnect_locations.available.resources.city
  requested_link_count     = 4  # Quad-redundancy
  link_type                = "LINK_TYPE_ETHERNET_100G"
  

  depends_on = []
}

# Get available interconnect locations
data "google_compute_interconnect_locations" "available" {
  filter = "city:${var.gcp_region}"
}

# ============================================================================
# NETWORK CONNECTIVITY CENTER (Multi-cloud Hub)
# ============================================================================

# Network Connectivity Center Hub
resource "google_network_connectivity_hub" "main" {
  name = "${var.project_name}-connectivity-hub"
}

# Spoke for local VPC
resource "google_network_connectivity_spoke" "gcp_vpc" {
  name            = "${var.project_name}-gcp-vpc-spoke"
  location        = var.gcp_region
  hub             = google_network_connectivity_hub.main.id
  linked_vpc_network {
    uri = google_compute_network.main.self_link
  }
}

# Spoke for AWS (configured via AWS side)
resource "google_network_connectivity_spoke" "aws_via_interconnect" {
  name            = "${var.project_name}-aws-spoke"
  location        = var.gcp_region
  hub             = google_network_connectivity_hub.main.id
  linked_interconnect_attachment {
    uri = google_compute_interconnect_attachment.cross_cloud.self_link
  }
}

# ============================================================================
# SECURITY & FIREWALL RULES
# ============================================================================

# Firewall rule to allow traffic from AWS
resource "google_compute_firewall" "allow_from_aws" {
  name    = "${var.project_name}-allow-aws"
  network = google_compute_network.main.name
  allow {
    protocol = "all"
  }
  source_ranges = [var.aws_vpc_cidr]
}

# Firewall rule to allow traffic to AWS
resource "google_compute_firewall" "allow_to_aws" {
  name      = "${var.project_name}-allow-to-aws"
  network   = google_compute_network.main.name
  allow {
    protocol = "all"
  }
  destination_ranges = [var.aws_vpc_cidr]
  direction          = "EGRESS"
}

# ============================================================================
# LOGGING & MONITORING
# ============================================================================

# Cloud Logging for VPC Flow
resource "google_compute_network_peering_routes_config" "gcp_routes" {
  peering = google_compute_network_peering.cross_cloud.name
  network = google_compute_network.main.self_link

  import_custom_routes = true
  export_custom_routes = true
}

# ============================================================================
# OUTPUTS
# ============================================================================

output "gcp_network_id" {
  value = google_compute_network.main.id
}

output "gcp_router_id" {
  value = google_compute_router.main.id
}

output "cci_attachment_id" {
  value = google_compute_interconnect_attachment.cross_cloud.id
}

output "connectivity_hub_id" {
  value = google_network_connectivity_hub.main.id
}

output "setup_complete" {
  value = "✅ GCP infrastructure ready. Use activation key from AWS to complete pairing."
}
