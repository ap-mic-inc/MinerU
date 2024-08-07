output "pwd" {
  value = random_password.vm.result
}

output "ip" {
  value = azurerm_public_ip.app.ip_address
}