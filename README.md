# CloudDeploy FastAPI

CloudDeploy is a small production-inspired FastAPI deployment project built to understand how a real application moves from a Git repository to a running service on AWS.

The focus is on learning the infrastructure and deployment process without adding unnecessary enterprise tooling.

![AWS Architecture](docs/images/image.png)

## What it includes

- FastAPI application with Uvicorn
- PostgreSQL on Amazon RDS
- Amazon EC2 running Amazon Linux 2023
- Nginx as the public reverse proxy
- systemd for application process management
- VPC with public and private subnets
- Security groups controlling EC2 and RDS access
- IAM roles and AWS Systems Manager
- GitHub Actions CI/CD
- GitHub Actions OIDC authentication to AWS
- CloudWatch metrics, logs, and basic alarms
- Alembic database migrations

## Architecture

The application runs on EC2 inside a public subnet. Nginx accepts public HTTP traffic and forwards requests to FastAPI on `127.0.0.1:8000`.

FastAPI connects to PostgreSQL on RDS through the private subnets. RDS is not publicly accessible.

The main application path is:

```text
Internet
   ↓
Nginx
   ↓
FastAPI / Uvicorn
   ↓
Amazon RDS PostgreSQL
```

## CI/CD

A push to `main` starts GitHub Actions.

```text
git push
   ↓
GitHub Actions
   ↓
AWS OIDC
   ↓
AWS Systems Manager
   ↓
EC2
   ↓
checkout exact commit
   ↓
uv sync --locked
   ↓
alembic upgrade head
   ↓
restart systemd service
   ↓
health check
```

The deployment deliberately avoids CodeDeploy, CodePipeline, containers, and other deployment layers that are not needed for this project.

## Monitoring

CloudWatch is used for basic operational visibility.

The CloudWatch Agent collects:

- CPU
- memory
- disk usage
- Nginx access logs
- Nginx error logs

FastAPI/Uvicorn logs remain available through the systemd journal.

## AWS Infrastructure

The current AWS environment uses:

- Region: `ap-south-1`
- VPC: `10.0.0.0/16`
- Public subnet: `10.0.1.0/24`
- Private subnets: `10.0.2.0/24` and `10.0.3.0/24`
- EC2: `t3.micro`
- RDS: PostgreSQL
- Internet Gateway
- Security groups
- IAM
- Systems Manager
- CloudWatch

There is no NAT Gateway because the private database does not require outbound internet access.

## Why this project?

The goal is not to build a large production platform. It is to build something small enough to understand completely, while still covering the fundamentals that matter in DevOps:

**networking → Linux → application deployment → database → CI/CD → observability → infrastructure as code**

The infrastructure was built and tested manually first. Terraform/OpenTofu is the next phase, so the infrastructure can be reproduced from code rather than manually created.

## Project status

The application is deployed and working on AWS.

CI/CD from `main` is working.

CloudWatch monitoring and logging are working.

**Next:** recreate the AWS infrastructure with Terraform/OpenTofu.
