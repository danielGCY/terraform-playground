output "load_balancer_ip" {
  value = module.alb.dns_name
}
