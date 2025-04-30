variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "db_password" {
  description = "Database password"
  type        = string
  default     = "your-secure-password"
}
