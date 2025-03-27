output "alb_dns_name" {
  description = "DNS Name of the ALB"
  value       = aws_lb.app_alb.dns_name
}

output "rds_endpoint" {
  description = "RDS Endpoint"
  value       = aws_db_instance.n26_db.endpoint
}

output "bastion_public_ip" {
  description = "Public IP of the Bastion Host"
  value       = aws_instance.bastion.public_ip
}

output "private_key_pem" {
  description = "The private key in PEM format (sensitive)"
  value       = tls_private_key.generated.private_key_pem
  sensitive   = true
}
