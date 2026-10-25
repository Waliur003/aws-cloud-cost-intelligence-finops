//Declare Lambda function for FinOps Cost Intelligence
resource "aws_lambda_function" "finops_cost_intelligence_lambda" {
  function_name    = var.lambda_function_name
  role             = aws_iam_role.finops_cost_intelligence_lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")
  architectures    = ["x86_64"]
  timeout          = 30

  environment {
    variables = {
      BUCKET_NAME   = var.s3_bucket_name
      SNS_TOPIC_ARN = aws_sns_topic.finops_cost_intelligence_topic.arn
    }
  }



}