# infrastructure/iam.tf

data "tls_certificate" "github_oidc" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_oidc.certificates[0].sha1_fingerprint]
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:graj902/penta-ai-skill-test:*"]
    }
  }
}

resource "aws_iam_role" "github_actions_deployer_role" {
  name               = "github-actions-eks-deployer-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
  description        = "IAM role for GitHub Actions to deploy to the EKS cluster"
}

# --- NEW SECTION TO ADD PERMISSIONS ---

# This is the IAM Policy that defines what the role is allowed to do.
resource "aws_iam_policy" "github_actions_eks_policy" {
  name        = "GitHubActionsEKSDeployPolicy"
  description = "Allows describing the EKS cluster to update kubeconfig"
  # This policy grants the single permission needed.
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "eks:DescribeCluster",
        Effect   = "Allow",
        Resource = module.eks.cluster_arn # Grabs the ARN from our EKS module output
      }
    ]
  })
}

# This resource ATTACHES the policy to the role.
resource "aws_iam_role_policy_attachment" "deployer_eks_policy_attach" {
  role       = aws_iam_role.github_actions_deployer_role.name
  policy_arn = aws_iam_policy.github_actions_eks_policy.arn
}

# --- END OF NEW SECTION ---

output "github_actions_deployer_role_arn" {
  description = "The ARN of the IAM role for GitHub Actions EKS deployment"
  value       = aws_iam_role.github_actions_deployer_role.arn
}