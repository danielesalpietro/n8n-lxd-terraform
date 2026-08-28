# Handoff — Collaudo e Sviluppo Procedura di Installazione n8n su LXD/MicroCloud

## Contesto

Il progetto (`main.tf`, `variables.tf`, `cloud-init.yaml.tpl`) è stato **scritto ma mai eseguito**. Non esiste alcuna evidenza che `terraform apply` funzioni, che il cloud-init si completi senza errori o che n8n sia effettivamente raggiungibile a fine provisioning.

Questo documento è l'handoff per la sessione che avrà **accesso SSH diretto all'host MicroCloud/LXD** ed eseguirà lo sviluppo iterativo e il collaudo (Fase 1) della procedura. Segui le fasi in ordine: ogni fase presuppone che la precedente sia stata superata.

Aggiorna il **Registro Problemi** (in fondo al documento) ad ogni anomalia riscontrata, anche se poi risolta — serve come base per la Fase 2 (hardening) successiva.

---

## Ruoli e ambito

- Ambiente target: host fisico/VM con **MicroCloud** (LXD + Ceph) già inizializzato e funzionante.
- Accesso: SSH con utente che ha permessi `lxd`/`sudo` sull'host.
- Obiettivo Fase 1: **collaudo end-to-end** della procedura di provisioning automatico — non ottimizzazione, non hardening di sicurezza (basic auth in chiaro nelle env vars è un problema noto, da trattare in una fase successiva).

---

## Fase 0 — Verifica ambiente e accessi

Da eseguire **prima di toccare il codice**, per non scambiare un problema di ambiente per un bug della procedura.

