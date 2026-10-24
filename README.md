# Cloud Engineering Project 11: Automated Cloud Cost Intelligence & FinOps Alerting System (Serverless Billing Analytics, Proactive Budgets & S3 Static Dashboard)

---

## Overview

I architected and deployed an automated, serverless **FinOps monitoring and proactive alerting engine on AWS** designed to eliminate surprise cloud billing overruns and give engineering teams real-time visibility into trailing infrastructure spend.

Built according to AWS Well-Architected Framework cost optimization best practices, this project combines proactive guardrails with automated scheduled telemetry.

The system uses **AWS Budgets** and **Amazon CloudWatch** to establish baseline spend limits and trigger instantaneous notifications through **Amazon Simple Notification Service (SNS)** when actual or forecasted costs cross defined thresholds.

Operating in parallel, an event-driven **AWS Lambda** function running Python 3.12 and Boto3 executes on an automated **Amazon EventBridge** cron schedule. The function queries the **AWS Cost Explorer API** for trailing 7-day expenditures grouped across all active AWS services.

The function then:

- Filters inactive `$0.00` line items
- Structures the billing dataset
- Generates executive cost summaries
- Publishes notifications through Amazon SNS
- Writes a dynamic `data.json` payload into an Amazon S3 static website bucket

The entire dashboard operates without persistent servers.

---

## The Problem

### 1. Unpredictable Cloud Incurrence & Invoice Shocks

AWS charges for more than 200 services across multiple billing dimensions, including:

- Per-second compute runtime
- Storage volume tiers
- Data transfer egress
- API invocation counts
- Managed service consumption

Without real-time spending observability, organizations may only discover runaway resources or misconfigurations after receiving an unexpectedly large invoice at the end of the month.

### 2. Delayed & Passive Cost Visibility

Traditional billing workflows require engineers to manually log into the AWS Billing Console and inspect historical reports.

Because this process is passive and retrospective, temporary infrastructure mistakes such as:

- Unused EC2 instances
- Unattached Elastic IP addresses
- Overprovisioned databases
- Forgotten load balancers
- Unoptimized storage

can continue generating charges for days or weeks before being discovered.

### 3. Server Provisioning Overhead for Internal Tooling

Running dedicated EC2 instances or persistent servers solely to host an internal cost-monitoring dashboard introduces:

- Continuous compute costs
- OS patching requirements
- Additional attack surface
- Administrative maintenance

This conflicts directly with the objective of FinOps efficiency.

---

## The Solution

### Automated Multi-Service Cost Aggregation

Implemented an event-driven AWS Lambda function using the **AWS Boto3 SDK** to query:

```text
ce:GetCostAndUsage
```

The function programmatically:

- Retrieves daily cost data
- Uses a trailing 7-day reporting window
- Filters inactive `$0.00` services
- Groups expenditure by AWS service
- Calculates total spending
- Sorts services by highest cost

### Dual-Layer Proactive Alerting & Budget Guardrails

Configured an AWS Budget named:

```text
monthly-overall-budget
```

with automated threshold boundaries:

```text
80% Actual Spend
100% Forecasted Spend
```

When spending thresholds are reached, AWS Budgets publishes alerts to:

```text
cost-alert-topic
```

through Amazon SNS.

### Serverless, Zero-Maintenance Architecture

Eliminated persistent compute infrastructure by separating analytics from presentation.

The solution uses:

```text
AWS Lambda
    |
    +--> AWS Cost Explorer
    |
    +--> Amazon SNS
    |
    +--> Amazon S3
```

Lambda performs cost calculations only when invoked, while Amazon S3 hosts the user-facing dashboard.

### Executive Client-Side Telemetry Visualization

Built a lightweight web dashboard using:

- HTML5
- CSS3
- JavaScript
- Fetch API

The frontend asynchronously retrieves:

```text
data.json
```

and dynamically displays:

