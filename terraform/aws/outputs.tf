output "interconnect_setup_status" {
  value = {
    transit_gateway_id = aws_ec2_transit_gateway.main.id
    dx_gateway_id      = aws_dx_gateway.main.id
    status             = "Ready for manual Interconnect creation in AWS Console"
  }
}

output "next_steps" {
  value = <<-EOT
    
    ✅ AWS Infrastructure Created Successfully!
    
    Next Steps:
    1. Go to AWS Console > Direct Connect > AWS Interconnect
    2. Click "Create new multicloud Interconnect"
    3. Select "Google Cloud" as the provider
    4. Source Region: ${var.aws_region}
    5. Destination Region: ${var.gcp_region}
    6. Attach to DX Gateway: ${aws_dx_gateway.main.id}
    7. GCP Project ID: ${var.gcp_project_id}
    8. Create the Interconnect and note the ACTIVATION_KEY
    9. In GCP terminal, export the key: export TF_VAR_activation_key="<KEY>"
    10. Then run: cd ../gcp && terraform apply
    
  EOT
}
