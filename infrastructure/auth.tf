# infrastructure/auth.tf

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = module.eks.node_role_arn # Get the node role ARN from the EKS module
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = [
          "system:bootstrappers",
          "system:nodes",
        ]
      },
      {
        rolearn  = aws_iam_role.github_actions_deployer_role.arn # Our deployer role
        username = "github-actions-deployer"
        groups   = [
          "system:masters", # Grant admin privileges
        ]
      }
    ])
  }
}
