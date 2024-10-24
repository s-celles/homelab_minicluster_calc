# outputs.tf

# Sortie simple
output "container_count" {
  description = "Nombre de conteneurs déployés"
  value       = var.container_count
}

# Sortie avec liste d'IPs
output "container_ips" {
  description = "Liste des adresses IP des conteneurs"
  value = [
    for container in proxmox_virtual_environment_container.lxc_container :
    split("/", container.initialization[0].ip_config[0].ipv4[0].address)[0]
  ]
}

# Sortie avec informations détaillées
output "container_details" {
  description = "Détails de tous les conteneurs"
  value = {
    for idx, container in proxmox_virtual_environment_container.lxc_container :
    container.initialization[0].hostname => {
      id         = container.vm_id
      ip_address = split("/", container.initialization[0].ip_config[0].ipv4[0].address)[0]
      cores      = container.cpu[0].cores
      memory     = container.memory[0].dedicated
    }
  }
}

# Sortie sensible (masquée dans les logs)
output "sensitive_info" {
  description = "Informations sensibles des conteneurs"
  value       = "information_sensible"
  sensitive   = true
}