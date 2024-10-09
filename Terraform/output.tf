# Output the public IP of the web server instance
output "web_server_ip" {
  description = "Public IP of the web server instance"
  value       = aws_instance.web_server.public_ip
}