- [ ] SSH funzionante verso l'host MicroCloud
- [ ] `lxc list` restituisce output senza errori (client LXD configurato)
- [ ] `lxc storage list` — verifica che il pool indicato in `terraform.tfvars` (`storage_pool`) esista davvero (es. pool Ceph)
- [ ] `lxc network list` — verifica presenza di un bridge/rete che assegni IP via DHCP ai container (necessario per l'output `instance_ip`)
- [ ] `lxc image list ubuntu:24.04` o comunque conferma che l'host possa scaricare/ha in cache l'immagine `ubuntu:24.04` dal remote configurato
- [ ] Terraform installato: `terraform version` (annotare la versione — la procedura richiede provider `terraform-lxd/lxd ~> 2.0`)
- [ ] Accesso internet in uscita dall'host per il download provider Terraform (registry.terraform.io) e, più avanti, dal **container** per npm/NodeSource/apt
- [ ] `git clone` del repository sull'host, checkout del branch di lavoro

**Criterio di uscita Fase 0:** tutti i punti sopra verificati. Annotare versioni di LXD, Terraform, e nome esatto del pool/rete da usare in `terraform.tfvars`.

---

## Fase 1 — Preparazione configurazione

```bash
cd n8n-lxd-terraform
cp terraform.tfvars.example terraform.tfvars
```

- [ ] Compilare `terraform.tfvars` con valori reali coerenti con quanto verificato in Fase 0 (`storage_pool`, `container_name`, limiti CPU/RAM)
- [ ] Password di test **non riutilizzate altrove** (verranno scritte in chiaro nel cloud-init e nel tfstate locale — è un dato noto, non bloccante per il collaudo ma da segnalare)
- [ ] Confermare che `terraform.tfvars` NON venga tracciato da git (`git status` deve risultare pulito dopo la modifica — protetto da `.gitignore`)

**Criterio di uscita:** `terraform.tfvars` compilato e ignorato da git.

---

## Fase 2 — Validazione statica (prima di qualunque apply)

Questa fase serve a intercettare errori di sintassi/schema **prima** di creare risorse reali.

```bash
terraform init
terraform fmt -check -diff
terraform validate
```

Punti di attenzione noti (verificare esplicitamente, sono i sospetti principali in caso di errore qui):

- [ ] `terraform init` scarica correttamente il provider `terraform-lxd/lxd`
- [ ] `terraform init` risolve il data source `template_file` — proviene dal provider `hashicorp/template`, **deprecato/archiviato** e non dichiarato in `required_providers` in `main.tf`. Se init fallisce o mostra warning di deprecazione, annotarlo: potrebbe essere necessario dichiararlo esplicitamente o sostituirlo con `templatefile()` nativo di Terraform (soluzione moderna, senza provider esterno).
- [ ] `terraform validate` su `variables.tf`: le righe `variable "db_password" { type = string, sensitive = true }` e `variable "n8n_password" { type = string, sensitive = true }` usano una virgola per separare gli argomenti sulla stessa riga. Verificare che non generi errore di parsing HCL ("Missing newline after argument" o simile). Se fallisce, va corretto andando a capo:
  ```hcl
  variable "db_password" {
    type      = string
    sensitive = true
  }
  ```
- [ ] Verificare che lo schema del resource `lxd_instance` (blocchi `limits`, `device`, `config`) sia compatibile con la versione 2.x del provider effettivamente scaricata (`terraform providers` per vedere la versione risolta)

**Criterio di uscita:** `terraform validate` passa senza errori. Ogni correzione applicata al codice va committata separatamente con messaggio chiaro (es. `fix(variables): sintassi HCL non valida`).

---

## Fase 3 — Plan

```bash
terraform plan -out=tfplan
```

- [ ] Il piano mostra la creazione di **1 risorsa** (`lxd_instance.n8n_node`) e la generazione del data source cloud-init, nessuna modifica/distruzione inattesa
- [ ] Ispezionare il rendering del cloud-init nel piano (o con `terraform console` / output intermedio) per confermare che le variabili vengano interpolate correttamente e non compaiano placeholder tipo `${db_user}` non risolti

**Criterio di uscita:** piano coerente con le aspettative, nessun errore.

---

## Fase 4 — Apply e monitoraggio provisioning

```bash
terraform apply tfplan
```

Poi, immediatamente dopo la creazione del container:

```bash
lxc list                          # verifica stato RUNNING e assegnazione IP
lxc exec <container_name> -- cloud-init status --wait   # attende fine cloud-init
lxc exec <container_name> -- cat /var/log/cloud-init-output.log
```

- [ ] Container in stato `RUNNING`
- [ ] `cloud-init status --wait` termina con `status: done` (non `error`)
- [ ] Nessun errore negli step `runcmd` dentro `/var/log/cloud-init-output.log` — controllare in particolare:
  - download/import chiave GPG NodeSource (`curl` verso `deb.nodesource.com`)
  - `apt-get install -y nodejs` completa senza conflitti
  - i comandi `psql` di creazione DB/utente/permessi non falliscono per ordine o sintassi
  - `npm install -g n8n pm2` completa (può richiedere diversi minuti — non interpretare la lentezza come blocco)
  - l'ultimo comando (`pm2 startup systemd ... | tail -1 | bash`) è fragile per costruzione: verificare che l'output di `pm2 startup` sia effettivamente un comando eseguibile eseguito con successo dalla pipe, non solo testo informativo

**Criterio di uscita:** cloud-init `done`, nessun errore critico in log. In caso di errore, annotare lo step esatto nel Registro Problemi prima di correggere.

---

## Fase 5 — Checklist funzionale dei servizi

Questa checklist va eseguita **sia durante lo sviluppo** (ad ogni iterazione di fix, per verificare che non si stiano introducendo regressioni) **sia a fine collaudo** come verifica finale. Eseguire tutti i comandi tramite `lxc exec <container_name> -- <comando>` salvo diversa indicazione.

### 5.1 Sistema di base
- [ ] `cloud-init status` → `done`
- [ ] `node -v` → versione Node 20.x
- [ ] `npm -v` risponde

### 5.2 PostgreSQL
- [ ] `systemctl is-active postgresql` → `active`
- [ ] `sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw n8n` → il database `n8n` esiste
- [ ] `sudo -u postgres psql -c "\du"` → l'utente definito in `db_user` esiste con i permessi corretti
- [ ] Connessione applicativa: `PGPASSWORD=<db_password> psql -h localhost -U <db_user> -d n8n -c '\conninfo'` → connessione riuscita (verifica reale delle credenziali usate da n8n, non solo esistenza utente)

### 5.3 n8n / PM2
- [ ] `pm2 list` → processo `n8n` presente, stato `online`, non in `errored`/restart loop
- [ ] `pm2 logs n8n --lines 50 --nostream` → nessun errore di connessione al DB, nessun crash all'avvio
- [ ] `curl -I http://localhost:5678` (porta default n8n) dall'interno del container → risposta HTTP (401 atteso se basic auth attiva, non 000/connection refused)
- [ ] Login da browser/curl con le credenziali `n8n_user`/`n8n_password` di `terraform.tfvars` → accesso riuscito alla UI
- [ ] Raggiungibilità **dall'host MicroCloud** e, se pertinente, dalla rete locale, usando l'IP riportato in output `instance_ip` (`terraform output instance_ip`)
- [ ] Creare un workflow minimo di prova (es. Manual Trigger → Set) e salvarlo → verifica scrittura effettiva su Postgres (non solo UI raggiungibile)
- [ ] Riavviare n8n (`pm2 restart n8n`) e verificare che il workflow di prova sia ancora presente dopo il riavvio → conferma persistenza su DB reale, non su storage in-memory/sqlite di fallback

### 5.4 Fuso orario
- [ ] `timedatectl` o `date` nel container coerente con `timezone` impostato
- [ ] Un nodo Schedule/Cron di prova in n8n si attiva all'orario locale atteso (non UTC)

**Criterio di uscita Fase 5:** tutte le voci verificate su almeno un ciclo completo `apply` → checklist → `destroy`.

---

## Fase 6 — Test di resilienza

Da eseguire dopo che la Fase 5 passa in modo pulito, per verificare la persistenza reale (non solo "funziona finché il container non viene riavviato").

- [ ] `lxc restart <container_name>` → attendere boot, poi ripetere l'intera Fase 5 sezione 5.3: `pm2` deve ripartire automaticamente (verifica reale dell'effetto di `pm2 startup systemd` + `pm2 save`)
- [ ] Riavvio dell'host MicroCloud (se autorizzato e concordato — **azione impattante, chiedere conferma prima di eseguirla**) → verificare che il container riparta automaticamente e che n8n torni disponibile senza intervento manuale
- [ ] Verificare che i dati creati in Fase 5 (workflow di prova) sopravvivano a entrambi i riavvii

