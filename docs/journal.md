# Deployment Journal

## 2026-08-06 — AWS Networking & EC2

### Completed

- Created custom VPC:
  - `clouddeploy-vpc`
  - CIDR: `10.0.0.0/16`
- Created public subnet:
  - `clouddeploy-public-subnet-1a`
  - CIDR: `10.0.1.0/24`
- Created private subnet:
  - `clouddeploy-private-subnet-1a`
  - CIDR: `10.0.2.0/24`
- Created and attached Internet Gateway:
  - `clouddeploy-igw`
- Created public route table:
  - `clouddeploy-public-rt`
  - `0.0.0.0/0 → Internet Gateway`
- Created EC2 IAM role:
  - `clouddeploy-ec2-role`
  - AmazonSSMManagedInstanceCore
  - CloudWatchAgentServerPolicy
- Created web security group:
  - `clouddeploy-web-sg`
  - SSH: 22 from My IP
  - HTTP: 80 from anywhere
  - HTTPS: 443 from anywhere
- Launched Amazon Linux 2023 EC2 instance.

### Issue

The EC2 launch wizard initially did not display the security group.

Cause:
The security group was not correctly associated with the VPC.

Resolution:
Associated the security group with the VPC through the Security Group's **VPC associations** section.

### Lesson

A security group belongs to a VPC. When launching an EC2 instance, the selected security group must belong to the VPC selected for that instance.

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

Initially created a dedicated `clouddeploy` system user and application directories.

This introduced unnecessary complexity for the scope of this project, particularly around per-user `uv` installation and filesystem permissions.

Decision:
Use the existing `ec2-user` for the application and deployment.

The dedicated `clouddeploy` user and related files were removed.

### systemd

Created:

- `/etc/systemd/system/clouddeploy.service`

The service:

- Runs as `ec2-user`
- Uses `/opt/clouddeploy-fastapi` as its working directory
- Runs the Uvicorn executable from the project's `.venv`
- Listens on `127.0.0.1:8000`
- Automatically restarts if the process fails
- Starts automatically on boot

Verified that systemd can stop and start the FastAPI application successfully.

### Nginx

Installed Nginx.

Configured:

- `/etc/nginx/conf.d/clouddeploy.conf`

Nginx listens on port 80 and reverse proxies requests to `127.0.0.1:8000`.

Removed the default Nginx server block to avoid a conflicting `server_name _` configuration.

Verified the Nginx configuration with:

```
nginx -t
```

Started and enabled Nginx with systemd.

### Current Request Flow

```text
Internet
   │
   │ HTTP :80
   ▼
  Nginx
   │
   │ 127.0.0.1:8000
   ▼
 Uvicorn
   │
   ▼
 FastAPI
```

### Verification

Verified locally through Nginx:

- `GET /` → `{"message":"Welcome to CloudDeploy API"}`
- `GET /health` → `{"status":"healthy"}`

### Lessons

- The application should be verified manually before putting it under systemd.
- systemd manages the application process and ensures it starts on boot.
- Uvicorn does not need to be publicly exposed when Nginx is used as the reverse proxy.
- Nginx provides the public HTTP entry point while FastAPI remains bound to localhost.
- Configuration changes should be tested with `nginx -t` before restarting the service.
- When troubleshooting, diagnose the actual cause before applying fixes; avoid adding complexity.