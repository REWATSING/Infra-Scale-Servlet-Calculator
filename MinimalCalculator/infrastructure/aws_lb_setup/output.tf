# aws_lb_setup/output.tf

output "lb_dns_name" {
  value = aws_lb.main.dns_name
}
