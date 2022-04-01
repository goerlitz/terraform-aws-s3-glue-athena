# Serverless Data Analysis on AWS

**Goal:** Store CSV datasets in S3 and make them accessible through an API.

## Requirements

* use serverless architecture to reduce costs (pay per use).
* use infrastructure as code (IaC) to automate setup.
* follow cloud best practices, like [AWS Well Architected Framework](https://docs.aws.amazon.com/wellarchitected/latest/framework/wellarchitected-framework.pdf)
* industrial-strength setup with authentication, security and monitoring.
* integrate with CI/CD.

## Infrastructure Overview

TODO: include graphic

## Implementation Choices

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

## Other Tools

* [Checkov](https://github.com/bridgecrewio/checkov)
* Github Actions
* Auth0
