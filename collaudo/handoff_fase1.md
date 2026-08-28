# Handoff — Fase 1: Preparazione configurazione

> Istruzioni operative per la sessione dedicata a questa fase. Sessione con accesso SSH diretto all'host MicroCloud che ospita LXD.

## 0. Prima di iniziare (obbligatorio)

- Contesto progetto: repository `n8n-lxd-terraform` — Terraform + cloud-init per il deployment automatico di n8n su un container LXD/LXC in un host MicroCloud.
- Branch di lavoro condiviso da tutte le fasi:
  ```bash
  git fetch origin claude/repo-status-mydlk3
  git checkout claude/repo-status-mydlk3
  git pull --rebase origin claude/repo-status-mydlk3
  ```
- **Leggi OBBLIGATORIAMENTE, per intero, `collaudo/logbook_fase0_compresso.md`** prima di fare qualunque cosa. È autosufficiente: non serve aprire il logbook esteso della Fase 0 né altro materiale storico. Da lì recupera in particolare: nome esatto del pool di storage, tipo di rete, versioni di LXD/Terraform verificate.
- Sub-issue GitHub di questa fase: **#5** (figlia di #3 "Handoff Test & Dev"). Aggiornane i checkbox man mano che completi le verifiche.
- Crea il logbook esteso di questa fase: `collaudo/logbook_fase1.md`.

## 1. Obiettivo della fase

Preparare `terraform.tfvars` con valori reali coerenti con l'ambiente verificato in Fase 0, senza rischiare leak di credenziali.

## 2. Procedura

```bash
cd n8n-lxd-terraform
cp terraform.tfvars.example terraform.tfvars
# compila i valori usando quanto riportato nel logbook compresso della Fase 0
git status   # deve risultare pulito: terraform.tfvars NON deve comparire come tracciato
```

## 3. Checklist (= checklist della sub-issue #5)

- [ ] `terraform.tfvars` compilato con valori coerenti (`storage_pool`, `container_name`, limiti CPU/RAM) con quanto verificato in Fase 0
- [ ] Password di test non riutilizzate altrove (dato noto: finiranno in chiaro nel cloud-init e nel tfstate locale — non bloccante ma da tenere a mente)
- [ ] Confermato che `terraform.tfvars` NON viene tracciato da git (`.gitignore` funzionante)

## 4. Criterio di uscita

`terraform.tfvars` compilato e correttamente ignorato da git.

## 5. Chiusura sessione (obbligatoria)

1. Verifica che la checklist rifletta lo stato reale.
2. Non committare mai `terraform.tfvars` (contiene credenziali). Se hai modificato altro codice, committa e pusha su `claude/repo-status-mydlk3`.
3. Aggiorna la sub-issue **#5** su GitHub: spunta i checkbox, commenta l'esito finale, chiudi se il criterio di uscita è soddisfatto.
4. Genera `collaudo/logbook_fase1_compresso.md` seguendo `collaudo/logbook_template_compresso.md`. Riporta nella sezione "Carry-over" i valori ereditati dalla Fase 0 ancora rilevanti (pool, rete, versioni) così la Fase 2 non debba aprire il logbook della Fase 0.
5. Committa e pusha `collaudo/logbook_fase1.md` e `collaudo/logbook_fase1_compresso.md`.
6. Indica che la sessione successiva deve aprire `collaudo/handoff_fase2.md`.

## Note per il supervisore

Questa sessione NON chiude autonomamente la issue madre #3.
