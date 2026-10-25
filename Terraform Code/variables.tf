//Declare AWS region variable
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

//Declare SNS topic name variable
variable "sns_topic_name" {
  description = "The name of the SNS topic for FinOps Cost Intelligence notifications"
  type        = string
  default     = "cost-alert-topic"
}

//Declare notification email variable
variable "notification_email" {
  description = "The email address to receive FinOps Cost Intelligence notifications"
  type        = string
  default     = "waliurrahmansun003@gmail.com"
}


//Declare AWS budget name variable
variable "budget_name" {
  description = "The name of the AWS budget for FinOps Cost Intelligence"
  type        = string
  default     = "monthly-overall-budget"
}


//Declare S3 bucket name variable
variable "s3_bucket_name" {
  description = "The name of the S3 bucket for FinOps Cost Intelligence"
  type        = string
  default     = "cloud-cost-dashboard-sun-2026"
}


//Declare IAM role name variable
variable "iam_role_name" {
  description = "The name of the IAM role for FinOps Cost Intelligence"
  type        = string
  default     = "CostCalculatorLambdaRole"
}


//Declare Lambda function name variable
variable "lambda_function_name" {
  description = "The name of the Lambda function for FinOps Cost Intelligence"
  type        = string
  default     = "cost-report-generator"
}


//Declare CloudWatch event rule name variable
variable "cloudwatch_event_rule_name" {
  description = "The name of the CloudWatch event rule for FinOps Cost Intelligence"
  type        = string
  default     = "weekly-cost-trigger"
}