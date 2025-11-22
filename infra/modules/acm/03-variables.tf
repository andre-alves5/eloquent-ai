variable "domain_name" {
  description = "The domain name for which to create the SSL certificate."
  type        = string
}

variable "project" {
  description = "The name of the project, used for resource naming."
  type        = string
}
