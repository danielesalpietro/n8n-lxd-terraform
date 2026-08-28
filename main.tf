# main.tf
terraform {
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "~> 2.0"
    }
  }
}

# Connessione al socket locale di LXD
provider "lxd" {
  generate_client_certificates = true
  accept_remote_certificate    = true
}

# Creazione del Container LXC
resource "lxd_instance" "n8n_node" {
  name      = var.container_name
  image     = "ubuntu:24.04"
  ephemeral = false
  profiles  = ["default"]

  limits = {
    cpu    = var.cpu_limits
    memory = var.ram_limits
  }

  # Configurazione storage (es. backend Ceph)
  device {
    name = "root"
    type = "disk"
    properties = {
      path = "/"
      pool = var.storage_pool
    }
  }

  # Iniezione del cloud-init (templatefile nativo: nessun provider esterno deprecato)
  config = {
    "user.user-data" = templatefile("${path.module}/cloud-init.yaml.tpl", {
      db_user      = var.db_user
      db_password  = var.db_password
      n8n_user     = var.n8n_user
      n8n_password = var.n8n_password
      timezone     = var.timezone
    })
  }
}

output "instance_ip" {
  description = "Indirizzo IP del container n8n (attendere l'assegnazione DHCP)"
  value       = lxd_instance.n8n_node.ipv4_address
}
