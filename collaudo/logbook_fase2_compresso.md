# Logbook compresso — Fase 2

## Stato finale
- Esito: COMPLETATA
- Data/ora fine sessione (UTC): 2026-08-28 ~21:55
- Sub-issue GitHub: #6 — stato: chiusa (criterio di uscita soddisfatto: `terraform validate` e la CI di validazione statica passano senza errori)
- Commit di riferimento (hash brevi) prodotti in questa sessione: `f2ba46a` (fix required_version), più commit dei logbook di questa fase (vedi subito dopo questo file)

## Configurazione rilevante per le fasi successive
- container_name: `n8n-collaudo-f1` (invariato dalla Fase 1)
- storage_pool: `remote` (invariato dalla Fase 1)
- rete/bridge usato: `default`, OVN, `10.126.229.1/24` (invariato)
- versioni rilevate: LXD `5.21.4 LTS`, Terraform `1.15.4` sull'host (CI usa `1.9.8`, compatibile con `required_version = ">= 1.9.0"` ora dichiarato in `main.tf`), **provider `terraform-lxd/lxd` risolto in v2.7.1** (constraint `~> 2.0`), `tflint` non installato sull'host (verifica delegata alla CI, ora verde).
- IP del container di test: nessun container ancora creato (questa fase non esegue `terraform apply`).
- `terraform.tfvars`: presente sia sul clone Windows (Fase 1) sia ora sul clone host `/home/dsalpietro/n8n-lxd-terraform` (ricreato in questa fase, password rigenerate indipendentemente sui due clone — nessuna delle due riutilizzata altrove). **Le fasi successive che eseguono `terraform apply`/`plan` devono operare sul clone host** (`/home/dsalpietro/n8n-lxd-terraform`), perché il provider LXD richiede il socket locale — non sul clone Windows.

## Bug riscontrati e fix applicati
| Bug | Fix applicato | Commit |
|-----|----------------|--------|
| CI `terraform-ci.yml` rossa su ogni push (anche commit solo doc): step `tflint` falliva con `main.tf:2:1: terraform "required_version" attribute is required` (regola `terraform_required_version` del preset `recommended` in `.tflint.hcl`), trattato da tflint come errore bloccante (exit 2) | Aggiunto `required_version = ">= 1.9.0"` al blocco `terraform {}` in `main.tf` | `f2ba46a` |

## Problemi aperti / non risolti
- **Container `n8n-server`**: confermato ancora presente e non toccato (non ri-ispezionato in dettaglio in questa fase, nessun comando `lxc` eseguito: questa fase è solo Terraform statico).
- `/remote-control` non disponibile in questo ambiente: monitoraggio in tempo reale non attivo, come già segnalato in Fase 1.
- `tflint` non installato sull'host: se una fase futura vuole eseguirlo localmente invece di affidarsi alla CI, andrà installato manualmente (non bloccante, la CI copre la verifica).
- Due clone del repository esistono in parallelo (Windows, usato per Fase 1 e per git/GitHub in questa fase; host `/home/dsalpietro/n8n-lxd-terraform`, usato per i comandi Terraform in questa fase): tenerne conto nelle fasi successive per capire su quale clone operare.

## Esito checklist di fase
- [x] `terraform init` scarica correttamente il provider `terraform-lxd/lxd`
- [x] `terraform init`/`validate` non falliscono per provider mancanti
- [x] `terraform validate` passa senza errori
- [x] Schema del resource `lxd_instance` (blocchi `limits`, `device`, `config`) compatibile con la versione 2.x del provider effettivamente risolta (2.7.1) — `validate` conferma
- [x] `tflint` passa senza warning bloccanti (verificato via CI `terraform-ci.yml`, run `33205792111` = success sul commit `f2ba46a`; tflint non installato sull'host)

## Carry-over ancora valido dalle fasi precedenti
- Container `n8n-server` (RUNNING, creato 2026-05-26): NON toccare mai, in nessuna fase successiva.
- Pool storage Ceph disponibili: `remote` (scelto per il collaudo), `remote-fast`, `nvme-tier`; `local` è zfs, non Ceph.
- Rete `default`, tipo OVN, `10.126.229.1/24`, DHCP attivo.
- `container_name = "n8n-collaudo-f1"`, verificato assente con `lxc list` in Fase 1 — da riverificare con `lxc list` prima di ogni `terraform apply` nelle fasi successive.
- `terraform.tfvars` non versionato: sul clone host `/home/dsalpietro/n8n-lxd-terraform` contiene `container_name`, `storage_pool`, `cpu_limits`, `ram_limits`, `timezone` coerenti col collaudo e password di test generate casualmente in questa fase (non recuperabili da git).

## Riferimenti
- Handoff seguito: `collaudo/handoff_fase2.md`
- Logbook esteso (facoltativo, solo per approfondimento): `collaudo/logbook_fase2.md`
- Sub-issue: https://github.com/danielesalpietro/n8n-lxd-terraform/issues/6
