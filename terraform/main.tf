# S3 Buckets
resource "aws_s3_bucket" "app_data" {
  bucket = "app-data-bucket"

  tags = {
    Name        = "Application Data Bucket"
    Environment = "local"
  }
}

resource "aws_s3_bucket_versioning" "app_data_versioning" {
  bucket = aws_s3_bucket.app_data.id

  versioning_configuration {
    status = "Enabled"
  }
}

# DynamoDB Table
resource "aws_dynamodb_table" "users" {
  name           = "users"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "userId"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  global_secondary_index {
    name            = "EmailIndex"
    hash_key        = "email"
    projection_type = "ALL"
    read_capacity   = 5
    write_capacity  = 5
  }

  tags = {
    Name        = "Users Table"
    Environment = "local"
  }
}

# SQS Queue
resource "aws_sqs_queue" "app_queue" {
  name                      = "app-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 10

  tags = {
    Name        = "Application Queue"
    Environment = "local"
  }
}

# SNS Topic
resource "aws_sns_topic" "app_notifications" {
  name = "app-notifications"

  tags = {
    Name        = "Application Notifications"
    Environment = "local"
  }
}

# SNS Subscription to SQS
resource "aws_sns_topic_subscription" "app_notifications_sqs" {
  topic_arn = aws_sns_topic.app_notifications.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.app_queue.arn
}

# Lambda Function (example)
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_lambda_function" "example" {
  filename      = "lambda_function.zip"
  function_name = "example_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  environment {
    variables = {
      ENVIRONMENT = "local"
      QUEUE_URL   = aws_sqs_queue.app_queue.url
    }
  }

  tags = {
    Name        = "Example Lambda Function"
    Environment = "local"
  }
}