- Total 7-day AWS spend
- Billing period
- Service-by-service costs
- Descending cost distribution

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Cost Ingestion & Analytics** | AWS Cost Explorer API (`ce:GetCostAndUsage`), AWS Billing Management |
| **Budgeting & Guardrails** | AWS Budgets (`monthly-overall-budget`), Amazon CloudWatch Billing Alerts |
| **Notification Engine** | Amazon SNS (`cost-alert-topic`) |
| **Compute & Automation** | AWS Lambda (`cost-report-generator`, Python 3.12, Boto3 SDK) |
| **Event Scheduling** | Amazon EventBridge (`weekly-cost-trigger`) |
| **Static Storage & Hosting** | Amazon S3 (`cloud-cost-dashboard-sun-2026`) |
| **Identity & Access Management** | AWS IAM Least-Privilege Roles & Policies |
| **Frontend Dashboard** | HTML5, JavaScript Fetch API, CSS3 Grid/Flexbox |
| **Infrastructure as Code** | HashiCorp Terraform |

---

## Architecture Diagram

<img width="1370" height="893" alt="Architecture Diagram" src="https://github.com/user-attachments/assets/cf021b4d-2d10-4c21-83c4-440c67ef7c80" />


---

## Project Procedure

### 1. Ingestion Preferences & Notification Fabric

#### Enabling Billing Metrics

Accessed AWS Billing Preferences to verify:

- Free Tier alerts
- CloudWatch billing alert delivery

#### Cost Explorer Initialization

Activated AWS Cost Explorer to enable:

- Historical usage tracking
- Dimensional grouping
- API data extraction
- Service-level billing analysis

#### SNS Alert Bus Construction

Provisioned an Amazon SNS Standard topic:

```text
cost-alert-topic
```

Topic ARN:

```text
arn:aws:sns:us-east-1:418272769771:cost-alert-topic
```

Created an email protocol subscription and completed the verification handshake.

#### AWS Budget Deployment

Configured a monthly fixed recurring cost budget:

```text
monthly-overall-budget
```

with an automated alert threshold at:

```text
80% Actual Spend
```

and mapped the notification directly to the SNS topic.

---

### 2. Least-Privilege IAM Execution Architecture

#### Role Provisioning

Created:

```text
CostCalculatorLambdaRole
```

with a trust relationship restricted to:

```text
lambda.amazonaws.com
```

#### Managed Policy Attachment

Attached:

```text
AWSLambdaBasicExecutionRole
```

for CloudWatch log stream delivery.

#### Granular Inline Permissions

Created:

```text
CostCalculatorPermissionsPolicy
```

with least-privilege permissions.

Cost Explorer read permissions:

```text
ce:GetCostAndUsage
ce:GetDimensionValues
```

S3 write permissions:

```text
s3:PutObject
```

scoped to:

```text
arn:aws:s3:::cloud-cost-dashboard-sun-2026/*
```

SNS permissions:

```text
sns:Publish
```

scoped to:

```text
arn:aws:sns:us-east-1:418272769771:cost-alert-topic
```

---

### 3. Serverless Aggregator & Analytics Engine

Deployed the Lambda function:

```text
cost-report-generator
```

Runtime configuration:

```text
Runtime: Python 3.12
SDK: Boto3
Timeout: 30 seconds
```

Environment variables:

```text
BUCKET_NAME=cloud-cost-dashboard-sun-2026
SNS_TOPIC_ARN=arn:aws:sns:us-east-1:418272769771:cost-alert-topic
```

The Lambda logic:

1. Calculates a rolling 7-day reporting window
2. Queries Cost Explorer
3. Retrieves unblended AWS costs
4. Groups data by service
5. Removes zero-cost services
6. Rounds active amounts to two decimal points
7. Generates SNS cost summaries
8. Serializes the report into JSON
9. Writes `data.json` into Amazon S3

---

### 4. S3 Static Web Hosting & Frontend Delivery

Provisioned the bucket:

```text
cloud-cost-dashboard-sun-2026
```

Region:

```text
us-east-1
```

Configured static website hosting with:

```text
index.html
```

as the root document.

The frontend asynchronously retrieves:

```text
data.json
```

using JavaScript:

```text
fetch()
```

The browser dynamically renders:

