# Serverless Data Analysis on AWS

**Goal:** Store machine learning datasets in S3 and make them accessible through an API.

## Requirements

* use serverless architecture to reduce costs (pay per use).
* use infrastructure as code (IaC) to automate setup.
* industrial-strength setup with security and monitoring.

## Implementation Choices:

* Terraform
  * declarative definition of (multi-) cloud infrastructure.
* S3 for storing the data (instead of data warehouse)
  * S3 is cheap and we don't need a data warehouse for basic exploratory analysis.
* Athena/Glue for queying data
  * Athena can work directly on S3 data and integrates well with the serverless architecture. 
* Lambda functions
  * We only want to pay for actual requests executed on the data
* API Gateway
  * Make Lambda function available for client applications

## Infrastructure Overview

TODO: include graphic
