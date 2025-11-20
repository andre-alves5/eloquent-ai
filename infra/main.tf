module "vpc" {
  source = "./modules/networking"

  env             = var.env
  vpc-cidr-block  = var.vpc-cidr-block
  private-subnets = var.private-subnets
  public-subnets  = var.public-subnets
}

module "alb" {
  source = "./modules/alb"

  env                        = var.env
  internal                   = var.internal
  lb-type                    = var.lb-type
  enable-deletion-protection = var.enable-deletion-protection
  vpc-id                     = module.vpc.vpc-id
  public-subnet-ids          = module.vpc.public-subnet-ids
  target-group               = module.ecs.target-group-arn
}

module "ecs" {
  source = "./modules/ecs-fargate"

  env                    = var.env
  capacity-providers     = var.capacity-providers
  cpu                    = var.cpu
  memory                 = var.memory
  network-mode           = var.network-mode
  max-capacity           = var.max-capacity
  min-capacity           = var.min-capacity
  target-cpu-utilization = var.target-cpu-utilization
  desired-count          = var.desired-count
  container-port         = var.container-port
  launch-type            = var.launch-type
  vpc-id                 = module.vpc.vpc-id
  private-subnet-ids     = module.vpc.private-subnet-ids
  alb-sg-id              = module.alb.alb-sg-id
}
