# Logbook compresso — Fase 4

## Stato finale
- Esito: COMPLETATA CON RISERVE
- Data/ora fine sessione (UTC): 2026-08-28 ~22:00
- Sub-issue GitHub: #8 — stato: chiusa (criterio di uscita soddisfatto al terzo tentativo: cloud-init `done`, nessun errore critico in log; riserva: due bug reali nel cloud-init erano bloccanti e sono stati corretti in questa fase, impattano la CI `e2e-regression.yml` — supervisore da informare esplicitamente come da nota dell'handoff)
- Commit di riferimento (hash brevi) prodotti in questa sessione: `ea1b9a8` (fix magic header `#cloud-config`), `e8b49f9` (fix pipe `pm2 startup`), più commit dei logbook di questa fase (vedi subito dopo questo file)

## Configurazione rilevante per le fasi successive
- container_name: `n8n-collaudo-f1` — **ora esiste realmente, RUNNING**, IP `10.126.229.9`
- storage_pool: `remote` (invariato)
- rete/bridge usato: `default`, OVN, `10.126.229.1/24` (invariato)
- versioni rilevate: LXD `5.21.4 LTS`, Terraform `1.15.4`/provider `terraform-lxd/lxd` v2.7.1 (invariati); **dentro il container**: Node `v20.20.2`, npm `10.8.2`, n8n e pm2 installati globalmente (`/usr/bin/n8n`, `/usr/bin/pm2`), PostgreSQL con database `n8n` (owner `n8n_user`)
- IP del container di test: **`10.126.229.9`** (assegnato via DHCP sulla rete OVN `default`) — **il container va lasciato ACCESO per la Fase 5**, che verifica i servizi sullo stesso container
- `terraform.tfvars`: invariato, sul clone host `/home/dsalpietro/n8n-lxd-terraform`

## Bug riscontrati e fix applicati
| Bug | Fix applicato | Commit |
|-----|----------------|--------|
| `cloud-init.yaml.tpl` iniziava con un commento prima di `#cloud-config`: cloud-init non riconosce il formato e ignora silenziosamente tutte le direttive (packages/write_files/runcmd mai eseguiti, nessun pacchetto installato) — status: degraded done, exit 2 | Rimossa la riga di commento iniziale, `#cloud-config` ora è la prima riga del file | `ea1b9a8` |
| Ultimo comando `runcmd`: `pm2 startup systemd -u root --hp /root \| tail -1 \| bash` — da root pm2 si auto-configura e l'ultima riga stampata è solo un suggerimento testuale (`$ pm2 unstartup systemd`), non un comando; la pipe lo esegue letteralmente e fallisce (`bash: line 1: $: command not found`), facendo fallire l'intero runcmd — status: error, exit 1 | Rimossa la pipe; `pm2 startup systemd -u root --hp /root` invocato direttamente | `e8b49f9` |

## Problemi aperti / non risolti
- **Container `n8n-server`**: confermato ancora RUNNING, mai toccato durante i 3 cicli create/destroy di questa fase (mai presente in `terraform state list`). Vincolo invariato per le fasi successive.
- `/remote-control` non disponibile in questo ambiente: invariato.
- I due bug corretti in questa fase erano presenti nel `cloud-init.yaml.tpl` sin dall'inizio del collaudo (non introdotti da fasi precedenti) e **impattano potenzialmente `.github/workflows/e2e-regression.yml`** (CI end-to-end): il supervisore va informato esplicitamente via commento sulla sub-issue #8, come richiesto dalla nota dell'handoff, anche se già corretti in questa sessione.
- Il container `n8n-collaudo-f1` attuale è il risultato del terzo apply (i primi due erano falliti e sono stati distrutti prima di richiudere il ciclo): nessun residuo dei tentativi falliti rimane sull'host.
- **Gap nella CI `e2e-regression.yml`** (non corretto in questa fase, fuori scope): lo step "Attendi completamento cloud-init" verifica solo `grep -q "status: done"` sull'output di `cloud-init status`; il bug #1 di questa fase (magic header) produceva comunque `status: done` come prima riga (solo `extended_status: degraded done` segnalava il problema), quindi quella CI **non avrebbe intercettato** un provisioning completamente non eseguito. Segnalato al supervisore, decisione su eventuale fix rimandata.

## Esito checklist di fase
- [x] Container in stato `RUNNING`
- [x] `cloud-init status --wait` termina con `status: done` (non `error`)
- [x] Download/import chiave GPG NodeSource senza errori
- [x] `apt-get install -y nodejs` completa senza conflitti (`node v20.20.2`, `npm 10.8.2`)
- [x] I comandi `psql` di creazione DB/utente/permessi non falliscono (ordine corretto: CREATE DATABASE → CREATE ROLE → GRANT → ALTER DATABASE)
- [x] `npm install -g n8n pm2` completa (`added 1996 packages`)
- [x] `pm2 startup systemd` produce ed esegue un comando valido (`systemctl is-enabled pm2-root` → `enabled`)

Verifica applicativa aggiuntiva (oltre alla checklist minima): `pm2 list` → processo `n8n` `online`; `curl http://localhost:5678/` dal container → `HTTP 200`.

## Carry-over ancora valido dalle fasi precedenti
- Container `n8n-server` (RUNNING, creato 2026-05-26): NON toccare mai, in nessuna fase successiva.
- Pool storage Ceph disponibili: `remote` (usato per il collaudo), `remote-fast`, `nvme-tier`; `local` è zfs, non Ceph.
- Rete `default`, tipo OVN, `10.126.229.1/24`, DHCP attivo.
- I comandi Terraform/`lxc` vanno eseguiti sul clone host `/home/dsalpietro/n8n-lxd-terraform`, non sul clone Windows.
- `terraform.tfvars` sul clone host: `container_name = "n8n-collaudo-f1"`, `storage_pool = "remote"`, `cpu_limits = "2"`, `ram_limits = "4GB"`, `timezone = "Europe/Rome"`, password di test generate in Fase 2 (non recuperabili da git, non stampate in nessun logbook).

## Riferimenti
- Handoff seguito: `collaudo/handoff_fase4.md`
- Logbook esteso (facoltativo, solo per approfondimento): `collaudo/logbook_fase4.md`
- Sub-issue: https://github.com/danielesalpietro/n8n-lxd-terraform/issues/8
