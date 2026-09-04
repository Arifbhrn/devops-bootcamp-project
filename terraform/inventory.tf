resource "local_file" "inventory" {
  filename = "inventory.ini"
  content = templatefile("inventory.ini.tftpl", {
    web_server_ip = module.web-server.public_ip
    monitoring_ip = module.monitor-server.private_ip
    controller_ip = module.ansible-controller.private_ip
  })
}