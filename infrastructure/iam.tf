# infrastructure/iam.tf

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      # This ARN points to the OIDC provider that GitHub Actions uses
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"]
    }
    # This condition scopes the permission down to your specific GitHub repository
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:graj902/penta-ai-skill-test:*"] # <-- IMPORTANT: Change this!
    }
  }
}

resource "aws_iam_role" "github_actions_deployer_role" {
  name               = "github-actions-eks-deployer-role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json
  description        = "IAM role for GitHub Actions to deploy to the EKS cluster"
}

output "github_actions_deployer_role_arn" {
  description = "The ARN of the IAM role for GitHub Actions EKS deployment"
  value       = aws_iam_role.github_actions_deployer_role.arn
}