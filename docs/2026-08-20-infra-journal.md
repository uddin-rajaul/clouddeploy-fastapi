## 2026-08-20 — Terraform Infrastructure Migration and Reconciliation

After establishing the Terraform foundation and remote state, I continued the Terraform phase by bringing the existing CloudDeploy AWS infrastructure under Terraform management.

The infrastructure had already been built and tested manually. Therefore, the objective was not to recreate it, but to accurately model the existing AWS resources in Terraform and import them into the production state.

### Terraform Modules

I implemented the production infrastructure using the planned module structure:

```text
infrastructure/
└── terraform/
    ├── bootstrap/
    ├── environments/
    │   └── production/
    └── modules/
        ├── networking/
        ├── security/
        ├── iam/
        ├── compute/
        ├── database/
        └── monitoring/
```

The modules represent meaningful infrastructure boundaries within CloudDeploy:

* `networking` — VPC, subnets, internet gateway, route table and routing
* `security` — RDS security group and its rules
* `iam` — EC2 IAM role, instance profile and required policies
* `compute` — EC2 instance
* `database` — RDS PostgreSQL and DB subnet group
* `monitoring` — CloudWatch log groups and alarms

This structure keeps the Terraform configuration organized around the actual architecture rather than creating unnecessary abstractions.

### Importing Existing Networking

The first major step was bringing the existing VPC infrastructure into Terraform.

The existing VPC is:

```text
VPC:
vpc-0a9633c66c64c417d

CIDR:
10.0.0.0/16

Region:
ap-south-1
```

I imported the existing:

* VPC
* public subnet
* two private subnets
* Internet Gateway
* public route table
* public route
* public subnet association

The existing architecture was preserved.

The public subnet remains:

```text
10.0.1.0/24
ap-south-1a
```

The private subnets remain:

```text
10.0.2.0/24
ap-south-1a

10.0.3.0/24
ap-south-1b
```

The public subnet uses the Internet Gateway through the existing public route table, while the private subnets continue using the VPC's main route table.

I did not introduce a NAT Gateway because the current architecture does not require one.

### Security and Database

I then brought the existing RDS networking and database configuration under Terraform.

Terraform now manages the existing RDS security group:

```text
clouddeploy-rds-sg
sg-0fca5782f18a6db53
```

The important security rule is:

```text
TCP 5432
Source:
EC2 web security group
```

This preserves the intended architecture where PostgreSQL is accessible from the application server without exposing PostgreSQL publicly.

The existing DB subnet group was also imported:

```text
clouddeploy-db-subnet-group
```

It contains the two private subnets.

The existing PostgreSQL RDS instance was then imported without recreating it.

The database remains:

```text
PostgreSQL 18.3
db.t4g.micro
20 GB gp3
Encrypted
Publicly accessible: false
Multi-AZ: false
```

Connectivity had already been verified from EC2 before the Terraform migration, including successful PostgreSQL authentication and TLS connectivity.

This gave confidence that the Terraform import was being performed against a known-working database rather than an unverified resource.

### IAM

The existing EC2 IAM configuration was also imported.

Terraform now manages:

```text
clouddeploy-ec2-role
```

along with:

```text
EC2 instance profile
CloudWatchAgentServerPolicy
AmazonSSMManagedInstanceCore
```

The role allows the EC2 instance to interact with the AWS services required by the project, particularly Systems Manager and CloudWatch.

### EC2

The existing production EC2 instance was imported rather than recreated.

```text
Instance:
i-051a3b2b68488e441

Name:
clouddeploy-web-01

Type:
t3.micro

Private IP:
10.0.1.82

Availability Zone:
ap-south-1a
```

During this process I encountered a Terraform provider constraint involving the EC2 root block device.

The `device_name` attribute for the root block device is provider-computed and cannot be configured in the way I initially attempted.

I removed that unnecessary configuration rather than trying to force Terraform to manage a computed attribute.

The instance was then successfully imported.

This reinforced an important Terraform lesson:

> Not every value visible in AWS should necessarily be declared as a configurable Terraform argument.

