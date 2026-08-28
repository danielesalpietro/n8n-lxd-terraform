# Logbook esteso — Fase 0

Sessione operativa locale (Claude Code), branch `claude/repo-status-mydlk3`.
Testo libero, append-only. Non è il documento da leggere per le fasi successive: vedi `collaudo/logbook_fase0_compresso.md`.

## Setup sessione

- `/remote-control` non disponibile in questo ambiente (comando non riconosciuto: "isn't available in this environment"). Procedo senza supervisione in tempo reale, come previsto da `CLAUDE.md` §2 in caso di indisponibilità.
- Verifica accesso SSH reale: `ssh dsalpietro@192.168.1.100` (via plink, auth password) → `hostname` = `micro01`, `uptime` = `19:28:20 up 9:46, 2 users, load average: 0.40, 0.26, 0.21`. Accesso confermato reale, non simulato.
- Letto `CLAUDE.md`: direttive di governance del collaudo, nessuna modifica apportata.
- `git fetch origin` / `git checkout claude/repo-status-mydlk3` / `git pull --rebase origin claude/repo-status-mydlk3`: branch esisteva già su origin (`04ef87a`), checkout pulito, nessun conflitto.

## Esecuzione checklist (§3 di `handoff_fase0.md`)

Comandi eseguiti via SSH sull'host `192.168.1.100` (utente `dsalpietro`):

```
lxc list
```
Output: 7 istanze presenti (`WinSrv19`, `deciding-pig`, `docker-node`, `holy-yak`, `more-alien`, `n8n-server`, `stirring-lemur`). Client LXD funzionante, nessun errore. Container `docker-node` e `n8n-server` sono RUNNING.

```
lxc storage list
```
Output: 4 pool — `local` (zfs), `nvme-tier` (ceph, 0 used), `remote` (ceph, "Distributed storage on Ceph", 9 used), `remote-fast` (ceph, 3 used). Il pool Ceph generico più plausibile come `storage_pool` per il collaudo è **`remote`**.

```
lxc network list
```
Output: rete gestita `default`, tipo **OVN** (non bridge semplice), IPv4 `10.126.229.1/24`, IPv6 `fd42:91da:fe0b:e6c1::1/64`, 9 istanze collegate. Assegna IP via DHCP. Da notare per Fase 1: il provider Terraform dovrà referenziare una rete OVN, non un bridge Linux tradizionale.

```
lxc image list ubuntu:24.04
```
Output: immagine ubuntu 24.04 LTS amd64 già in cache locale (container fingerprint `249184e85e13`, VM fingerprint `aa5e27c9f434`), upload date 2026-08-26. Nessun download necessario.

```
terraform version
```
Output: `Terraform v1.15.4` (aggiornamento disponibile a v1.16.0, non bloccante).

Verifica internet in uscita dall'host:
```
curl -sS -m 5 -o /dev/null -w 'HTTP %{http_code}\n' https://registry.terraform.io
```
Output: `HTTP 200`. OK.

Verifica versioni LXD/snap:
```
lxc version
lxd --version
snap list lxd microceph microcloud
```
Output: LXD `5.21.4 LTS` (client e server coincidenti), microceph `19.2.3`, microcloud `2.1.3`.

Repository sull'host:
```
ls -la ~/n8n-lxd-terraform
```
Non presente → clonato:
```
git clone https://github.com/danielesalpietro/n8n-lxd-terraform.git ~/n8n-lxd-terraform
cd ~/n8n-lxd-terraform && git checkout claude/repo-status-mydlk3
```
Clone e checkout riusciti senza errori.

## Anomalia: container `n8n-server` pre-esistente

Durante `lxc list` è emerso un container `n8n-server` RUNNING il cui nome coincide esattamente con `container_name = "n8n-server"` in `terraform.tfvars.example:17`, in contraddizione con la premessa "codice mai eseguito".

Approfondimento:
```
lxc info n8n-server
```
→ `Created: 2026/05/26 13:11 UTC`, `Last Used: 2026/08/28 10:43 UTC` (oggi — verosimilmente riavvio/uso recente coerente con l'uptime dell'host, non creazione).

```
lxc exec n8n-server -- pm2 list
```
→ processo `n8n` (PM2, fork mode), status `online`, uptime `8h`, mem `272.0mb`.

```
lxc info n8n-server | grep -A5 Snapshots
```
→ snapshot `post-installazione` del `2026/05/26 14:33 UTC`.

Cloud-init interno (`lxc config show n8n-server`) installa `postgresql`, `postgresql-contrib`, e scrive `/opt/n8n/ecosystem.config.js` — pattern coerente con lo stack di questo progetto.

**Conclusione:** container creato ~3 mesi prima di questa sessione (26/05/2026), non collegato a questa esecuzione del collaudo. Segnalato al proprietario prima di procedere, per decisione esplicita (vedi sezione seguente). Non è stato eseguito alcun comando di modifica, riavvio o distruzione su `n8n-server` in nessun momento di questa sessione — solo comandi di sola lettura (`lxc info`, `lxc config show`, `lxc exec ... pm2 list`).

## Decisione dell'owner (scambio in chat, 2026-08-28)

L'owner ha confermato: `n8n-server` è realmente in uso e funzionante, **non va toccato, modificato, riavviato né distrutto in nessuna fase del collaudo**. Le fasi di collaudo (a partire dalla Fase 1) useranno un container di test separato con `container_name` dedicato e inequivocabile (es. `n8n-collaudo-f1`), verificato con `lxc list` come non esistente prima della creazione.

L'owner ha aggiornato direttamente (da altra sessione) `collaudo/handoff_fase0.md`, `collaudo/handoff_fase1.md`, `handoff_test_and_dev.md`, `terraform.tfvars.example` con questa indicazione, e documentato l'anomalia sulla sub-issue #4: https://github.com/danielesalpietro/n8n-lxd-terraform/issues/4

Questa sessione ha eseguito `git pull --rebase origin claude/repo-status-mydlk3` per recepire le modifiche (fast-forward `04ef87a..41ecfd8`, nessun conflitto) e ha verificato con `git show` che il contenuto corrisponda esattamente a quanto descritto dall'owner in chat, prima di proseguire.

Ripresa della checklist dopo la sospensione: la nuova voce aggiunta da `handoff_fase0.md` ("`lxc list` ispezionato per container pre-esistenti...") risulta già soddisfatta dal lavoro di investigazione sopra riportato.

## Note su versioni non ancora risolvibili in questa fase

- Versione risolta del provider `terraform-lxd/lxd`: non ancora nota, si risolve con `terraform init` in Fase 2 (vedi `collaudo/handoff_fase2.md`).
- Versione Node.js: non applicabile in questa fase — Node viene installato dal cloud-init dentro il container di test, che non esiste ancora (verrà creato in Fase 1/2).
