output "app_instance_public_ip" {
  description = "The public IP of the EC2 instance running the app"
  value       = aws_instance.app.public_ip
}

output "db_endpoint" {
  description = "The endpoint of the RDS PostgreSQL database"
  value       = aws_db_instance.postgres.endpoint
}
