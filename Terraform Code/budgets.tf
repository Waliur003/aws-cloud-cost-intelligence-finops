//Declare AWS Budget resource for FinOps Cost Intelligence
resource "aws_budgets_budget" "finops_cost_intelligence_budget" {
  name         = var.budget_name
  budget_type  = "COST"
  limit_amount = "10.00"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator = "GREATER_THAN"
    notification_type   = "ACTUAL"
    threshold           = 80
    threshold_type      = "PERCENTAGE"

    #notification with SNS notification arn
    subscriber_sns_topic_arns = [aws_sns_topic.finops_cost_intelligence_topic.arn]
  }
}