Terraform configuration should describe what Terraform can and should manage, while allowing provider-computed attributes to remain computed.

### Monitoring

I added the monitoring module and imported the existing CloudWatch resources.

Terraform now manages:

```text
/clouddeploy/nginx/access
/clouddeploy/nginx/error
```

and the existing CloudWatch alarms:

```text
clouddeploy-high-cpu
clouddeploy-instance-status-check
```

The Nginx log groups were preserved without introducing a new retention policy.

One monitoring configuration was identified as conceptually questionable:

```text
clouddeploy-high-cpu

Metric:
cpu_usage_idle

Condition:
cpu_usage_idle > 80
```

If the intention is to detect high CPU utilization, this is backwards because high idle CPU generally means low CPU utilization.

However, I intentionally did not change it during the Terraform import phase.

The goal of this phase was to reproduce the existing infrastructure accurately first. Monitoring improvements will be handled later as deliberate configuration changes.

### Important Security Group Exception

One unusual AWS configuration was investigated during the migration.

The EC2 web security group:

```text
clouddeploy-web-sg
sg-0f587876d8e314354
```

originated from another VPC but is associated with the CloudDeploy VPC through AWS Security Group VPC Association functionality.

The EC2 network interface confirms that the security group is being used by the CloudDeploy EC2 instance.

I deliberately did not recreate or replace this security group.

This is an important example of why infrastructure should be investigated before importing or modifying it blindly.

The current Terraform-managed security resources therefore cover the RDS security group and rules, while the unusual web security group remains outside Terraform for now.

### Final Terraform State

After the imports and configuration reconciliation, the production Terraform state contains 22 resources.

The state now includes:

```text
EC2
RDS
DB subnet group

IAM role
IAM instance profile
IAM policy attachments

VPC
3 subnets
Internet Gateway
Public route table
Public route
Route table association

RDS security group
RDS ingress rule
RDS egress rule

2 Nginx CloudWatch log groups
2 CloudWatch alarms
```

The final state was verified with:

```bash
terraform state list
```

### Terraform Reconciliation

The most important verification was:

```bash
terraform fmt
terraform validate
terraform plan
```

Terraform returned:

```text
Success! The configuration is valid.

No changes. Your infrastructure matches the configuration.
```

This is the key milestone of the Terraform migration.

It means Terraform's configuration and state now accurately represent the existing AWS infrastructure without Terraform proposing to modify or recreate the working environment.

The migration process can therefore be summarized as:

```text
Existing AWS infrastructure
        ↓
Understand each resource
        ↓
Create Terraform resource definitions
        ↓
Import existing resources
        ↓
Reconcile configuration with reality
        ↓
terraform plan
        ↓
No changes
```

### What I Learned

The biggest lesson from this phase is that Terraform is not primarily about writing configuration files.

The difficult part is understanding the relationship between:

```text
Terraform configuration
        ↓
Terraform state
        ↓
AWS infrastructure
```

Importing an existing environment requires understanding how AWS resources map to Terraform resources, which attributes are configurable, which are provider-computed, and which existing AWS behaviors should be preserved rather than "cleaned up."

I also learned that infrastructure-as-code does not mean every AWS resource must be managed by Terraform.

For CloudDeploy, the goal is to manage the infrastructure that is important to the application and leave unrelated or unnecessarily complex AWS resources outside the Terraform scope.

### Current Milestone

The Terraform migration is now effectively complete for the core CloudDeploy infrastructure.

Current status:

```text
Terraform foundation       ✓
Remote production state    ✓
Terraform modules          ✓
Existing infrastructure    ✓
Resource imports           ✓
Terraform state            ✓
Configuration validation   ✓
Plan reconciliation        ✓
```

Most importantly:

```text
terraform plan
→ No changes
```

The next phase is therefore no longer about importing infrastructure.

Terraform has achieved its purpose for the current architecture. The project can now move forward with the remaining engineering work, beginning with the existing CI/CD pipeline and production deployment workflow rather than expanding Terraform to manage every AWS resource in the account.
