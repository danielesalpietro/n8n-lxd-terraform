# Logbook compresso — Fase 3

## Stato finale
- Esito: COMPLETATA
- Data/ora fine sessione (UTC): 2026-08-28 ~22:20
- Sub-issue GitHub: #7 — stato: chiusa (criterio di uscita soddisfatto: piano coerente con le aspettative, nessun errore)
- Commit di riferimento (hash brevi) prodotti in questa sessione: (solo commit dei logbook di questa fase, nessun fix al codice necessario — vedi subito dopo questo file)

## Configurazione rilevante per le fasi successive
- container_name: `n8n-collaudo-f1` (invariato)
- storage_pool: `remote` (invariato)
- rete/bridge usato: `default`, OVN, `10.126.229.1/24` (invariato)
- versioni rilevate: invariate dalla Fase 2 — LXD `5.21.4 LTS`, Terraform `1.15.4` sull'host, provider `terraform-lxd/lxd` v2.7.1
- IP del container di test: non ancora assegnato — `terraform plan` mostra `instance_ip = (known after apply)`; il container non è stato ancora creato (questa fase non esegue `apply`)
- `terraform.tfvars`: invariato, sul clone host `/home/dsalpietro/n8n-lxd-terraform`, riusato dalla Fase 2 senza modifiche
- `tfplan`: piano salvato sull'host (`/home/dsalpietro/n8n-lxd-terraform/tfplan`), **non versionato** (artefatto binario locale). La Fase 4 (presumibilmente `apply`) può riusarlo con `terraform apply "tfplan"` se eseguita sulla stessa sessione/host entro breve tempo, altrimenti va rigenerato con un nuovo `terraform plan -out=tfplan` (il piano salvato può risultare stale se lo stato o la configurazione cambiano nel frattempo).

## Bug riscontrati e fix applicati
Nessun bug riscontrato in questa fase.

## Problemi aperti / non risolti
- **Container `n8n-server`**: confermato ancora RUNNING, non toccato. Vincolo invariato per le fasi successive.
- `/remote-control` non disponibile in questo ambiente: invariato dalle fasi precedenti.
- Il piano (`tfplan`) contiene in forma cifrata/locale le password generate in Fase 2 (necessarie per il rendering del cloud-init): trattarlo come sensibile, non copiarlo/spostarlo fuori dall'host, non versionarlo (già rispettato).

## Esito checklist di fase
- [x] Il piano mostra la creazione di 1 sola risorsa (`lxd_instance.n8n_node`), nessuna modifica/distruzione inattesa (`1 to add, 0 to change, 0 to destroy`)
- [x] Il rendering del cloud-init non mostra placeholder non risolti (verificato via `terraform show -json` + estrazione mirata, 0 placeholder `${...}` residui, senza esporre le password in chiaro)
- [x] Nessun warning/errore da `terraform plan`

## Carry-over ancora valido dalle fasi precedenti
- Container `n8n-server` (RUNNING, creato 2026-05-26): NON toccare mai, in nessuna fase successiva.
- Pool storage Ceph disponibili: `remote` (usato per il collaudo), `remote-fast`, `nvme-tier`; `local` è zfs, non Ceph.
- Rete `default`, tipo OVN, `10.126.229.1/24`, DHCP attivo.
- I comandi Terraform vanno eseguiti sul clone host `/home/dsalpietro/n8n-lxd-terraform` (provider LXD richiede il socket locale), non sul clone Windows.
- `terraform.tfvars` sul clone host: `container_name = "n8n-collaudo-f1"`, `storage_pool = "remote"`, `cpu_limits = "2"`, `ram_limits = "4GB"`, `timezone = "Europe/Rome"`, password di test generate in Fase 2 (non recuperabili da git, non stampate in nessun logbook).

## Riferimenti
- Handoff seguito: `collaudo/handoff_fase3.md`
- Logbook esteso (facoltativo, solo per approfondimento): `collaudo/logbook_fase3.md`
- Sub-issue: https://github.com/danielesalpietro/n8n-lxd-terraform/issues/7