- Total AWS expenditure
- Billing period
- Active AWS services
- Sorted service costs

---

### 5. EventBridge Automated Cron Scheduling

Provisioned the EventBridge rule:

```text
weekly-cost-trigger
```

Schedule:

```text
cron(0 8 ? * MON *)
```

This automatically triggers the cost-reporting Lambda function every Monday.

Lambda resource-based permissions grant:

```text
events.amazonaws.com
```

permission to invoke the function from the specific EventBridge rule.

---

## Infrastructure as Code (IaC) Architecture

To ensure repeatable and immutable provisioning, the complete FinOps monitoring pipeline is designed to be deployed through modular Terraform configuration.

```text
terraform-aws-cost-calculator/
├── main.tf              # Provider configuration, AWS backend, and global tags
├── variables.tf         # Abstracted parameters (email, budget threshold, bucket name)
├── sns.tf               # SNS topic, email subscription, and access policy
├── budgets.tf           # AWS Budget definition and notification thresholds
├── iam.tf               # Lambda execution role, CloudWatch logging, and inline policy
├── lambda.tf            # Lambda function, code archive, and environment variables
├── s3.tf                # S3 bucket, website configuration, public access settings, and policy
├── eventbridge.tf       # EventBridge cron rule, target binding, and Lambda invoke permission
└── outputs.tf           # S3 website URL, Lambda ARN, and SNS topic ARN
```

---

## Detailed File-by-File Technical Breakdown

### `main.tf`

Initializes the HashiCorp AWS provider:

```text
hashicorp/aws ~> 5.0
```

Target region:

```text
us-east-1
```

Default resource tags:

```text
Environment = "Production"
Project     = "FinOps-Cost-Intelligence"
```

### `variables.tf`

Parameterizes inputs including:

```text
alert_email
monthly_budget_amount
bucket_name
```

Default monthly budget:

```text
10.0
```

### `sns.tf`

Provisions:

```text
aws_sns_topic
aws_sns_topic_subscription
```

using the email subscription protocol.

### `budgets.tf`

Defines:

```text
aws_budgets_budget
```

with:

```text
budget_type = "COST"
time_unit   = "MONTHLY"
```

and SNS notification thresholds.

### `iam.tf`

Implements:

```text
aws_iam_role
```

with an assume-role policy for:

```text
lambda.amazonaws.com
```

Attaches:

```text
AWSLambdaBasicExecutionRole
```

and adds scoped permissions for:

- Cost Explorer
- S3
- SNS

### `lambda.tf`

Uses:

```text
archive_file
```

to package:

```text
lambda_function.py
```

and configures:

```text
aws_lambda_function
runtime = python3.12
timeout = 30
```

with required environment variables.

### `s3.tf`

Provisions:

```text
aws_s3_bucket
aws_s3_bucket_website_configuration
aws_s3_bucket_public_access_block
aws_s3_object
aws_s3_bucket_policy
```

The configuration hosts both:

```text
index.html
data.json
```

### `eventbridge.tf`

Defines:

```text
aws_cloudwatch_event_rule
```

with:

```text
schedule_expression = "cron(0 8 ? * MON *)"
```

and binds the Lambda through:

```text
aws_cloudwatch_event_target
aws_lambda_permission
```

### `outputs.tf`

Exports:

```text
dashboard_website_endpoint
sns_topic_arn
lambda_function_arn
```

---

## Technical Difficulties Faced & Engineering Resolutions

### Challenge 1: S3 Bucket Policy Rejection Due to Active Block Public Access

#### Root Cause Analysis

When attempting to apply the public read bucket policy:

```text
s3:GetObject
```

AWS returned:

```text
Your bucket policy changes can't be saved because Block Public Access settings are turned on
```

AWS prevents public policies from attaching while bucket-level Block Public Access remains enabled.

#### Architectural Resolution

Navigated to:

```text
S3
→ Bucket
→ Permissions
→ Block Public Access
```

Disabled the bucket-level setting, confirmed the change, and then applied the public read bucket policy.

---

### Challenge 2: AWS Budgets ARN Rejection in Standard Email Input

