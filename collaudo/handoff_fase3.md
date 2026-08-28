# Handoff — Fase 3: Plan

> Istruzioni operative per la sessione dedicata a questa fase. Sessione con accesso SSH diretto all'host MicroCloud che ospita LXD.

## 0. Prima di iniziare (obbligatorio)

- Contesto progetto: repository `n8n-lxd-terraform` — Terraform + cloud-init per il deployment automatico di n8n su un container LXD/LXC in un host MicroCloud.
- Branch di lavoro condiviso:
  ```bash
  git fetch origin claude/repo-status-mydlk3
  git checkout claude/repo-status-mydlk3
  git pull --rebase origin claude/repo-status-mydlk3
  ```
- **Leggi OBBLIGATORIAMENTE, per intero, `collaudo/logbook_fase2_compresso.md`** prima di fare qualunque cosa.
- Sub-issue GitHub di questa fase: **#7**.
- Crea il logbook esteso: `collaudo/logbook_fase3.md`.

## 1. Obiettivo della fase

Confermare che il piano Terraform rifletta esattamente l'intento (creazione container + rendering cloud-init) senza modifiche/distruzioni inattese.

## 2. Procedura

```bash
terraform plan -out=tfplan
```

Ispeziona l'output del piano con attenzione al blocco `config."user.user-data"`: deve contenere lo YAML del cloud-init con le variabili già interpolate (nessun placeholder tipo `${db_user}` letterale).

## 3. Checklist (= checklist della sub-issue #7)

- [ ] Il piano mostra la creazione di 1 sola risorsa (`lxd_instance.n8n_node`), nessuna modifica/distruzione inattesa
- [ ] Il rendering del cloud-init non mostra placeholder non risolti
- [ ] Nessun warning/errore da `terraform plan`

## 4. Criterio di uscita

Piano coerente con le aspettative, nessun errore.

## 5. Chiusura sessione (obbligatoria)

1. Verifica che la checklist rifletta lo stato reale.
2. Se il plan ha rivelato un problema nel codice, correggilo, ricommitta e ripeti il plan prima di chiudere.
3. Aggiorna la sub-issue **#7**: spunta i checkbox, commenta l'esito, chiudi se il criterio di uscita è soddisfatto.
4. Genera `collaudo/logbook_fase3_compresso.md` seguendo il template.
5. Committa e pusha `collaudo/logbook_fase3.md` e `collaudo/logbook_fase3_compresso.md` (non `tfplan`, è un artefatto binario locale, non va versionato).
6. Indica che la sessione successiva deve aprire `collaudo/handoff_fase4.md`.

## Note per il supervisore

Questa sessione NON chiude autonomamente la issue madre #3.
