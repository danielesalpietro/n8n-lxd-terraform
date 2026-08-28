# Logbook compresso — Fase 0

## Stato finale
- Esito: COMPLETATA CON RISERVE
- Data/ora fine sessione (UTC): 2026-08-28 ~19:50
- Sub-issue GitHub: #4 — stato: chiusa (criterio di uscita soddisfatto: tutti i punti della checklist verificati; l'anomalia del container `n8n-server` è annotata come riserva ma non ne blocca la chiusura — tracciata per le fasi successive nella sezione "Problemi aperti" sotto)
- Commit di riferimento (hash brevi) prodotti in questa sessione: (vedi commit di chiusura Fase 0, subito successivo a questo file)

## Configurazione rilevante per le fasi successive
- container_name: **da NON usare `n8n-server`** — esiste già un container con questo nome sull'host, in uso reale, non toccare. Per il collaudo scegliere un nome dedicato e verificato assente con `lxc list` (es. `n8n-collaudo-f1`), a partire dalla Fase 1.
- storage_pool: pool Ceph disponibili — `remote` (ceph, "Distributed storage on Ceph", candidato più plausibile), `remote-fast` (ceph), `nvme-tier` (ceph, vuoto); esiste anche `local` (zfs, non Ceph). Nessuna scelta ancora vincolante fatta in questa fase: la conferma spetta alla Fase 1.
- rete/bridge usato: rete gestita `default`, tipo **OVN** (non bridge Linux tradizionale), IPv4 `10.126.229.1/24`, DHCP attivo. Il provider Terraform LXD dovrà referenziare questa rete OVN.
- versioni rilevate: LXD `5.21.4 LTS` (client=server), Terraform `1.15.4` (v1.16.0 disponibile, non bloccante), provider `terraform-lxd/lxd`: non ancora risolto (si risolve in Fase 2 con `terraform init`), Node: non applicabile in questa fase (installato dal cloud-init nel container di test, non ancora creato).
- IP del container di test: nessun container di test ancora creato in questa fase (Fase 0 è solo verifica ambiente).

## Bug riscontrati e fix applicati
| Bug | Fix applicato | Commit |
|-----|----------------|--------|
| `terraform.tfvars.example` usa `container_name = "n8n-server"`, che collide con un container reale già in uso sull'host | Aggiunto avviso nel file e aggiornati `collaudo/handoff_fase0.md`, `collaudo/handoff_fase1.md`, `handoff_test_and_dev.md` per imporre un nome di test dedicato | 41ecfd8 (applicato dall'owner/sessione di supervisione, recepito con `git pull --rebase` in questa sessione) |

## Problemi aperti / non risolti
- **Container `n8n-server` pre-esistente e in uso reale** (creato 2026-05-26, non collegato a questo collaudo): NON va mai toccato, modificato, riavviato o distrutto in nessuna fase successiva. Dettaglio investigativo completo nel logbook esteso (`collaudo/logbook_fase0.md`) e nel commento dell'owner sulla sub-issue #4 (https://github.com/danielesalpietro/n8n-lxd-terraform/issues/4). La Fase 1 deve scegliere un `container_name` dedicato (es. `n8n-collaudo-f1`) verificato assente con `lxc list` prima di procedere.
- Versione risolta del provider `terraform-lxd/lxd` non ancora nota: sarà annotata dalla Fase 2 (`terraform init` / `terraform providers`).
- Scelta definitiva dello `storage_pool` tra `remote` e `remote-fast` non ancora confermata: la Fase 1 deve decidere in base ai requisiti di performance/capacità (vedi tabella pool nel logbook esteso).

## Esito checklist di fase
- [x] SSH funzionante verso l'host MicroCloud
- [x] `lxc list` restituisce output senza errori (client LXD configurato)
- [x] `lxc storage list` — il pool che userai come `storage_pool` esiste davvero (pool Ceph presenti: `remote`, `remote-fast`, `nvme-tier`)
- [x] `lxc network list` — presenza di un bridge/rete che assegni IP via DHCP ai container (rete OVN `default`)
- [x] `lxc image list ubuntu:24.04` — l'host può scaricare/ha in cache l'immagine (già in cache)
- [x] `terraform version` eseguito e annotato (v1.15.4; richiesto provider `terraform-lxd/lxd ~> 2.0`, non ancora risolto)
- [x] Accesso internet in uscita dall'host verificato (HTTP 200 verso registry.terraform.io)
- [x] Repository clonato e branch `claude/repo-status-mydlk3` in checkout
- [x] `lxc list` ispezionato per container pre-esistenti che potrebbero collidere per nome (trovato `n8n-server`, RUNNING, creato 2026-05-26 — NON toccato, solo ispezionato in sola lettura)

## Carry-over ancora valido dalle fasi precedenti
Nessun carry-over aggiuntivo oltre quanto già riportato sopra (è la Fase 0, non esistono fasi precedenti).

## Riferimenti
- Handoff seguito: `collaudo/handoff_fase0.md`
- Logbook esteso (facoltativo, solo per approfondimento): `collaudo/logbook_fase0.md`
- Sub-issue: https://github.com/danielesalpietro/n8n-lxd-terraform/issues/4
