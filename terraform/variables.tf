```hcl
variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name of the application"
  default     = "comments-app"
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  default     = "t3.small"
}

variable "db_instance_class" {
  description = "RDS instance class"
  default     = "db.t3.small"
}

variable "db_name" {
  description = "Database name"
  default     = "comments_app_prod"
}

variable "db_username" {
  description = "Database username"
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  sensitive   = true
}

variable "ssh_key_name" {
  description = "SSH key name for EC2 access"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}
```