```hcl
output "app_public_ip" {
  value = aws_eip.app.public_ip
}

output "app_public_dns" {
  value = aws_instance.app_server.public_dns
}

output "db_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "db_name" {
  value = aws_db_instance.postgres.db_name
}
```