variable "env" {
  description = "The target environment name."
  type        = string
}

variable "project" {
  description = "The name of the project."
  type        = string
}

variable "capacity-providers" {
  description = "List of capacity providers for the cluster."
  type        = list(string)
}

variable "cpu" {
  description = "The number of CPU units for the task."
  type        = number
}

variable "memory" {
  description = "The amount of memory (in MiB) for the task."
  type        = number
}

variable "network-mode" {
  description = "The Docker networking mode for the task."
  type        = string
}

variable "max-capacity" {
  description = "Maximum number of tasks for auto-scaling."
  type        = number
}

variable "min-capacity" {
  description = "Minimum number of tasks for auto-scaling."
  type        = number
}

variable "target-cpu-utilization" {
  description = "Target CPU utilization for auto-scaling."
  type        = number
}

variable "desired-count" {
  description = "The desired number of tasks for the service."
  type        = number
}

variable "container-port" {
  description = "The port the container listens on."
  type        = number
}

variable "launch-type" {
  description = "The launch type for the ECS service."
  type        = string
}

variable "vpc-id" {
  description = "The ID of the VPC."
  type        = string
}

variable "private-subnet-ids" {
  description = "A list of private subnet IDs."
  type        = list(string)
}

variable "alb-sg-id" {
  description = "The ID of the ALB's security group."
  type        = string
}

variable "use_fargate_spot" {
  description = "Whether to use Fargate Spot."
  type        = bool
}

variable "alb_listener_arn" {
  description = "The ARN of the ALB listener to explicitly depend on."
  type        = string
}