#### Root Cause Analysis

Pasting the SNS ARN into the standard AWS Budgets notification input generated:

```text
Invalid email address detected
```

The primary field expected an RFC-compliant email address.

#### Architectural Resolution

Expanded:

```text
Amazon SNS Alerts - Optional
```

and entered:

```text
arn:aws:sns:us-east-1:418272769771:cost-alert-topic
```

into the dedicated SNS Topic ARN field.

---

### Challenge 3: Lambda Invocation Timeout on Cost Explorer API Aggregations

#### Root Cause Analysis

The default Lambda timeout of 3 seconds was insufficient for:

```text
ce.get_cost_and_usage()
```

because retrieving and aggregating service-level cost metrics required approximately 1.5 to 4 seconds.

#### Architectural Resolution

Increased the Lambda timeout from:

```text
3 seconds
```

to:

```text
30 seconds
```

providing sufficient execution buffer for Cost Explorer queries, data processing, SNS publishing, and S3 object writes.

---

### Challenge 4: Client-Side Dashboard Blank Rendering Due to 0-Byte Payload Upload

#### Root Cause Analysis

The public S3 static website initially displayed a blank page.

Inspection showed:

```text
index.html = 0 B
```

because an unsaved local file buffer had been uploaded.

#### Architectural Resolution

Populated `index.html` with the frontend interface, verified the local file size at approximately:

```text
2.4 KB
```

re-uploaded the file to S3, and performed a hard browser refresh:

```text
Ctrl + F5
```

The dashboard rendered correctly afterward.

---

## Verification and Results

### Verified Cost Explorer Metrics Aggregation

The Lambda function successfully invoked AWS Cost Explorer and grouped active service expenditure across the reporting window.

```text
Execution Status: Succeeded
HTTP Status: 200

Reporting Window:
2026-10-17 to 2026-10-24

Aggregated 7-Day Spend:
$0.34
```

Top active services:

| AWS Service | 7-Day Cost |
|---|---:|
| AWS Key Management Service | $0.23 |
| Amazon Elastic Load Balancing | $0.05 |
| Amazon Relational Database Service | $0.03 |
| EC2 - Other | $0.02 |
| Amazon Virtual Private Cloud | $0.02 |
| Amazon Elastic Container Service | $0.01 |

### Confirmed Real-Time SNS Push Telemetry

Lambda execution tests verified that Amazon SNS successfully delivered automated cost reports to subscribed administrator inboxes.

The notification included:

- Reporting window
- Total AWS spend
- Highest-cost services
- Service-by-service breakdown

### Validated S3 Dynamic Data Persistence

The Lambda execution successfully generated:

```text
data.json
```

and uploaded it to:

```text
s3://cloud-cost-dashboard-sun-2026/data.json
```

with:

```text
ContentType: application/json
```

### Validated Live Public Dashboard Endpoint

The S3 static website successfully rendered:

- 7-day total spend
- Active billing period
- Service breakdown
- Descending cost distribution

Website endpoint:

```text
http://cloud-cost-dashboard-sun-2026.s3-website-us-east-1.amazonaws.com
```

---

## Verification Screenshots

### 1. AWS Billing Preferences & Active Cost Explorer Analysis Console

Displays the AWS Billing Preferences console confirming active **Free Tier alerts** and **CloudWatch billing alerts**, alongside the AWS Cost Explorer analysis interface showing historical expenditures grouped across active AWS services.

This validates that account-level billing telemetry and Cost Explorer reporting are enabled before automated FinOps analytics are executed.

<img width="1640" height="1371" alt="Screenshot 1" src="https://github.com/user-attachments/assets/1c5fea24-6577-464d-a308-fa687c1a560e" />


### 2. Amazon SNS Alerts Configuration within AWS Budgets

Shows the AWS Budgets threshold configuration screen with the alert routed to:

```text
arn:aws:sns:us-east-1:418272769771:cost-alert-topic
```

through the dedicated Amazon SNS Alerts configuration.

This verifies that budget threshold events are connected directly to the centralized notification pipeline.

