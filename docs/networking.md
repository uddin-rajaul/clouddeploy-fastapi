# Networking Decisions

## VPC

CIDR: 10.0.0.0/16

Reason:
Provides a large private address space that can be subdivided into multiple public and private subnets as the infrastructure grows.

---

## DNS

Enabled DNS Resolution
Enabled DNS Hostnames

Reason:
Allows EC2 instances and future RDS instances to use AWS DNS names.