# Deployment n8n su LXD/MicroCloud con Terraform

Questo repository contiene l'Infrastructure as Code (IaC) per il provisioning automatizzato di un nodo **n8n** self-hosted su un ambiente LXD/MicroCloud.

Il progetto elimina la necessità di interventi manuali post-creazione: l'infrastruttura viene istanziata tramite **Terraform** e il sistema operativo viene configurato in modo imperativo tramite **Cloud-Init** al primissimo avvio del container LXC.

## 🏗️ Architettura
* **Hypervisor/Orchestratore:** LXD / Ubuntu MicroCloud
* **OS Container:** Ubuntu 24.04 LTS
* **Process Manager:** PM2
* **Database:** PostgreSQL (nativo, per massime performance)
* **Runtime:** Node.js 20.x LTS

## 📂 Struttura del Progetto
* `main.tf`: Core del provider LXD e definizione delle risorse compute e storage.
* `variables.tf`: Dichiarazione delle variabili richieste.
* `cloud-init.yaml.tpl`: Template YAML eseguito al boot per installare le dipendenze, configurare il DB e avviare n8n.
* `.gitignore`: Esclusioni per proteggere il file di stato (`.tfstate`) e le credenziali.

## 🚀 Utilizzo
1. Clonare il repository.
2. Creare un file `terraform.tfvars` (ignorato da Git per sicurezza) partendo dalle variabili definite in `variables.tf`.
3. Inizializzare il progetto: `terraform init`
4. Verificare il piano di esecuzione: `terraform plan`
5. Eseguire il deployment: `terraform apply`

## 👤 Autore
**Daniele Carmelo Salpietro**
*Senior Cloud & AI Architect*
