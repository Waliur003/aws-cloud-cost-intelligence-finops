import os
import json
import boto3
from datetime import datetime, timedelta

ce = boto3.client('ce')
s3 = boto3.client('s3')
sns = boto3.client('sns')

BUCKET_NAME = os.environ.get('BUCKET_NAME')
SNS_TOPIC_ARN = os.environ.get('SNS_TOPIC_ARN')

def lambda_handler(event, context):
    end_date = datetime.utcnow().date()
    start_date = end_date - timedelta(days=7)
    
    # Query Cost Explorer grouped by service
    response = ce.get_cost_and_usage(
        TimePeriod={
            'Start': start_date.strftime('%Y-%m-%d'),
            'End': end_date.strftime('%Y-%m-%d')
        },
        Granularity='DAILY',
        Metrics=['UnblendedCost'],
        GroupBy=[{'Type': 'DIMENSION', 'Key': 'SERVICE'}]
    )
    
    service_costs = {}
    total_spend = 0.0
    
    for day in response.get('ResultsByTime', []):
        for group in day.get('Groups', []):
            service = group['Keys'][0]
            amount = float(group['Metrics']['UnblendedCost']['Amount'])
            service_costs[service] = service_costs.get(service, 0.0) + amount
            total_spend += amount
            
    # Filter out $0.00 items
    active_services = {k: round(v, 2) for k, v in service_costs.items() if round(v, 2) > 0.00}
    
    payload = {
        "startDate": str(start_date),
        "endDate": str(end_date),
        "totalCost": round(total_spend, 2),
        "breakdown": active_services
    }
    
    # Write report directly to S3 dashboard as data.json
    if BUCKET_NAME:
        s3.put_object(
            Bucket=BUCKET_NAME,
            Key='data.json',
            Body=json.dumps(payload, indent=2),
            ContentType='application/json'
        )
        
    # Send weekly summary notification
    if SNS_TOPIC_ARN:
        message = f"Weekly AWS Spend ({start_date} to {end_date}): ${total_spend:.2f}\n\nTop Services:\n"
        for s, c in sorted(active_services.items(), key=lambda x: x[1], reverse=True)[:5]:
            message += f"- {s}: ${c:.2f}\n"
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject=f"AWS Cost Summary: ${total_spend:.2f}",
            Message=message
        )
        
    return {
        "statusCode": 200,
        "body": json.dumps(payload)
    }