resource "aws_iam_instance_profile" "lab_instance" {
  name = "lab_instance_mrap_profile"
  role = "lab_instance_mrap"
}

# REGION1 VPC
# ============================

resource "aws_vpc" "region1" {
  provider = aws

  cidr_block = "10.201.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    name = "cloudacademy-lab"
  }
}

resource "aws_subnet" "region1" {
  provider = aws

  vpc_id     = aws_vpc.region1.id
  cidr_block = "10.201.0.0/24"
}

module "vpc-endpoint-s3-global-region1" {
  providers = {
    aws = aws
  }
  source = "../terraform/modules/vpc-endpoint"

  private_dns_only_for_inbound_resolver_endpoint = false
  configuration = {
    service_name = "com.amazonaws.s3-global.accesspoint"
    subnet_type  = "Private"
    region       = "us-east-1"
  }

  vpc_id     = aws_vpc.region1.id
  subnet_ids = [aws_subnet.region1.id]
}

resource "aws_route_table" "region1" {
  vpc_id = aws_vpc.region1.id

  tags = {
    name = "private-zone"
  }
}

resource "aws_route_table_association" "region1" {
  subnet_id      = aws_subnet.region1.id
  route_table_id = aws_route_table.region1.id
}

resource "aws_security_group" "region1" {
  vpc_id = aws_vpc.region1.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "region1" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "region1" {
  ami           = data.aws_ami.region1.id
  instance_type = "t3.micro"

  subnet_id              = aws_subnet.region1.id
  vpc_security_group_ids = [aws_security_group.region1.id]
  iam_instance_profile   = aws_iam_instance_profile.lab_instance.name

  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    Name = "lab-instance-region1"
  }
}

resource "aws_vpc_endpoint" "ssm_region1" {
  vpc_id              = aws_vpc.region1.id
  service_name        = "com.amazonaws.us-east-1.ssm"
  subnet_ids          = [aws_subnet.region1.id]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.region1.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages_region1" {
  vpc_id              = aws_vpc.region1.id
  service_name        = "com.amazonaws.us-east-1.ec2messages"
  subnet_ids          = [aws_subnet.region1.id]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.region1.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages_region1" {
  vpc_id              = aws_vpc.region1.id
  service_name        = "com.amazonaws.us-east-1.ssmmessages"
  subnet_ids          = [aws_subnet.region1.id]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.region1.id]
  private_dns_enabled = true
}

# REGION2 VPC
# ============================

resource "aws_vpc" "region2" {
  provider = aws.us-west-2

  cidr_block = "10.202.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    name = "cloudacademy-lab"
  }
}

resource "aws_subnet" "region2" {
  provider = aws.us-west-2

  vpc_id     = aws_vpc.region2.id
  cidr_block = "10.202.0.0/24"
}

module "vpc-endpoint-s3-global-region2" {
  providers = {
    aws = aws.us-west-2
  }
  source = "../terraform/modules/vpc-endpoint"

  private_dns_only_for_inbound_resolver_endpoint = false
  configuration = {
    service_name = "com.amazonaws.s3-global.accesspoint"
    subnet_type  = "Private"
    region       = "us-west-2"
  }

  vpc_id     = aws_vpc.region2.id
  subnet_ids = [aws_subnet.region2.id]
}

resource "aws_route_table" "region2" {
  provider = aws.us-west-2

  vpc_id = aws_vpc.region2.id

  tags = {
    name = "private-zone"
  }
}

resource "aws_route_table_association" "region2" {
  provider = aws.us-west-2

  subnet_id      = aws_subnet.region2.id
  route_table_id = aws_route_table.region2.id
}

resource "aws_security_group" "region2" {
  provider = aws.us-west-2

  vpc_id = aws_vpc.region2.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "region2" {
  provider = aws.us-west-2

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "region2" {
  provider = aws.us-west-2

  ami           = data.aws_ami.region2.id
  instance_type = "t3.micro"

  subnet_id              = aws_subnet.region2.id
  vpc_security_group_ids = [aws_security_group.region2.id]
  iam_instance_profile   = aws_iam_instance_profile.lab_instance.name

  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    Name = "lab-instance-region2"
  }
}

resource "aws_vpc_endpoint" "ssm_region2" {
  provider = aws.us-west-2

  vpc_id              = aws_vpc.region2.id
  service_name        = "com.amazonaws.us-west-2.ssm"
  subnet_ids          = [aws_subnet.region2.id]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.region2.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages_region2" {
  provider = aws.us-west-2

  vpc_id              = aws_vpc.region2.id
  service_name        = "com.amazonaws.us-west-2.ec2messages"
  subnet_ids          = [aws_subnet.region2.id]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.region2.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages_region2" {
  provider = aws.us-west-2

  vpc_id              = aws_vpc.region2.id
  service_name        = "com.amazonaws.us-west-2.ssmmessages"
  subnet_ids          = [aws_subnet.region2.id]
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.region2.id]
  private_dns_enabled = true
}
