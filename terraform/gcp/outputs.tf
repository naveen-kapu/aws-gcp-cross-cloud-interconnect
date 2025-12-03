output "gcp_network_id" {
  description = "ID of the GCP VPC network"
  value       = google_compute_network.main.id
}

output "gcp_router_id" {
  description = "ID of the GCP Cloud Router"
  value       = google_compute_router.main.id
}

output "cci_attachment_id" {
  description = "ID of the Cross-Cloud Interconnect attachment"
  value       = google_compute_interconnect_attachment.cross_cloud.id
}

output "connectivity_hub_id" {
  description = "ID of the Network Connectivity Center hub"
  value       = google_network_connectivity_hub.main.id
}

output "setup_complete" {
  description = "Human-readable setup status"
  value       = "✅ GCP side of Cross-Cloud Interconnect deployed. Use activation key from AWS to complete pairing."
}
