# Deployment Journal

## 2026-08-06 — AWS Networking & EC2

### Completed

- Created custom VPC:
  - `clouddeploy-vpc`
  - CIDR: `10.0.0.0/16`
- Created public subnet:
  - `clouddeploy-public-subnet-1a`
  - CIDR: `10.0.1.0/24`
  - AZ: `ap-south-1a`
- Created private subnet:
  - `clouddeploy-private-subnet-1a`
  - CIDR: `10.0.2.0/24`
  - AZ: `ap-south-1a`
- Created Internet Gateway:
  - `clouddeploy-igw`
- Created public route table:
  - `clouddeploy-public-rt`
  - `0.0.0.0/0 → Internet Gateway`
- Created EC2 IAM role:
  - `clouddeploy-ec2-role`
  - `AmazonSSMManagedInstanceCore`
  - `CloudWatchAgentServerPolicy`
- Created EC2 security group:
  - `clouddeploy-web-sg`
  - SSH: port 22 from My IP
  - HTTP: port 80 from anywhere
  - HTTPS: port 443 from anywhere
- Launched Amazon Linux 2023 EC2 instance.

### Issue

The EC2 launch wizard initially did not display the security group.

Cause:
The security group was not correctly associated with the VPC.

Resolution:
Associated the security group with the VPC through the Security Group's VPC associations section.

### Lesson

A security group belongs to a VPC. When launching an EC2 instance, the security group must belong to the VPC selected for the instance.

---

## 2026-08-08 — Linux & FastAPI Deployment

### Application Setup

- Installed Git and basic Linux administration tools.
- Installed `uv`.
- Created `/opt/clouddeploy-fastapi`.
- Cloned the private GitHub repository:
  - `uddin-rajaul/clouddeploy-fastapi`
- Used `uv sync` to create the project virtual environment and install dependencies.
- Verified FastAPI manually with Uvicorn.
- Verified:
  - `/`
  - `/health`

### Deployment User Decision

Initially created a dedicated `clouddeploy` system user.

This introduced unnecessary complexity around filesystem permissions and the per-user `uv` installation.

Decision:
Use the existing `ec2-user` for the application and deployment.

The dedicated `clouddeploy` user and related configuration were removed.

### systemd

Created:

`/etc/systemd/system/clouddeploy.service`

The service:

- Runs as `ec2-user`
- Uses `/opt/clouddeploy-fastapi` as its working directory
- Runs Uvicorn from the project's `.venv`
- Listens on `127.0.0.1:8000`
- Automatically restarts if the process fails
- Starts automatically on boot

Verified that the service starts successfully and runs the FastAPI application.

### Nginx

Installed Nginx.

Created:

`/etc/nginx/conf.d/clouddeploy.conf`

Nginx listens on port 80 and reverse proxies requests to:

`127.0.0.1:8000`

The default Nginx server configuration initially caused a conflicting `server_name _` warning. The configuration was corrected so that only the intended CloudDeploy server block handles port 80.

Verified the configuration with:

`nginx -t`

Started and enabled Nginx with systemd.

### Current Application Request Flow

    Internet
        |
        | HTTP :80
        v
      Nginx
        |
        | 127.0.0.1:8000
        v
     Uvicorn
        |
        v
     FastAPI

### Verification

Verified through Nginx:

`GET /`
→ `{"message":"Welcome to CloudDeploy API"}`

`GET /health`
→ `{"status":"healthy"}`

### Lessons

- Verify the application manually before putting it under systemd.
- systemd manages the application process and starts it automatically on boot.
- Uvicorn does not need to be publicly exposed when Nginx is the reverse proxy.
- FastAPI remains bound to localhost while Nginx provides the public HTTP entry point.
- Test Nginx configuration with `nginx -t` before restarting it.
- When troubleshooting, identify the actual cause before applying fixes. Avoid adding complexity to solve a simple problem.

---

## 2026-08-09 — RDS PostgreSQL

### Why RDS

The application currently runs on EC2, but the database should not be installed directly on the application server.

