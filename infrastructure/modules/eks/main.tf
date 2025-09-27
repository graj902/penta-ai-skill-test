# infrastructure/modules/eks/main.tf

# IAM Role for the EKS Cluster (Control Plane)
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project_name}-eks-cluster-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# IAM Role for the EKS Worker Nodes
resource "aws_iam_role" "eks_node_role" {
  name = "${var.project_name}-eks-node-role"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# --- Policies for the Worker Nodes ---
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}
resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}
resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}
resource "aws_iam_role_policy_attachment" "ssm_read_only_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  role       = aws_iam_role.eks_node_role.name
}
# --- End of Node Policies ---

# Create the EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

# --- Custom Security Group for Worker Nodes ---
resource "aws_security_group" "eks_node_sg" {
  name        = "${var.project_name}-eks-node-sg"
  description = "Security group for all nodes in the EKS cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # Allow nodes to communicate with each other
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
  
  # Allow control plane to communicate with nodes.
  ingress {
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    security_groups = [aws_eks_cluster.main.vpc_config[0].cluster_security_group_id]
  }

  tags = {
    Name = "${var.project_name}-node-sg"
  }
}
# --- End of Security Group ---

# --- Launch Template for Custom Security Group ---
resource "aws_launch_template" "eks_nodes" {
  name_prefix = "${var.project_name}-lt-"
  vpc_security_group_ids = [aws_security_group.eks_node_sg.id]
  lifecycle {
    create_before_destroy = true
  }
}
# --- End of Launch Template ---

# Create the EKS Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnet_ids

  instance_types = ["t3.small"]
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  # THIS IS THE CRITICAL PART that associates our custom security group
  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_read_only,
    aws_iam_role_policy_attachment.ssm_read_only_access,
  ]
}