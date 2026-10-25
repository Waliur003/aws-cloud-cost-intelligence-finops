// Declare the provider block and specify the required version of the AWS provider
resource "aws_s3_bucket" "finops_cost_intelligence_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Project   = "FinOps-Cost-Intelligence"
    ManagedBy = "Terraform"
  }
}


// Declare the S3 bucket website configuration for the FinOps Cost Intelligence bucket
resource "aws_s3_bucket_website_configuration" "finops_cost_intelligence_bucket_website_configuration" {
  bucket = aws_s3_bucket.finops_cost_intelligence_bucket.id

  index_document {
    suffix = "index.html"
  }
}


// Declare the S3 bucket public access block for the FinOps Cost Intelligence bucket
resource "aws_s3_bucket_public_access_block" "finops_cost_intelligence_bucket_public_access_block" {
  bucket = aws_s3_bucket.finops_cost_intelligence_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


// Declare the S3 bucket policy for the FinOps Cost Intelligence bucket
resource "aws_s3_bucket_policy" "finops_cost_intelligence_bucket_policy" {
  bucket     = aws_s3_bucket.finops_cost_intelligence_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.finops_cost_intelligence_bucket_public_access_block]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.finops_cost_intelligence_bucket.arn}/*"
      }
    ]
  })
}


// Declare the S3 object for the FinOps Cost Intelligence dashboard index.html
resource "aws_s3_object" "finops_cost_intelligence_index_html" {
  bucket       = aws_s3_bucket.finops_cost_intelligence_bucket.id
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
}