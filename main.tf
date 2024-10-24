# Configuration du provider Terraform
terraform {
  required_providers {
    # Utilisation du provider Proxmox de BPG
    proxmox = {
      source = "bpg/proxmox"
      version = "0.42.0"
    }
  }
}

# Configuration du fournisseur Proxmox
provider "proxmox" {
  # URL de l'API Proxmox
  endpoint = var.proxmox_endpoint
  # Token d'authentification (à définir dans les variables)
  api_token = var.api_token
  # Désactive la vérification SSL pour les environnements de test
  insecure = true
  # Configuration SSH pour l'accès root
  ssh {
    agent = true
    username = "root"
  }
}

# Définition des conteneurs LXC
resource "proxmox_virtual_environment_container" "lxc_container" {
  # Nombre de conteneurs à créer
  count = var.container_count
  # Description pour l'identification dans Proxmox
  description = "Managed by Terraform"
  # Nœud Proxmox cible
  node_name = var.target_node
  # ID de la VM (incrémenté pour chaque conteneur)
  vm_id = 241201 + count.index

  # Ajout de tags au conteneur
  # Les tags peuvent être utilisés pour identifier et organiser les conteneurs
  # Plusieurs tags peuvent être ajoutés, séparés par des points-virgules
  tags = [
    "calcul-distribue",                # Tag pour identifier le type d'usage
    "julia-worker-${count.index + 1}", # Tag unique pour chaque worker
    "terraform-managed"                # Tag indiquant la gestion par Terraform
  ]

  # Configuration initiale du conteneur
  initialization {
    # Nom d'hôte avec index
    hostname = "${var.vm_hostname}-${count.index + 1}"
    
    # Configuration IP
    ip_config {
      ipv4 {
        # Attribution d'une IP statique dans la plage 192.168.1.201+
        address = "192.168.1.${201 + count.index}/24"
        gateway = var.gateway
      }
    }
    
    # Configuration utilisateur avec clé SSH
    user_account {
      keys = var.ssh_public_keys
    }
  }

  # Configuration réseau
  network_interface {
    name = "eth0"
    bridge = "vmbr0"
  }

  # Système d'exploitation
  operating_system {
    template_file_id = var.template_file_id
    type = "ubuntu"
  }

  # Ressources CPU
  cpu {
    cores = var.cores
  }

  # Allocation mémoire
  memory {
    dedicated = var.memory
  }

  # Configuration stockage
  disk {
    datastore_id = var.disk.storage
    size         = var.disk.size
  }

  # Fonctionnalités avancées
  features {
    nesting = true
  }

  # Démarrage automatique
  start_on_boot = var.onboot
  # Mode non privilégié pour plus de sécurité
  unprivileged = true
}