**Criterio di uscita:** n8n si autoripristina dopo restart del container senza intervento manuale.

---

## Fase 7 — Cleanup / rollback

```bash
terraform destroy
```

- [ ] Container rimosso correttamente (`lxc list` non lo mostra più)
- [ ] Nessuna risorsa orfana residua (volumi storage, se il pool non gestisce la cancellazione automatica — verificare con `lxc storage volume list <pool>`)
- [ ] `terraform.tfstate` locale ripulito/coerente (nessuna risorsa fantasma in `terraform show`)

Ripetere il ciclo Fase 3 → Fase 7 ad ogni correzione significativa al codice, per confermare che il fix non abbia rotto altro.

---

## Registro problemi riscontrati

Compilare per ogni anomalia, anche minore. Serve come input per la fase successiva di hardening/fix definitivo.

| # | Fase | Descrizione problema | Log/evidenza | Fix applicato (se sì) | Stato |
|---|------|----------------------|---------------|------------------------|-------|
| 1 |      |                       |               |                        |       |

---

## Definition of Done — Fase 1 (collaudo)

La Fase 1 si considera completata quando:

1. Un ciclo completo `terraform apply` → checklist Fase 5 interamente verde → `terraform destroy` è stato eseguito **senza interventi manuali correttivi durante l'apply** (ogni fix è stato riportato nel codice sorgente, non fatto a mano nel container).
2. Il test di resilienza (Fase 6, almeno restart del container) è stato superato.
3. Il Registro Problemi è compilato e condiviso, con indicazione di quali problemi restano aperti/da pianificare per la fase successiva.
