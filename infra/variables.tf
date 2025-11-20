variable "env" {
  description = "Environment name."
  type        = string
}

variable "vpc-cidr-block" {
  description = "CIDR (Classless Inter-Domain Routing)."
  type        = string
  default     = "10.0.0.0/16"
}

variable "private-subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "public-subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "capacity-providers" {
  type    = list(string)
  default = ["FARGATE", "FARGATE_SPOT"]
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "network-mode" {
  type    = string
  default = "awsvpc"
}

variable "max-capacity" {
  type = number
}

variable "min-capacity" {
  type = number
}

variable "target-cpu-utilization" {
  type = number
}

variable "desired-count" {
  type = number
}

variable "container-port" {
  type = number
}

variable "launch-type" {
  type = string
}

variable "internal" {
  type = bool
}

variable "lb-type" {
  type = string
}

variable "enable-deletion-protection" {
  type = bool
}
