# Logbook esteso — Fase 1: Preparazione configurazione

## Sessione
- Sessione operativa locale (Windows, accesso SSH reale via PuTTY `plink` verso host MicroCloud `micro01`, 192.168.1.100).
- `/remote-control` **non disponibile in questo ambiente** (harness Claude Agent SDK / CCD, non terminale interattivo classico): i comandi terminal-dialog come `/remote-control` risultano non invocabili come tool in questa sessione. Segnalato come da istruzioni del prompt di avvio; monitoraggio in tempo reale via `/remote-control` NON attivo per questa sessione. Il logbook (questo file + il compresso) resta la fonte di verità scritta, come previsto da CLAUDE.md.
- Governance letta: `CLAUDE.md` (root repo) — nessuna modifica apportata alle direttive.
- Branch: `claude/repo-status-mydlk3`, aggiornato con `git fetch` + verifica stato (già allineato a `origin`, nessun rebase necessario: working tree già pulito e up to date).
- `collaudo/logbook_fase0_compresso.md` letto per intero prima di aprire altro materiale, come da istruzioni.

## Verifiche preliminari sull'host (SSH reale, non simulato)
Comandi eseguiti via `plink -ssh -batch -pw ... dsalpietro@192.168.1.100 "..."`:

- `lxc list`: confermato che `n8n-collaudo-f1` **non esiste** sull'host. Container presenti: `WinSrv19` (VM, stopped), `deciding-pig` (container, stopped), `docker-node` (container, running), `holy-yak` (container, stopped, 1 snapshot), `more-alien` (VM, stopped), **`n8n-server` (container, RUNNING, 1 snapshot)** — solo ispezionato in sola lettura, NON toccato, NON modificato, NON riavviato — `stirring-lemur` (VM, stopped).
- `lxc storage list`: confermati i pool già rilevati in Fase 0 — `local` (zfs), `nvme-tier` (ceph, used by 0), `remote` (ceph, "Distributed storage on Ceph", used by 9), `remote-fast` (ceph, used by 3).
- `lxc network list`: confermata rete gestita `default`, tipo `ovn`, IPv4 `10.126.229.1/24`, IPv6 `fd42:91da:fe0b:e6c1::1/64` — coerente con quanto riportato in Fase 0.

## Decisione: storage_pool

Scelto `remote` (Ceph, "Distributed storage on Ceph") come `storage_pool` per il container di test. Motivazione: è il pool Ceph general-purpose, già in uso da 9 istanze (incluso presumibilmente `n8n-server` stesso, non verificato nel dettaglio per non rischiare di toccarlo), indicato in Fase 0 come "candidato più plausibile". `remote-fast` e `nvme-tier` sono lasciati per workload che richiedono performance dedicate, non necessari per un container di collaudo.

## terraform.tfvars

Creato copiando `terraform.tfvars.example` e compilando:

- `container_name = "n8n-collaudo-f1"` — verificato assente con `lxc list` (vedi sopra), diverso da `n8n-server`.
- `cpu_limits = "2"`, `ram_limits = "4GB"` — valori contenuti, adeguati a un container di collaudo (l'example usava 4 vCPU / 8GB, sovradimensionato per un test).
- `storage_pool = "remote"` — vedi decisione sopra.
- `db_user = "n8n_user"`, `db_password` — generata con `openssl rand -base64 18` (20 caratteri, troncata, priva di caratteri `=+/`), non riutilizzata altrove, non stampata in questa sessione né in nessun file di log. Valore presente solo in `terraform.tfvars` locale (non versionato).
- `n8n_user = "admin"`, `n8n_password` — generata allo stesso modo, indipendente dalla password del DB.
- `timezone = "Europe/Rome"` — invariato dall'example.

Nota di sicurezza operativa: le password sono state generate e scritte direttamente in `terraform.tfvars` all'interno dello stesso comando shell, senza passare da file temporanei intermedi, per minimizzare l'esposizione.

## Verifica non-tracciamento git

- `git status` dopo la creazione di `terraform.tfvars`: working tree pulito, il file NON compare come untracked.
- `git check-ignore -v terraform.tfvars` → `.gitignore:25:terraform.tfvars terraform.tfvars` (regola che lo esclude, confermata attiva).

## Esito

Nessun bug riscontrato in questa fase. Nessuna modifica al codice versionato del repository (solo creazione del file locale `terraform.tfvars`, non tracciato, e dei logbook di questa fase).

## Riferimenti
- Handoff seguito: `collaudo/handoff_fase1.md`
- Sub-issue: https://github.com/danielesalpietro/n8n-lxd-terraform/issues/5
