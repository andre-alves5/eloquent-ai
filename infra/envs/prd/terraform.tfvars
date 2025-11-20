#VPC Values
env            = "prd"
vpc-cidr-block = "10.109.0.0/16"
#azs             = ["us-east-1a", "us-east-1b"]
#private-subnets = ["10.109.10.0/24", "10.109.20.0/24"]
#public-subnets  = ["10.109.30.0/24", "10.109.40.0/24"]

private-subnets = {
  subnet-1 = { cidr = "10.109.10.0/24", az = "us-east-1a" }
  subnet-2 = { cidr = "10.109.20.0/24", az = "us-east-1b" }
}
public-subnets = {
  subnet-1 = { cidr = "10.109.30.0/24", az = "us-east-1a" }
  subnet-2 = { cidr = "10.109.40.0/24", az = "us-east-1b" }
}

#ALB Values
internal                   = "false"
lb-type                    = "application"
enable-deletion-protection = true

#ECS Values
capacity-providers     = ["FARGATE", "FARGATE_SPOT"]
cpu                    = 512
memory                 = 1024
network-mode           = "awsvpc"
max-capacity           = 2
min-capacity           = 1
target-cpu-utilization = 70
desired-count          = 1
container-port         = 8080
launch-type            = "FARGATE"
