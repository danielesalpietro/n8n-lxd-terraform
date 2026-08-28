# Handoff — Fase 2: Validazione statica del codice Terraform

> Istruzioni operative per la sessione dedicata a questa fase. Sessione con accesso SSH diretto all'host MicroCloud che ospita LXD.

## 0. Prima di iniziare (obbligatorio)

- Contesto progetto: repository `n8n-lxd-terraform` — Terraform + cloud-init per il deployment automatico di n8n su un container LXD/LXC in un host MicroCloud.
- Branch di lavoro condiviso:
  ```bash
  git fetch origin claude/repo-status-mydlk3
  git checkout claude/repo-status-mydlk3
  git pull --rebase origin claude/repo-status-mydlk3
  ```
- **Leggi OBBLIGATORIAMENTE, per intero, `collaudo/logbook_fase1_compresso.md`** prima di fare qualunque cosa. Non serve aprire logbook di fasi precedenti alla 1.
- Sub-issue GitHub di questa fase: **#6**.
- Crea il logbook esteso: `collaudo/logbook_fase2.md`.
- Nota: due bug HCL noti sono già stati corretti in questo branch prima dell'avvio del collaudo (variabili sensibili con sintassi a virgola non valida; `data "template_file"` deprecato sostituito con `templatefile()`). Questa fase deve comunque rivalidare tutto da zero, non dare per scontato che non ce ne siano altri.

## 1. Obiettivo della fase

Intercettare errori di sintassi/schema prima di creare risorse reali. Questa fase è coperta anche automaticamente dalla CI (`.github/workflows/terraform-ci.yml`) ad ogni push/PR — puoi usarla come riscontro, ma la verifica va comunque ripetuta localmente sull'host.

## 2. Procedura

```bash
terraform init
terraform fmt -check -diff
terraform validate
terraform providers   # verifica versione risolta del provider terraform-lxd/lxd
tflint --init && tflint -f compact   # se tflint è installato sull'host; altrimenti verifica solo via CI
```

## 3. Checklist (= checklist della sub-issue #6)

- [ ] `terraform init` scarica correttamente il provider `terraform-lxd/lxd`
- [ ] `terraform init`/`validate` non falliscono per provider mancanti
- [ ] `terraform validate` passa senza errori
- [ ] Schema del resource `lxd_instance` (blocchi `limits`, `device`, `config`) compatibile con la versione 2.x del provider effettivamente risolta
- [ ] `tflint` passa senza warning bloccanti (o la CI `terraform-ci.yml` risulta verde sull'ultimo commit)

## 4. Criterio di uscita

`terraform validate` e la CI di validazione statica passano senza errori. Ogni correzione va committata separatamente con messaggio chiaro.

## 5. Chiusura sessione (obbligatoria)

1. Verifica che la checklist rifletta lo stato reale.
2. Se hai applicato fix, committa (messaggi tipo `fix(terraform): ...`) e pusha su `claude/repo-status-mydlk3`.
3. Aggiorna la sub-issue **#6**: spunta i checkbox, commenta l'esito, chiudi se il criterio di uscita è soddisfatto.
4. Genera `collaudo/logbook_fase2_compresso.md` seguendo il template. Se hai trovato e corretto altri bug HCL/provider oltre a quelli già noti, documentali nella tabella "Bug riscontrati e fix applicati" con il commit di riferimento.
5. Committa e pusha `collaudo/logbook_fase2.md` e `collaudo/logbook_fase2_compresso.md`.
6. Indica che la sessione successiva deve aprire `collaudo/handoff_fase3.md`.

## Note per il supervisore

Questa sessione NON chiude autonomamente la issue madre #3.
