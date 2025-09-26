module "vpc" {
  source = "./modules/vpc" # Path to our VPC module

  # Pass variables to the module
  aws_region         = var.aws_region
  project_name       = var.project_name
  availability_zones = ["ap-south-1a", "ap-south-1b"]
  vpc_cidr_block     = "10.0.0.0/16" # Replace with your desired CIDR block
}

# infrastructure/main.tf

# ... (your existing module.vpc block should be above this) ...

module "eks" {
  source = "./modules/eks" # Path to our EKS module

  # Pass variables to the module
  cluster_name = var.project_name
  project_name = var.project_name

  # Connect the modules: Use outputs from the VPC module as inputs here
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
}
