#General & Networking Variables
variable "env" {
  description = "The target environment name (e.g., 'dev', 'staging', 'prod'). Used for resource naming and tagging."
  type        = string
}

variable "vpc-cidr-block" {
  description = "The IP address range for the VPC in CIDR notation (e.g., 10.0.0.0/16)."
  type        = string
  default     = "10.0.0.0/16"
}

variable "private-subnets" {
  description = "A map of objects defining the private subnets, where keys are identifiers and values contain CIDR blocks and Availability Zones."
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "public-subnets" {
  description = "A map of objects defining the public subnets, where keys are identifiers and values contain CIDR blocks and Availability Zones."
  type = map(object({
    cidr = string
    az   = string
  }))
}

#ECS Cluster & Task Definitions
variable "capacity-providers" {
  description = "List of short names for the capacity providers to associate with the cluster (e.g., ['FARGATE', 'FARGATE_SPOT'])."
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "cpu" {
  description = "The number of CPU units used by the task. 1024 units = 1 vCPU."
  type        = number
}

variable "memory" {
  description = "The amount of memory (in MiB) used by the task."
  type        = number
}

variable "network-mode" {
  description = "The Docker networking mode to use for the containers in the task. For Fargate, this must be 'awsvpc'."
  type        = string
  default     = "awsvpc"
}

variable "container-port" {
  description = "The port number on the container that the application listens on."
  type        = number
}

variable "launch-type" {
  description = "The launch type on which to run your service (e.g., 'FARGATE' or 'EC2')."
  type        = string
}

variable "desired-count" {
  description = "The initial number of instances of the task definition to place and keep running."
  type        = number
}

variable "max-capacity" {
  description = "The maximum number of tasks the Auto Scaling group is allowed to scale out to."
  type        = number
}

variable "min-capacity" {
  description = "The minimum number of tasks the Auto Scaling group must maintain."
  type        = number
}

variable "target-cpu-utilization" {
  description = "The target CPU utilization percentage (0-100) that triggers the auto-scaling policy."
  type        = number
}

#Load Balancer Variables
variable "internal" {
  description = "Boolean flag to determine if the Load Balancer is internal (true) or internet-facing (false)."
  type        = bool
}

variable "lb-type" {
  description = "The type of Load Balancer to create (e.g., 'application' or 'network')."
  type        = string
}

variable "enable-deletion-protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API. Prevents accidental destruction."
  type        = bool
}
