provider "aws" {
  region = var.aws_region
}

#Terraform locals are set up to reference to and avoid repetition.It also allows us to 
#write more meaningful names instead of hard-coded values. 

locals {
    name = "ecs-counter-project"
    owner       = "Mehmet"
    environment = "dev"
    ec2_resources_name = "${local.name}-${local.environment}"
    tags = {
        Owner = "${local.owner}"
        Environment = "${local.environment}"
    }
    region = "us-east-1"
}
#Creates a new VPC from a module block of source code pointing at github.
#This creates 3 private subnets and 3 public subnets in 3 different 

module "vpc" {
  source = "github.com/terraform-aws-modules/terraform-aws-vpc"
  name   = "ECS-Project-VPC"
  cidr   = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_ipv6 = true

  enable_nat_gateway = false
  single_nat_gateway = true

  public_subnet_tags = {
    Name = "overridden-name-public"
  }

  tags = {
    Owner       = local.owner
    Environment = local.environment
  }

  vpc_tags = {
    Name = "ECS-Project-VPC"
  }
}

#Application load balancer is created which references the newly created
#VPC's public subnets and listens out on port 80. 

module "alb" {
  source  = "terraform-aws-modules/alb/aws"

  name = local.name

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name             = local.name
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    },
  ]

  security_groups = [module.vpc.default_security_group_id]

  tags = local.tags
}

#Here we load up the ecs module from linked source and then set FARGATE
#as the main capacity provider for ECS which abstracts underlying infrastructure
#and allows us to focus on container development. 

module "ecs" {
  source = "github.com/terraform-aws-modules/terraform-aws-ecs"

  name               = local.name
  container_insights = true

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy = [{
    capacity_provider = "FARGATE_SPOT"
    weight            = "1"
  }]

  tags = {
    Environment = local.environment
  }
}

module "website-counter" {
  source = "./modules/service-website-counter"

  cluster_id = module.ecs.ecs_cluster_id
}
