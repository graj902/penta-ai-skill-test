# This file defines VPC endpoints for secure, private communication to AWS services.

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.ssm"
  vpc_endpoint_type = "Interface"
  
  # Place the endpoint network interfaces in our private subnets
  subnet_ids = module.vpc.private_subnet_ids

  # Attach a dedicated security group to the endpoint
  security_group_ids = [aws_security_group.ssm_endpoint_sg.id]
  
  # This allows the standard ssm.region.amazonaws.com DNS name to resolve to the private endpoint IPs
  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-ssm-vpc-endpoint"
  }
}

# This security group allows the EKS nodes to communicate with the SSM endpoint
resource "aws_security_group" "ssm_endpoint_sg" {
  name   = "${var.project_name}-ssm-endpoint-sg"
  vpc_id = module.vpc.vpc_id
  description = "Allow EKS nodes to access the SSM VPC endpoint"

  # Allow ingress from the EKS nodes on HTTPS (port 443)
  ingress {
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    # This is the security group used by the EKS control plane and nodes
    security_groups = [module.eks.cluster_security_group_id]
  }

  tags = {
    Name = "${var.project_name}-ssm-endpoint-sg"
  }
}
