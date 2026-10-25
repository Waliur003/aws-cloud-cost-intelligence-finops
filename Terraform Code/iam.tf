// Declare the provider block and specify the required version of the AWS provider
resource "aws_iam_role" "finops_cost_intelligence_lambda_role" {
  name = var.iam_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}


// Declare the IAM policy document for the FinOps Cost Intelligence Lambda function
data "aws_iam_policy_document" "finops_cost_intelligence_lambda_policy_document" {
  statement {
    sid    = "CostExplorerReadAccess"
    effect = "Allow"
    actions = [
      "ce:GetCostAndUsage",
      "ce:GetDimensionValues"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "S3DashboardWriteAccess"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.finops_cost_intelligence_bucket.arn}/*"] # Dynamic reference
  }

  statement {
    sid       = "SNSPublishAlertAccess"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.finops_cost_intelligence_topic.arn] # Dynamic reference
  }
}


// Declare the IAM policy for the FinOps Cost Intelligence Lambda function
resource "aws_iam_policy" "finops_cost_intelligence_lambda_policy" {
  name   = "FinOpsCostIntelligenceLambdaPolicy"
  policy = data.aws_iam_policy_document.finops_cost_intelligence_lambda_policy_document.json
}


// Attach the IAM policy to the FinOps Cost Intelligence Lambda function role
resource "aws_iam_role_policy_attachment" "finops_cost_intelligence_lambda_role_policy_attachment" {
  role       = aws_iam_role.finops_cost_intelligence_lambda_role.name
  policy_arn = aws_iam_policy.finops_cost_intelligence_lambda_policy.arn
}


// Attach the AWSLambdaBasicExecutionRole policy to the FinOps Cost Intelligence Lambda function role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.finops_cost_intelligence_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}