<img width="1701" height="883" alt="Screenshot 2" src="https://github.com/user-attachments/assets/65c6c43b-929f-4c0e-aa45-b3d73359af56" />


### 3. S3 Bucket Public Access Block Configuration & Bucket Policy

Displays the Permissions configuration for:

```text
cloud-cost-dashboard-sun-2026
```

showing that Block Public Access has been disabled and the public:

```text
s3:GetObject
```

bucket policy has been applied.

This verifies that the static website objects can be retrieved through the configured public S3 website endpoint.

<img width="1253" height="748" alt="Screenshot 3" src="https://github.com/user-attachments/assets/1aa45ea5-013a-4a3e-92e8-398698cb111a" />


### 4. AWS Lambda Execution Test Returning HTTP 200 & Cost Breakdown

Shows a successful execution of:

```text
cost-report-generator
```

inside the AWS Lambda console with:

```text
Status: Succeeded
HTTP 200
```

and the generated cost report showing:

```text
7-Day Spend: $0.34
```

This validates Cost Explorer querying, aggregation logic, and successful serverless execution.

<img width="1311" height="674" alt="Screenshot 4" src="https://github.com/user-attachments/assets/d88bc967-f980-434c-8023-40996f9341ab" />


### 5. Live S3 Static Dashboard Rendering Real-World AWS Expenditures

Shows the browser-based cost dashboard hosted from the S3 static website endpoint.

The dashboard displays:

```text
7-Day Total Spend: $0.34
```

alongside descending cost distribution across:

- AWS KMS
- Elastic Load Balancing
- Amazon RDS
- EC2
- Amazon VPC
- Amazon ECS

This confirms the complete end-to-end workflow from Cost Explorer data ingestion through Lambda processing, S3 persistence, and browser visualization.

<img width="1919" height="896" alt="Screenshot 5" src="https://github.com/user-attachments/assets/0fab98c2-3fab-4197-8af4-71cef948b3a6" />


---

## Future Improvements

### S3 Secure Distribution with CloudFront & Route 53

Front the static S3 dashboard with Amazon CloudFront to:

- Enforce HTTPS with AWS Certificate Manager
- Remove direct public S3 access
- Use Origin Access Control
- Enable edge caching
- Attach a custom Route 53 domain

### Anomaly Detection Integration

Integrate **AWS Cost Anomaly Detection** with Amazon SNS to identify statistical cost anomalies independently of fixed monthly budget thresholds.

### Multi-Account AWS Organizations Aggregation

Extend the Lambda function to support AWS Organizations environments by assuming cross-account IAM roles.

This would enable centralized FinOps monitoring across:

```text
Production Account
Staging Account
Development Account
Sandbox Account
Shared Services Account
```

from a single management environment.

---

## Cost Analysis (FinOps Footprint)

Because the primary objective of this architecture is cost control, the monitoring system itself was engineered to run with near-zero operating overhead by strictly leveraging serverless, event-driven primitives:

| Service Component | Usage Metric / Allocation | Monthly Estimated Cost |
|---|---|---|
| **AWS Cost Explorer API** | 4-5 paginated API calls/month (1 weekly invocation) at $0.01/call | ~$0.04 - $0.05 |
| **AWS Budgets** | 1 Active Monthly Budget (`monthly-overall-budget`) | $0.00 (Standard usage included) |
| **AWS Lambda** | 4-5 executions/month, 128 MB memory, ~1.5s average duration | $0.00 (Well within 1M Free Tier requests) |
| **Amazon S3 (Hosting)** | < 10 KB storage (`index.html` + `data.json`), ~50 GET requests/month | $0.00 (Negligible storage/transfer) |
| **Amazon SNS** | 4-8 emails/month (Weekly digests + alerts) | $0.00 (First 1,000 emails/month free) |
| **Amazon EventBridge** | 1 scheduled cron rule (4-5 event dispatches/month) | $0.00 (Standard schedule rules are free) |
| **Amazon CloudWatch Logs** | Ingestion of Lambda execution logs (< 5 MB/month) | $0.00 (Within 5 GB log ingestion Free Tier) |
| **Total Monthly Operating Cost** | **Fully Functional FinOps Telemetry Engine** | **~$0.04 - $0.05 / month** |

