terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.30"
    }
  }

  # Uncomment for remote state management
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "aws-gcp-interconnect/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "AWS-GCP-Interconnect"
      ManagedBy   = "Terraform"
      CreatedAt   = timestamp()
    }
  }
}

# ============================================================================
# DATA SOURCES
# ============================================================================

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get VPC details
data "aws_vpc" "main" {
  id = var.vpc_id
}

# Get availability zones in the region
data "aws_availability_zones" "available" {
  state = "available"
}

# ============================================================================
# VPC & NETWORK CONFIGURATION
# ============================================================================

# Create Transit Gateway for multicloud connectivity
resource "aws_ec2_transit_gateway" "main" {
  description                     = "Transit Gateway for AWS-GCP Interconnect"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  amazon_side_asn                 = var.transit_gateway_asn

  tags = {
    Name = "${var.project_name}-tgw"
  }
}

# Attach VPC to Transit Gateway
resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids

  tags = {
    Name = "${var.project_name}-tgw-vpc-attachment"
  }

  depends_on = [aws_ec2_transit_gateway.main]
}

# ============================================================================
# DIRECT CONNECT SETUP
# ============================================================================

# Create Direct Connect Gateway (connects to Transit Gateway)
resource "aws_dx_gateway" "main" {
  name = "${var.project_name}-dcgw"

  tags = {
    Name = "${var.project_name}-dcgw"
  }
}

# Associate Direct Connect Gateway with Transit Gateway
resource "aws_dx_gateway_association" "tgw" {
  dx_gateway_id              = aws_dx_gateway.main.id
  associated_gateway_id      = aws_ec2_transit_gateway.main.id
  associated_gateway_owner_account_id = data.aws_caller_identity.current.account_id

  proposal_id = aws_dx_gateway_association_proposal.tgw.id

  depends_on = [
    aws_ec2_transit_gateway.main,
    aws_dx_gateway.main
  ]
}

# Create association proposal (need to accept from AWS side)
resource "aws_dx_gateway_association_proposal" "tgw" {
  dx_gateway_id             = aws_dx_gateway.main.id
  dx_gateway_owner_account_id = data.aws_caller_identity.current.account_id
  associated_gateway_id     = aws_ec2_transit_gateway.main.id

  depends_on = [aws_dx_gateway.main]
}

# ============================================================================
# AWS INTERCONNECT - MULTICLOUD SETUP
# ============================================================================

# Create multicloud interconnect (requesting connection to GCP)
resource "aws_ec2_network_interface" "interconnect" {
  # Note: Using aws_ec2_network_interface as placeholder
  # Actual Interconnect resource may differ based on AWS provider version
  
  tags = {
    Name = "${var.project_name}-interconnect-eni"
  }
}

# For current preview, create via custom resource or manual step
# In production, use aws_interconnect_multicloud when available

resource "null_resource" "aws_interconnect_create" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "Creating AWS Interconnect - Multicloud connection..."
      # Use AWS CLI for now (until Terraform provider is available)
      # aws ec2 create-multicloud-interconnect \
      #   --provider GCP \
      #   --source-region ${var.aws_region} \
      #   --destination-region ${var.gcp_region} \
      #   --bandwidth 1gbps \
      #   --dx-gateway-id ${aws_dx_gateway.main.id} \
      #   --gcp-project-id ${var.gcp_project_id}
      
      # For now, document the manual step
      echo "Step 1: Go to AWS Console > Direct Connect > AWS Interconnect"
      echo "Step 2: Click 'Create new multicloud Interconnect'"
      echo "Step 3: Select Google Cloud as provider"
      echo "Step 4: Select source region: ${var.aws_region}"
      echo "Step 5: Select destination region: ${var.gcp_region}"
      echo "Step 6: Attach to DX Gateway: ${aws_dx_gateway.main.id}"
      echo "Step 7: Enter GCP Project ID: ${var.gcp_project_id}"
      echo "Step 8: Note the ACTIVATION_KEY provided"
    EOT
  }
  
  depends_on = [aws_dx_gateway.main]
}

# ============================================================================
# SECURITY GROUPS & NETWORK CONFIGURATION
# ============================================================================

# Security group for multicloud traffic
resource "aws_security_group" "multicloud" {
  name        = "${var.project_name}-multicloud-sg"
  description = "Security group for AWS-GCP multicloud traffic"
  vpc_id      = var.vpc_id

  # Allow all traffic from GCP side (adjust CIDR as needed)
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.gcp_network_cidr]
    description = "Allow inbound from GCP network"
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = [var.gcp_network_cidr]
    description = "Allow UDP from GCP network"
  }

  # Allow outbound to GCP
  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = [var.gcp_network_cidr]
    description = "Allow all outbound to GCP"
  }

  tags = {
    Name = "${var.project_name}-multicloud-sg"
  }
}

# ============================================================================
# MONITORING & LOGGING
# ============================================================================

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "interconnect_flow_logs" {
  name              = "/aws/vpc/interconnect-flow-logs"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "${var.project_name}-flow-logs"
  }
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "vpc_flow_logs" {
  name = "${var.project_name}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for VPC Flow Logs
resource "aws_iam_role_policy" "vpc_flow_logs" {
  name = "${var.project_name}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.interconnect_flow_logs.arn}:*"
      }
    ]
  })
}

# VPC Flow Logs for multicloud traffic
resource "aws_flow_log" "interconnect" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs.arn
  log_destination = "${aws_cloudwatch_log_group.interconnect_flow_logs.arn}:*"
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id

  tags = {
    Name = "${var.project_name}-flow-logs"
  }
}

# CloudWatch Alarm for high bandwidth utilization
resource "aws_cloudwatch_metric_alarm" "high_bandwidth" {
  alarm_name          = "${var.project_name}-high-bandwidth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "BytesOut"
  namespace           = "AWS/DX"
  period              = 300
  statistic           = "Sum"
  threshold           = var.bandwidth_alert_threshold
  alarm_description   = "Alert when interconnect bandwidth exceeds threshold"

  dimensions = {
    ConnectionId = "placeholder"  # Will be updated after interconnect creation
  }
}

# ============================================================================
# OUTPUTS
# ============================================================================

output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.id
}

output "dx_gateway_id" {
  description = "ID of the Direct Connect Gateway"
  value       = aws_dx_gateway.main.id
}

output "security_group_id" {
  description = "ID of the multicloud security group"
  value       = aws_security_group.multicloud.id
}

output "vpc_flow_logs_group" {
  description = "Name of CloudWatch Log Group for VPC Flow Logs"
  value       = aws_cloudwatch_log_group.interconnect_flow_logs.name
}

output "setup_instructions" {
  description = "Manual setup steps for AWS Interconnect"
  value       = "See AWS Console > Direct Connect > AWS Interconnect to complete setup"
}
