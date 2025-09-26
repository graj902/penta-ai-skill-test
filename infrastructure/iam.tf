# infrastructure/iam.tf

# This data source dynamically fetches the required security certificate from GitHub.
data "tls_certificate" "github_oidc" {
  url = "https://token.actions.githubusercontent.com"
}

# This resource creates the IAM OIDC Identity Provider in your AWS account.
# This is a one-time setup that allows AWS to trust GitHub Actions.
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_oidc.certificates[0].sha1_fingerprint]
}

data "aws_caller_identity" "current" {}

# This is the trust policy for our deployer role.
data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      # It now correctly points to the ARN of the OIDC provider we just created.
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    # This condition is a critical security step. It ensures ONLY your
    # repository can assume this role.
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      # =======================================================================
      # !!! IMPORTANT !!! 
      # Change "gururaj-penta-ai" to your actual GitHub username.
      # =======================================================================
      values   = ["repo:graj902/penta-ai-skill-test:*"]
    }
  }
}

# This is the IAM role that GitHub Actions will assume.
resource "aws_iam_role" "github_actions_deployer_role" {
  name               = "github-actions-eks-deployer-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
  description        = "IAM role for GitHub Actions to deploy to the EKS cluster"
}

# This is the output for the role ARN, which is used in the GitHub secret.
output "github_actions_deployer_role_arn" {
  description = "The ARN of the IAM role for GitHub Actions EKS deployment"
  value       = aws_iam_role.github_actions_deployer_role.arn
}