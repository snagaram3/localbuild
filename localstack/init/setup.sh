#!/bin/bash

echo "Initializing LocalStack resources..."

# Create S3 buckets
awslocal s3 mb s3://app-data-bucket
awslocal s3 mb s3://terraform-state-bucket

# Create DynamoDB table
awslocal dynamodb create-table \
    --table-name users \
    --attribute-definitions \
        AttributeName=userId,AttributeType=S \
    --key-schema \
        AttributeName=userId,KeyType=HASH \
    --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5

# Create SQS queue
awslocal sqs create-queue --queue-name app-queue

# Create SNS topic
awslocal sns create-topic --name app-notifications

echo "LocalStack initialization complete!"
