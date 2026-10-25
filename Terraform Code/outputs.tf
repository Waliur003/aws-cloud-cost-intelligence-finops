output "sns_topic_arn" {
  value       = aws_sns_topic.finops_cost_intelligence_topic.arn
  description = "The ARN of the SNS topic for FinOps Cost Intelligence notifications"
}

output "lambda_function_arn" {
  value       = aws_lambda_function.finops_cost_intelligence_lambda.arn
  description = "The ARN of the Lambda function for FinOps Cost Intelligence"
}



output "s3_dashboard_url" {
  value       = "http://${aws_s3_bucket_website_configuration.finops_cost_intelligence_bucket_website_configuration.website_endpoint}"
  description = "The public website URL of the S3 dashboard"
}