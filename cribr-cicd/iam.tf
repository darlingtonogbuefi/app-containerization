# cribr-cicd\iam.tf

#############################################
# IAM Roles for CI/CD
#############################################

#############################################
# CodeBuild Role
#############################################

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.project_name}-codebuild-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # CloudWatch Logging
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      # S3 Artifacts Access
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = "*"
      },
      # ECR Docker Image Push/Pull
      {
        Effect = "Allow",
        Action = [
          "ecr:*"
        ]
        Resource = "*"
      },
      # EKS + AssumeRole
      {
        Effect = "Allow",
        Action = [
          "eks:*",
          "sts:AssumeRole"
        ],
        "Resource": "*"
      },
      # Allow specifically assuming the cribr-cicd-role
      {
        Effect = "Allow",
        Action = "sts:AssumeRole",
        Resource = "arn:aws:iam::493834426110:role/cribr-cicd-role"
      },
      # Secrets Manager access
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:*"
        ]
        Resource = "*"
      },
      # Deployment Access (ECS, Lambda, CloudFormation)
      {
        Effect = "Allow",
        Action = [
          "ecs:*",
          "lambda:*",
          "cloudformation:*"
        ]
        Resource = "*"
      },
      # IAM PassRole
      {
        Effect = "Allow",
        Action = "iam:PassRole"
        Resource = "*"
      },
      # KMS access if secrets or artifacts are encrypted
      {
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}
