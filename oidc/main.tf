terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

variable "aws_region" {
  description = "The AWS region to create resources in"
  default     = "us-west-2"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket to create"
}

variable "role_name" {
  description = "The name of the IAM role for GitHub Actions"
  default     = "github-actions-oidc-role"
}

variable "repositories" {
  description = "List of GitHub repositories to grant access to"
  type        = list(string)
}

provider "aws" {
  region = var.aws_region
}

# aws account id
data "aws_caller_identity" "current" {}

# create policy
resource "aws_iam_policy" "github_actions" {
  name        = "github-actions-policy"
  description = "Policy for GitHub Actions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListAndDescribe"
        Effect = "Allow"
        Action = [
          "dynamodb:List*",
          "dynamodb:DescribeReservedCapacity*",
          "dynamodb:DescribeLimits",
          "dynamodb:DescribeTimeToLive"
        ]
        Resource = "*"
      },
      {
        Sid    = "SpecificTable"
        Effect = "Allow"
        Action = [
          "dynamodb:BatchGet*",
          "dynamodb:DescribeStream",
          "dynamodb:DescribeTable",
          "dynamodb:Get*",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWrite*",
          "dynamodb:CreateTable",
          "dynamodb:Delete*",
          "dynamodb:Update*",
          "dynamodb:PutItem"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/DiggerDynamoDBLockTable"
      }
    ]
  })
}

module "github-oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "~> 1"

  create_oidc_provider = true
  create_oidc_role     = true

  repositories = var.repositories

  oidc_role_attach_policies = [
    aws_iam_policy.github_actions.arn
  ]
}

################################################################################
# OUTPUTS
################################################################################
output "oidc_provider_arn" {
  description = "OIDC provider ARN"
  value       = module.github-oidc.oidc_provider_arn
}

output "github_oidc_role_arn" {
  description = "CICD GitHub role."
  value       = module.github-oidc.oidc_role
}