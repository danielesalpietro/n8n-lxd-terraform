# Logbook esteso — Fase 3: Plan

## Sessione
- Sessione operativa locale (Windows, accesso SSH reale via PuTTY `plink` verso host MicroCloud `micro01`, 192.168.1.100).
- `/remote-control` non disponibile in questo ambiente: invariato dalle fasi precedenti, monitoraggio in tempo reale non attivo.
- `CLAUDE.md` riletto, nessuna modifica alle direttive.
- Branch `claude/repo-status-mydlk3`: sincronizzato con `git fetch` + `pull --rebase` sia sul clone Windows sia sul clone host `/home/dsalpietro/n8n-lxd-terraform` (fast-forward su entrambi fino a `74b26d9`).
- `collaudo/logbook_fase2_compresso.md` letto per intero prima di procedere.
- Confermato (come indicato nel logbook Fase 2) che i comandi Terraform vanno eseguiti sul clone host: eseguiti tutti i comandi di questa fase su `/home/dsalpietro/n8n-lxd-terraform` via SSH.
- `terraform.tfvars` già presente su quel clone (creato in Fase 2): **riusato così com'è**, non ricreato.

## Verifiche preliminari
- `lxc list` sull'host: confermato `n8n-collaudo-f1` ancora assente, `n8n-server` ancora RUNNING e non toccato (solo ispezionato, nessun comando di modifica eseguito).

## Procedura eseguita

`terraform plan -out=tfplan` (su `/home/dsalpietro/n8n-lxd-terraform`):

```
Terraform will perform the following actions:

  # lxd_instance.n8n_node will be created
  + resource "lxd_instance" "n8n_node" {
      + config     = { "user.user-data" = (sensitive value) }
      + limits     = { "cpu" = "2", "memory" = "4GB" }
      + name       = "n8n-collaudo-f1"
      + profiles   = ["default"]
      + type       = "container"
      + device { name = "root", type = "disk", properties = { path = "/", pool = "remote" } }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

Nessun warning, nessun errore. Piano salvato in `tfplan` (artefatto binario locale sull'host, non versionato).

## Verifica del rendering cloud-init (senza esporre segreti in chat/log)

Il campo `config."user.user-data"` è marcato `(sensitive value)` nell'output leggibile del plan (perché deriva da variabili `sensitive = true`), quindi non ispezionabile direttamente da lì. Verificato invece così, senza mai stampare il contenuto completo (che include le password generate):

1. `terraform show -json tfplan` → estratto con `jq` il valore di `.planned_values.root_module.resources[] | select(.address=="lxd_instance.n8n_node") | .values.config."user.user-data"` in un file temporaneo locale sull'host (cancellato subito dopo).
2. Verifiche automatiche su quel file (solo conteggi/pattern-match, mai stampa del contenuto):
   - Dimensione: 2064 byte (coerente con `cloud-init.yaml.tpl`, non troncato/vuoto).
   - Placeholder non risolti (pattern `${nome_variabile}` letterale): **0 trovati** — nessun `${db_user}`, `${db_password}`, `${n8n_user}`, `${n8n_password}`, `${timezone}` residuo.
   - Marker strutturali non sensibili attesi dal template presenti: `GENERIC_TIMEZONE` (1 occorrenza), `CREATE DATABASE n8n` (1 occorrenza).
3. File temporanei (`tfplan.json`, estratto `user-data`) cancellati subito dopo la verifica; le password generate in Fase 2 non sono mai state stampate in questo logbook, in chat o nei commenti GitHub.

## Esito checklist

- Il piano mostra la creazione di 1 sola risorsa (`lxd_instance.n8n_node`), nessuna modifica/distruzione inattesa → confermato (`1 to add, 0 to change, 0 to destroy`).
- Il rendering del cloud-init non mostra placeholder non risolti → confermato (0 placeholder `${...}` residui nel rendering).
- Nessun warning/errore da `terraform plan` → confermato, `plan exit=0`, nessun testo di warning nell'output.

## Bug riscontrati e fix applicati

Nessuno. Il codice Terraform e il template cloud-init risultano corretti così come consegnati dopo il fix della Fase 2 (`required_version`).

## Esito

Nessuna risorsa reale creata in questa fase (solo `terraform plan`, nessun `apply`). Container `n8n-server` non toccato.

## Riferimenti
- Handoff seguito: `collaudo/handoff_fase3.md`
- Sub-issue: https://github.com/danielesalpietro/n8n-lxd-terraform/issues/7