RDS provides a managed PostgreSQL database while AWS handles the underlying database server infrastructure.

The application architecture is now:

    Internet
        |
        v
      Nginx
        |
        v
      FastAPI
        |
        | PostgreSQL :5432
        v
    RDS PostgreSQL

The database is private and is not directly reachable from the internet.

### Private Subnet

Created a second private subnet:

- Name: `clouddeploy-private-subnet-1b`
- CIDR: `10.0.3.0/24`
- AZ: `ap-south-1b`

The existing private subnet remains:

- Name: `clouddeploy-private-subnet-1a`
- CIDR: `10.0.2.0/24`
- AZ: `ap-south-1a`

The second Availability Zone provides the subnet coverage required for the RDS DB subnet group.

No NAT Gateway was created because the database does not need internet access.

### RDS DB Subnet Group

Created:

`clouddeploy-db-subnet-group`

Contains:

- `10.0.2.0/24` in `ap-south-1a`
- `10.0.3.0/24` in `ap-south-1b`

The DB subnet group tells RDS which VPC subnets can be used for the database.

### RDS Security Group

Created:

`clouddeploy-rds-sg`

Inbound access:

- PostgreSQL
- TCP 5432
- Source: `clouddeploy-web-sg`

This creates the intended relationship:

    EC2
     |
     | TCP 5432
     v
    RDS

The database does not allow arbitrary internet clients to connect.

The source is the EC2 security group rather than an EC2 IP address so the rule remains valid if the EC2 private IP changes.

### RDS Instance

Created:

- DB identifier: `clouddeploy-postgres`
- Engine: PostgreSQL
- Engine version: `18.3`
- Instance class: `db.t4g.micro`
- Region: `ap-south-1`
- AZ: `ap-south-1a`
- Public access: No
- Port: `5432`
- DB subnet group: `clouddeploy-db-subnet-group`
- Security group: `clouddeploy-rds-sg`
- Automated backup retention: 1 day
- Storage autoscaling: Disabled
- Deletion protection: Disabled

The database is currently `Available`.

### Connectivity Verification

From EC2, verified DNS and TCP connectivity to the RDS endpoint.

RDS resolved to the private address:

`10.0.2.109`

Verified PostgreSQL port connectivity:

`TCP 5432 → Connected`

This confirmed that:

- DNS resolution works.
- EC2 can reach the private RDS address.
- VPC routing is working.
- The RDS security group allows the EC2 security group.
- PostgreSQL is listening on port 5432.

### PostgreSQL Authentication Verification

Installed the PostgreSQL client on EC2.

Connected successfully using:

- Client: PostgreSQL 18.4
- Server: PostgreSQL 18.3
- Database: `postgres`
- User: `clouddeployadmin`
- Port: `5432`

Verified:

- PostgreSQL server version: 18.3
- Private RDS address: `10.0.2.109`
- SSL connection: enabled
- TLS version: 1.3
- Authentication: successful
- Master user is not a PostgreSQL superuser, as expected for an RDS-managed database.

### Current RDS Architecture

    clouddeploy-vpc
    |
    +-- Public subnet 1a
    |     |
    |     +-- EC2
    |
    +-- Private subnet 1a
    |     |
    |     +-- RDS
    |
    +-- Private subnet 1b
          |
          +-- Available to RDS subnet group

    Internet
       |
       | :80
       v
      EC2
       |
       | :5432
       v
      RDS

### Lessons

- A public application does not require a publicly accessible database.
- DB subnet groups define the subnets available to RDS.
- Security groups can reference other security groups instead of relying on fixed IP addresses.
- Network connectivity should be tested separately from database authentication.
- `nc` verified TCP connectivity, while `psql` verified actual PostgreSQL authentication.
- RDS provides a managed PostgreSQL server; EC2 only needs the PostgreSQL client when direct database administration or testing is required.
- Keep the architecture simple: no NAT Gateway, RDS Proxy, read replicas, Multi-AZ deployment, or other unnecessary infrastructure for this learning project.