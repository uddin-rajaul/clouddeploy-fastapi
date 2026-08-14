## 2026-08-15 — Terraform Foundation and Remote State

Today I officially started the Terraform phase of CloudDeploy.

The AWS infrastructure had already been built and tested manually, so the goal now is to bring that existing infrastructure under Infrastructure as Code rather than destroying it and rebuilding everything from scratch.

Before touching the actual AWS infrastructure, I set up the Terraform foundation.

### Terraform Versioning

The project is using:

- Terraform `1.15.x`
- AWS provider `6.60.x`

The provider version is constrained in the Terraform configuration, and Terraform generated `.terraform.lock.hcl` to record the selected provider version and checksums.

The lock file will be committed to the repository so local development and CI/CD can use consistent provider dependencies.

### Terraform Project Structure

I created a structured Terraform layout:

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
````

The idea is to separate the Terraform bootstrap infrastructure, the production root module, and the reusable infrastructure modules.

The modules represent meaningful parts of the actual CloudDeploy architecture rather than creating modules just for the sake of having them.

### Terraform Bootstrap

Terraform first needed a place to store its remote state.

I created a small bootstrap configuration that creates an S3 bucket:

```text
clouddeploy-terraform-state-116527261682
```

The bucket has:

* S3 versioning enabled
* Server-side encryption using AES256

The bootstrap configuration successfully passed:

```text
terraform fmt
terraform init
terraform validate
terraform plan
```

The plan showed:

```text
Plan: 3 to add, 0 to change, 0 to destroy.
```

I then applied it successfully:

```text
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

This bootstrap state is currently local. That is intentional because the bootstrap configuration creates the S3 bucket that the main Terraform configuration will use for remote state.

### Production Remote State

After creating the S3 bucket, I created the production Terraform root configuration and configured an S3 backend.

The production state is configured to use:

```text
S3 bucket:
clouddeploy-terraform-state-116527261682

State key:
clouddeploy/production/terraform.tfstate

Region:
ap-south-1
```

The backend also uses Terraform's native S3 lockfile mechanism:

```text
use_lockfile = true
```


The production Terraform configuration successfully initialized against S3.

`terraform validate` succeeded.

`terraform plan` returned:

```text
No changes. Your infrastructure matches the configuration.
```

This is expected because the production Terraform configuration does not contain any infrastructure resources yet.

### Important Terraform Concept Learned

Terraform has three important pieces to reconcile:

```text
Terraform configuration
        ↓
Terraform state
        ↓
Actual infrastructure
```

The AWS infrastructure already exists, but the production Terraform state currently does not know about it.

Therefore, the next phase is not to create a second copy of the infrastructure.

Instead, I will define the existing infrastructure in Terraform and import the existing AWS resources into Terraform state.

The intended flow is:

```text
Existing AWS infrastructure
        ↓
Terraform resource definitions
        ↓
Import existing resources
        ↓
Terraform state
        ↓
terraform plan
        ↓
No unwanted changes
```

### Current Terraform State

Bootstrap:

```text
Local state
    ↓
Creates and manages the Terraform S3 state bucket
```

Production:

```text
S3 remote state
    ↓
clouddeploy/production/terraform.tfstate
```

The production state currently contains no resources because nothing has been imported yet.

### Lesson

The most important lesson today was that Terraform is not simply a tool for creating infrastructure.

It maintains a relationship between:

```text
what I declare
what Terraform knows
what actually exists
```

Because CloudDeploy's AWS environment already works, importing the existing infrastructure is the correct approach.

This also makes the Terraform phase more valuable: instead of blindly rebuilding the architecture, I have to understand how each existing AWS resource maps to Terraform configuration and state.

The goal is to understand each Terraform resource and its relationship to the existing AWS architecture before moving on to modules and Terraform CI/CD.

```

The key milestone today is **not "Terraform created AWS infrastructure."** It is that we now have a proper Terraform foundation with remote production state, while preserving the existing manually built environment. The next step is importing the VPC and learning the resource/state/import relationship properly.
```
