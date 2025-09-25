terraform {
  backend "s3" {
    bucket         = "penta-ai-skill-test-506776019563-ap-south-1-tfstate"
    key            = "global/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
