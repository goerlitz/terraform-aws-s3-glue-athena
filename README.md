# Dataset Management in the Cloud (AWS)

---
This project started with a simple goal: store datasets in the cloud and make the data accessible through an API.

The initial expectation was that this would take only a couple of days to implement. But it turned out to be much more complex as several cloud services need to be involved and a couple of design decisions had to be taken.

In addition, a couple of requirements should be fulfilled:
- use serverless architecture to reduce costs (pay per use).
- implement an industrial strength solution
  - use infrastructure as code (IaC) to automate management of all cloud component.
  - take care of security and maintainability aspects.
  - follow cloud best practices, like [AWS Well Architected Framework](https://docs.aws.amazon.com/wellarchitected/latest/framework/wellarchitected-framework.pdf)
  - integrate with CI/CD.

## Technology Overview

---
TODO: include graphic with AWS components

### Cloud Services ☁️

- **AWS S3** as cheap data storage.
- **AWS Lambda** and **API Gateway** to access the datasets through an HTTP/REST interface.
- **AWS DynamoDB** to store metadata about the datasets.
- **AWS Glue** and **Athena** to query the datasets and compute statistics.
- **AWS VPC** to secure services.
- **AWS Cognito** for authentication.

### Dev Tech & Tools 🛠️

- **Terraform** and **Terragrunt** for Infrastructure as Code (IaC).
- Lambda functions
  - **Typescript** for increased development efficiency.
  - **Eslint** + **Prettier** for JavaScript code styling.
  - **Jest** for JavaScript testing.
  - **Webpack** to create deployment packages for AWS lambda.
- **GitHub Actions** for continuous integration and deployment (CI/CD).


### Implementation Decisions 🔄

- **Terraform/Terragrunt**: prefer declarative infrastructure definition, supports multiple cloud platforms.
- **AWS S3**: it is cheap, and we don't need a data warehouse for basic data exploration and analysis.
- **AWS Athena + Glue**: executes SQL queries directly on S3 data and integrates well with the serverless architecture.
- **AWS Lambda**: only pay for actual requests on the data.
- **AWS API Gateway**: also a core part of serverless application that make Lambda function available as HTTP/REST API.

### Other Tools 🔨

- [Checkov](https://github.com/bridgecrewio/checkov)

## Prerequisites 🎨

- AWS cli
- terraform + terragrunt

## Commands ⚙️

* `npm run build` - compile all TypeScript files and create packaged JavaScript for deployment.
* `npm run deploy` - build deployment package and upload to AWS lambda via terraform lambda configuration.

## Run Checkov

...
