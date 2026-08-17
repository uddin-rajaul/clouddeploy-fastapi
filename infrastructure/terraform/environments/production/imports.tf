import {
  to = module.networking.aws_vpc.this
  id = "vpc-0a9633c66c64c417d"
}

import {
  to = module.networking.aws_subnet.public_1a
  id = "subnet-0e397ff96e6c91d7e"
}

import {
  to = module.networking.aws_subnet.private_1a
  id = "subnet-01c8fc49db8db789b"
}

import {
  to = module.networking.aws_subnet.private_1b
  id = "subnet-01ab585c607e15ef9"
}

import {
  to = module.networking.aws_internet_gateway.this
  id = "igw-0acdbe0c93ba6897c"
}

import {
  to = module.networking.aws_route_table.public
  id = "rtb-00e607db790e0e86f"
}

import {
  to = module.networking.aws_route.public_internet
  id = "rtb-00e607db790e0e86f_0.0.0.0/0"
}

import {
  to = module.networking.aws_route_table_association.public_1a
  id = "subnet-0e397ff96e6c91d7e/rtb-00e607db790e0e86f"
}

import {
  to = module.security.aws_security_group.rds
  id = "sg-0fca5782f18a6db53"
}

import {
  to = module.security.aws_vpc_security_group_ingress_rule.rds_postgres
  id = "sgr-0cb225edacbe9cdc7"
}

import {
  to = module.security.aws_vpc_security_group_egress_rule.rds_all
  id = "sgr-02b98554691ca44fe"
}