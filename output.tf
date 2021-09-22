output "vm_id" {
  value = azurerm_linux_virtual_machine.prodenv.id
}

output "vm_ip" {
  value = azurerm_linux_virtual_machine.prodenv.public_ip_address
}

output "tls_private_key" { 
  value = tls_private_key.prodenv.private_key_pem 
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.devenv.id
}

output "vm_ip" {
  value = azurerm_linux_virtual_machine.devenv.public_ip_address
}

output "tls_private_key" { 
  value = tls_private_key.devenv.private_key_pem 
}
