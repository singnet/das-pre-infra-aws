data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "alb" {
  state = "available"

  tags = {
    Name = "default"
  }
}

data "aws_subnets" "public" {
  filter {
    name = "vpc-id"
    values = [
      data.aws_vpc.alb.id
    ]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = [true]
  }
}

resource "aws_eip" "lb_eip" {
  domain = "vpc"
}

resource "aws_alb" "das_network_alb" {
  name               = "distributed-atom-space-lb"
  internal           = false
  load_balancer_type = "network"

  enable_deletion_protection = true

  subnet_mapping {
    subnet_id     = data.aws_subnets.public[0].id
    allocation_id = aws_eip.lb_eip.id
  }
}

resource "aws_alb" "das_application_alb" {
  name               = "das-application-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [for subnet in data.aws_subnet.public : subnet.id]

  enable_deletion_protection = true
}
