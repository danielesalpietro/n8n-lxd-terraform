# Logbook compresso — Fase 1

## Stato finale
- Esito: COMPLETATA
- Data/ora fine sessione (UTC): 2026-08-28 ~21:10
- Sub-issue GitHub: #5 — stato: chiusa (criterio di uscita soddisfatto: `terraform.tfvars` compilato e correttamente ignorato da git)
- Commit di riferimento (hash brevi) prodotti in questa sessione: (vedi commit di chiusura Fase 1, subito successivo a questo file)

## Configurazione rilevante per le fasi successive
- container_name: **`n8n-collaudo-f1`** (in `terraform.tfvars`, non versionato) — verificato assente con `lxc list` all'inizio di questa fase. Ricordare comunque di riverificare con `lxc list` prima di ogni `terraform apply`, dato che l'host è condiviso con altri workload.
- storage_pool: **`remote`** (ceph, general-purpose) — scelto tra i pool disponibili (`remote`, `remote-fast`, `nvme-tier`); `remote-fast`/`nvme-tier` non necessari per un container di collaudo.
- rete/bridge usato: rete gestita `default`, tipo OVN, IPv4 `10.126.229.1/24`, IPv6 `fd42:91da:fe0b:e6c1::1/64`, DHCP attivo. Nessuna modifica necessaria in `terraform.tfvars` (il provider LXD usa i profili/rete di default lato host, non referenziata esplicitamente nelle variabili di questo progetto).
- versioni rilevate: invariate rispetto alla Fase 0 — LXD `5.21.4 LTS` (client=server), Terraform `1.15.4`, provider `terraform-lxd/lxd`: non ancora risolto (si risolve in Fase 2 con `terraform init`), Node: non applicabile in questa fase.
- IP del container di test: nessun container ancora creato in questa fase (Fase 1 prepara solo la configurazione, non esegue `terraform apply`).
- Credenziali di test: `db_password` e `n8n_password` generate casualmente (`openssl rand`, 20 caratteri), non riutilizzate altrove, presenti solo in `terraform.tfvars` locale sulla macchina di questa sessione (non versionato, non presente altrove). La Fase 2 dovrà rigenerarle o riutilizzare lo stesso `terraform.tfvars` se eseguita sulla stessa macchina/host — da verificare con l'owner se le fasi successive girano sulla stessa macchina o su una nuova sessione (in tal caso `terraform.tfvars` andrà ricreato, dato che non è versionato).

## Bug riscontrati e fix applicati
Nessun bug riscontrato in questa fase.

## Problemi aperti / non risolti
- **Container `n8n-server` pre-esistente e in uso reale**: confermato ancora RUNNING sull'host, NON toccato in questa fase. Vincolo non negoziabile invariato per tutte le fasi successive.
- `/remote-control` non disponibile in questo ambiente (harness Claude Agent SDK, non terminale interattivo): monitoraggio in tempo reale della sessione da parte del supervisore NON attivo per questa fase. Segnalato esplicitamente; il logbook resta l'unica fonte di verità scritta per questa sessione. Le sessioni successive dovrebbero verificare se il proprio ambiente supporta `/remote-control` prima di darlo per scontato.
- `terraform.tfvars` è locale e non versionato: se la Fase 2 gira su una macchina/sessione diversa da questa, il file (inclusi `container_name`, `storage_pool` e le password generate) dovrà essere ricreato da zero seguendo questo logbook, non sarà recuperabile da git.
- Versione risolta del provider `terraform-lxd/lxd` non ancora nota: sarà annotata dalla Fase 2 (`terraform init` / `terraform providers`).

## Esito checklist di fase
- [x] `terraform.tfvars` compilato con valori coerenti (`storage_pool`, limiti CPU/RAM) con quanto verificato in Fase 0
- [x] `container_name` scelto è un nome di test dedicato, verificato con `lxc list` come non esistente e diverso da `n8n-server`
- [x] Password di test non riutilizzate altrove (dato noto: finiranno in chiaro nel cloud-init e nel tfstate locale — non bloccante ma da tenere a mente)
- [x] Confermato che `terraform.tfvars` NON viene tracciato da git (`.gitignore` funzionante)

## Carry-over ancora valido dalle fasi precedenti
- Container `n8n-server` (RUNNING, creato 2026-05-26): NON toccare mai, in nessuna fase successiva.
- Pool storage Ceph disponibili: `remote` (scelto per il collaudo), `remote-fast`, `nvme-tier`; `local` è zfs, non Ceph.
- Rete `default`, tipo OVN, `10.126.229.1/24`, DHCP attivo.
- LXD `5.21.4 LTS`, Terraform `1.15.4` (v1.16.0 disponibile, non bloccante).
- Accesso internet in uscita dall'host verificato in Fase 0 (HTTP 200 verso registry.terraform.io) — non riverificato in questa fase, presumibilmente invariato.

## Riferimenti
- Handoff seguito: `collaudo/handoff_fase1.md`
- Logbook esteso (facoltativo, solo per approfondimento): `collaudo/logbook_fase1.md`
- Sub-issue: https://github.com/danielesalpietro/n8n-lxd-terraform/issues/5
