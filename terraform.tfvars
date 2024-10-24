proxmox_endpoint = "https://192.168.1.6:8006/"

# Ne jamais mettre le api_token dans ce fichier
# Utiliser plutôt une variable d'environnement :
# export TF_VAR_api_token="votre_token"
# api_token = "NE_PAS_METTRE_ICI"

# Nom du nœud Proxmox cible
target_node = "opti-7010"

# Nombre de conteneurs à créer
container_count = 5

# Configuration des conteneurs
vm_hostname = "ubuntu-lxc"

# Ressources de calcul
cores = 2
memory = 2048  # 2 GB

# Configuration du stockage
disk = {
  storage = "local-lvm"
  size    = "20"  # Taille en GB sans le suffixe "G"
}

# Configuration réseau
gateway = "192.168.1.1"
dns_servers = [
  "192.168.1.1",  # Passerelle locale comme DNS primaire
  "1.1.1.1"       # Cloudflare comme DNS secondaire
]

# La clé publique SSH doit être générée au préalable
# Exemple de commande : ssh-keygen -t ed25519 -C "terraform-proxmox"
ssh_public_keys  = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDKW96r73C2mON+Yy9Oxi8BrFiOACz11mYsZYrgrdkC2 deployer@ubuntu-deploy"
]

# Options de démarrage
onboot = true