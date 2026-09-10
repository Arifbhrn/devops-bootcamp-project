output "web-server-ip-private" {
  value = module.web-server.private_ip
}
output "ansible-controller" {
  value = module.ansible-controller.private_ip
}
output "monitor-server" {
  value = module.monitor-server.private_ip
}

output "web-server-ssm" {
  value = "aws ssm start-session --target ${module.web-server.id}"
}
output "ansible-controller-ssm" {
  value = "aws ssm start-session --target ${module.ansible-controller.id}"
}
output "monitor-server-ssm" {
  value = "aws ssm start-session --target ${module.monitor-server.id}"
}