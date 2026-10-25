//Declare CloudWatch event rule for FinOps Cost Intelligence
resource "aws_cloudwatch_event_rule" "finops_cost_intelligence_event_rule" {
  name                = var.cloudwatch_event_rule_name
  description         = "CloudWatch event rule for FinOps Cost Intelligence"
  schedule_expression = "cron(0 8 ? * MON *)"
}


//Declare CloudWatch event target for FinOps Cost Intelligence
resource "aws_cloudwatch_event_target" "finops_cost_intelligence_event_target" {
  rule      = aws_cloudwatch_event_rule.finops_cost_intelligence_event_rule.name
  target_id = "FinOpsCostIntelligenceLambda"
  arn       = aws_lambda_function.finops_cost_intelligence_lambda.arn
}


//Declare CloudWatch event permission for FinOps Cost Intelligence
resource "aws_lambda_permission" "finops_cost_intelligence_lambda_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.finops_cost_intelligence_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.finops_cost_intelligence_event_rule.arn
}