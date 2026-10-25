//Declare SNS topic for FinOps Cost Intelligence notifications
resource "aws_sns_topic" "finops_cost_intelligence_topic" {
  name = var.sns_topic_name
}


//Declare SNS topic subscription for FinOps Cost Intelligence notifications
resource "aws_sns_topic_subscription" "finops_cost_intelligence_subscription" {
  topic_arn = aws_sns_topic.finops_cost_intelligence_topic.arn
  protocol  = "email"
  endpoint  = var.notification_email
}


//Declare SNS topic policy for FinOps Cost Intelligence notifications to budgets.amazonaws.com
resource "aws_sns_topic_policy" "finops_cost_intelligence_topic_policy" {
  arn = aws_sns_topic.finops_cost_intelligence_topic.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "SNS:Publish"
        Resource  = aws_sns_topic.finops_cost_intelligence_topic.arn
      }
    ]
  })
}