### FinOps ROI
By spending **less than $0.05 per month**, this pipeline eliminates the need for a dedicated monitoring EC2 instance (which would cost upwards of $3.50–$10.00/month for a `t3.nano` or `t3.micro`) while protecting the AWS account against runaway cloud charges that could easily scale into hundreds or thousands of dollars.

---

## Monitoring, Alerting & Observability Framework

The operational integrity of this pipeline is governed by multi-tier observability, automated health tracking, and push-based delivery:

### 1. Compute & API Telemetry (Amazon CloudWatch)
* **Log Stream Ingestion:** All runtime executions, API responses, and exception stack traces are streamed to the `/aws/lambda/cost-report-generator` CloudWatch Log Group.
* **Execution Metrics:** Lambda execution performance is monitored via native CloudWatch metrics:
  * `Duration`: Tracks execution time (consistently averaging 1,000ms–1,500ms).
  * `Errors`: Tracks execution exceptions (e.g., IAM permission rejections or Cost Explorer throttling).
  * `Invocations`: Confirms triggered executions dispatched by the EventBridge schedule.

### 2. Event-Driven Alert Delivery (Amazon SNS)
* **Real-Time Threshold Escalation:** AWS Budgets dispatches instantaneous alerts to `cost-alert-topic` if actual account spend crosses 80% or forecasted spend hits 100%, bypassing manual dashboard checks entirely.
* **Weekly Push Digest:** Every Monday at 08:00 UTC, Lambda publishes a formatted email digest detailing total spend and top active cost drivers directly to subscribed administrator inboxes.

### 3. Client-Side Telemetry & Fail-Safe State (S3 & Web Frontend)
* **Visual Status Flags:** If `data.json` fails to generate or cannot be reached, `index.html` dynamically transitions from loading states to a distinct red warning notification (`data.json not found yet`), alerting operators to inspect backend execution logs.
* **Direct Payload Inspection:** Administrators can verify object freshness by querying the S3 REST endpoint or validating object metadata timestamps directly in the AWS S3 console.

---

## Technical Skills Demonstrated

### AWS FinOps

- AWS Cost Explorer API
- AWS Budgets
- Cost aggregation
- Forecasted spend monitoring
- Billing threshold alerting
- Service-level cost attribution

### Serverless Engineering

- AWS Lambda
- Python 3.12
- Boto3
- Amazon EventBridge
- Event-driven architecture
- Scheduled workloads

### Cloud Storage & Web Delivery

- Amazon S3
- Static Website Hosting
- JSON object persistence
- HTML5
- CSS3
- JavaScript Fetch API

### Security & IAM

- IAM service roles
- Least-privilege policy design
- Resource-scoped S3 permissions
- Scoped SNS publishing
- Lambda trust policies

### Infrastructure as Code

- Terraform
- Modular Terraform architecture
- Provider configuration
- Variables and outputs
- IAM resource provisioning
- Serverless infrastructure deployment

---

## Notes

This project demonstrates an enterprise approach to FinOps by combining proactive budgeting guardrails with automated serverless analytics.

It emphasizes core competencies in:

- Cost Explorer API consumption
- Decoupled event-driven architecture
- IAM least-privilege scoping
- Automated cron scheduling
- Serverless web delivery
- Proactive cloud financial governance

The architecture avoids persistent virtual machine infrastructure, reducing both infrastructure cost and operational maintenance.

---

## Bottom Line

The **Automated Cloud Cost Intelligence & FinOps Alerting System** delivers financial visibility and proactive budget enforcement across AWS cloud environments.

By combining **AWS Budgets**, **Amazon SNS**, **AWS Lambda**, **Amazon EventBridge**, **AWS Cost Explorer**, and **Amazon S3**, the architecture creates a fully serverless FinOps monitoring platform capable of automatically collecting cost data, notifying engineers, persisting telemetry, and presenting spending information through a lightweight web dashboard without requiring continuously running servers.
