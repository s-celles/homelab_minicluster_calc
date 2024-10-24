# Token d'API pour l'authentification Proxmox
# À définir via une variable d'environnement ou un fichier tfvars
variable "api_token" {
  description = "Token pour la connexion à l'API Proxmox"
  type        = string
  sensitive   = true
}

# Endpoint de l'API Proxmox
variable "proxmox_endpoint" {
  description = "URL de l'API Proxmox (exemple: https://192.168.1.7:8006/)"
  type        = string

  validation {
    condition     = can(regex("^https://.*:\\d+/$", var.proxmox_endpoint))
    error_message = "L'endpoint doit être une URL HTTPS valide se terminant par un port et un slash (exemple: https://192.168.1.7:8006/)"
  }
}

# Nombre de conteneurs à créer
variable "container_count" {
  description = "Nombre de conteneurs LXC à créer"
  type        = number
  default     = 1

  validation {
    condition     = var.container_count >= 0 && var.container_count <= 10
    error_message = "Le nombre de conteneurs doit être entre 0 et 10."
  }
}

# Nœud Proxmox cible pour le déploiement
variable "target_node" {
  description = "Nom du nœud Proxmox pour le déploiement"
  type        = string
  default     = "pve"
}

# Nom de base pour les conteneurs
variable "vm_hostname" {
  description = "Préfixe de nom d'hôte pour les conteneurs"
  type        = string
  default     = "lxc-ubuntu"

  validation {
    condition     = length(var.vm_hostname) > 2 && length(var.vm_hostname) <= 63
    error_message = "Le nom d'hôte doit faire entre 3 et 63 caractères."
  }
}

# Template du conteneur à utiliser
variable "template_file_id" {
  description = "ID du template de conteneur à utiliser"
  type        = string
  default     = "local:vztmpl/ubuntu-24.04-standard_24.04-2_amd64.tar.zst"
}

# Configuration du processeur
variable "cores" {
  description = "Nombre de cœurs CPU à allouer"
  type        = number
  default     = 2

  validation {
    condition     = var.cores > 0 && var.cores <= 8
    error_message = "Le nombre de cœurs doit être entre 1 et 8."
  }
}

# Configuration de la mémoire
variable "memory" {
  description = "Quantité de mémoire en MB"
  type        = number
  default     = 2048

  validation {
    condition     = var.memory >= 512 && var.memory <= 16384
    error_message = "La mémoire doit être entre 512 MB et 16 GB."
  }
}

# Configuration du disque
variable "disk" {
  description = "Configuration du stockage"
  type = object({
    storage = string
    size    = string
  })
  default = {
    storage = "local-lvm"
    size    = "20"  # Taille en GB sans le suffixe
  }

  validation {
    condition     = can(tonumber(var.disk.size))
    error_message = "La taille du disque doit être un nombre (en GB) sans suffixe."
  }
}

# Configuration du démarrage automatique
variable "onboot" {
  description = "Démarrer le conteneur au boot du système"
  type        = bool
  default     = true
}

# Configuration réseau
variable "gateway" {
  description = "Passerelle réseau par défaut"
  type        = string
  default     = "192.168.1.1"

  validation {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}$", var.gateway))
    error_message = "L'adresse de la passerelle doit être une IPv4 valide."
  }
}

# Serveurs DNS
variable "dns_servers" {
  description = "Liste des serveurs DNS"
  type        = list(string)
  default     = ["192.168.1.1", "1.1.1.1"]

  validation {
    condition     = length(var.dns_servers) > 0
    error_message = "Au moins un serveur DNS doit être spécifié."
  }
}

# Clé SSH publique pour l'accès aux conteneurs
variable "ssh_public_keys" {
  description = "Liste des clés SSH publiques pour l'accès aux conteneurs"
  type        = list(string)

  validation {
    condition     = length(var.ssh_public_keys) > 0
    error_message = "Au moins une clé SSH publique doit être fournie."
  }

  validation {
    condition = alltrue([
      for key in var.ssh_public_keys :
      can(regex("^(ssh-rsa|ssh-ed25519|ssh-dss)", key))
    ])
    error_message = "Toutes les clés doivent être dans un format SSH valide (ssh-rsa, ssh-ed25519, ou ssh-dss)."
  }
}