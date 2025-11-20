variable "env" {
  type = string
}

variable "vpc-cidr-block" {
  type = string
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
