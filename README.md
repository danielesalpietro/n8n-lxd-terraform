# n8n su LXD/MicroCloud con Terraform

Deploy automatizzato di [n8n](https://n8n.io) in un container LXC su MicroCloud, con PostgreSQL come database e PM2 come process manager. Il provisioning è interamente gestito da cloud-init, senza accesso manuale al container.

## Architettura

```
Host MicroCloud (192.168.1.x)
│
├── Terraform  →  crea il container LXC + proxy device
│
└── Container LXC "n8n-server" (10.126.229.x)
    ├── cloud-init (eseguito al primo boot)
    │   ├── installa Node.js 20 LTS, PostgreSQL, gnupg
    │   ├── configura il database PostgreSQL
    │   ├── installa n8n e PM2 via npm
    │   └── avvia n8n con PM2 (persistente al riavvio)
    └── Proxy device LXD  →  :5678 host → :5678 container
```

- **Hypervisor**: LXD / Ubuntu MicroCloud
- **OS Container**: Ubuntu 24.04 LTS
- **Runtime**: Node.js 20.x LTS
- **Process Manager**: PM2
- **Database**: PostgreSQL 16 (locale al container)

## Struttura del progetto

```
.
├── main.tf                   # Risorse Terraform (container, proxy, cloud-init)
├── variables.tf              # Dichiarazione delle variabili
├── cloud-init.yaml.tpl       # Template cloud-init per il provisioning
├── terraform.tfvars.example  # Esempio di configurazione (copiare e personalizzare)
└── .gitignore                # Esclude terraform.tfvars e file di stato
```

## Prerequisiti

- MicroCloud/LXD installato e configurato sull'host
- Terraform >= 1.0
- Provider Terraform LXD `terraform-lxd/lxd ~> 2.0`
- Accesso al socket LXD dall'utente che esegue Terraform

## Configurazione

### 1. Clona il repository

```bash
git clone https://github.com/danielesalpietro/n8n-lxd-terraform.git
cd n8n-lxd-terraform
```

### 2. Crea il file delle variabili

```bash
cp terraform.tfvars.example terraform.tfvars
```

Modifica `terraform.tfvars` con i tuoi valori:

| Variabile | Descrizione | Esempio |
|-----------|-------------|---------|
| `container_name` | Nome del container LXC | `n8n-server` |
| `cpu_limits` | Numero di vCPU | `4` |
| `ram_limits` | RAM assegnata | `8GB` |
| `storage_pool` | Pool di storage LXD | `default` |
| `db_user` | Utente PostgreSQL per n8n | `n8n_user` |
| `db_password` | Password del database | *(password sicura)* |
| `n8n_user` | Utente per la web UI di n8n | `admin` |
| `n8n_password` | Password per la web UI di n8n | *(password sicura)* |
| `timezone` | Fuso orario per i nodi Schedule | `Europe/Rome` |

> `terraform.tfvars` è escluso dal versioning tramite `.gitignore`. Non committare mai credenziali reali.

## Deploy

### 1. Inizializza Terraform

```bash
terraform init
```

### 2. Verifica il piano

```bash
terraform plan
```

### 3. Applica

```bash
terraform apply
```

Terraform crea il container e cloud-init esegue automaticamente al primo boot:

1. Installazione di Node.js 20 LTS, PostgreSQL, gnupg
2. Configurazione del database PostgreSQL e dell'utente dedicato
3. Installazione di n8n e PM2 via npm (~5-10 minuti per le dipendenze)
4. Avvio di n8n tramite PM2 con persistenza al riavvio del container

### 4. Accesso a n8n

Una volta completato il provisioning (attendere ~10 minuti dal `terraform apply`):

```
http://<IP-host-MicroCloud>:5678
```

Il proxy device LXD espone automaticamente la porta 5678 del container sull'host, rendendola raggiungibile da tutta la LAN.

## Monitoraggio del provisioning

Per seguire il log di cloud-init in tempo reale:

```bash
lxc exec n8n-server -- tail -f /var/log/cloud-init-output.log
```

Per verificare che il provisioning sia completato:

```bash
lxc exec n8n-server -- cloud-init status --wait
lxc exec n8n-server -- pm2 list
```

Il provisioning è completato quando compare la riga:

```
Cloud-init finished at ...
```

## Gestione del container

### Controllare lo stato di n8n

```bash
lxc exec n8n-server -- pm2 list
lxc exec n8n-server -- pm2 logs n8n
```

### Riavviare n8n

```bash
lxc exec n8n-server -- pm2 restart n8n
```

### Aggiornare n8n

```bash
lxc exec n8n-server -- npm install -g n8n@latest
lxc exec n8n-server -- pm2 restart n8n
```

## Ricreazione del container

```bash
# Distrugge e ricrea tutto
terraform destroy && terraform apply

# Ricrea solo il container senza toccare altro
terraform apply -replace="lxd_instance.n8n_node"
```

## Note tecniche

- **Node.js**: installato tramite repository NodeSource con chiave GPG, metodo affidabile in ambienti non interattivi come cloud-init (il tradizionale `curl | bash` fallisce silenziosamente).
- **ecosystem.config.js**: scritto tramite la sezione `write_files` di cloud-init prima dell'esecuzione di `runcmd`, evitando heredoc fragili dentro la lista dei comandi.
- **PM2 startup**: il comando `pm2 startup` genera uno script systemd eseguito immediatamente tramite pipe a `bash`, garantendo la persistenza al riavvio del container.
- **N8N_SECURE_COOKIE**: disabilitato per accesso HTTP su LAN. Per ambienti esposti su internet configurare TLS e rimuovere questa variabile.
- **`#cloud-config`**: deve essere la prima riga assoluta del file — nessun commento o riga vuota prima, altrimenti cloud-init ignora silenziosamente l'intero file.

## Autore

**Daniele Carmelo Salpietro** — Senior Cloud & AI Architect
