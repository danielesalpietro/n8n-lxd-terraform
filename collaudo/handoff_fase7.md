# Handoff — Fase 7: Cleanup / rollback

> Istruzioni operative per la sessione dedicata a questa fase. Sessione con accesso SSH diretto all'host MicroCloud che ospita LXD. **È l'ultima fase del collaudo Fase 1.**

## 0. Prima di iniziare (obbligatorio)

- Contesto progetto: repository `n8n-lxd-terraform` — Terraform + cloud-init per il deployment automatico di n8n su un container LXD/LXC in un host MicroCloud.
- Branch di lavoro condiviso:
  ```bash
  git fetch origin claude/repo-status-mydlk3
  git checkout claude/repo-status-mydlk3
  git pull --rebase origin claude/repo-status-mydlk3
  ```
- **Leggi OBBLIGATORIAMENTE, per intero, `collaudo/logbook_fase6_compresso.md`** prima di fare qualunque cosa.
- **Attenzione ai clone multipli:** opera sul clone che sta fisicamente sull'host MicroCloud (serve il socket LXD locale per `terraform destroy`) — verifica il percorso esatto nel logbook compresso.
- Sub-issue GitHub di questa fase: **#11**.
- Crea il logbook esteso: `collaudo/logbook_fase7.md`.

## 1. Obiettivo della fase

Verificare che il rollback completo funzioni in modo pulito, senza risorse orfane, e chiudere il ciclo di collaudo.

## 2. Procedura

```bash
terraform destroy
lxc list
lxc storage volume list <pool>
terraform show
```

Se durante le fasi precedenti sono state applicate correzioni significative al codice, ripeti almeno una volta l'intero ciclo Fase 3 (`plan`) → Fase 7 (`destroy`) prima di chiudere, per confermare che l'ultima versione del codice funzioni end-to-end senza intervento manuale.

## 3. Checklist (= checklist della sub-issue #11)

- [ ] Container rimosso correttamente (`lxc list` non lo mostra più)
- [ ] Nessuna risorsa orfana residua (volumi storage)
- [ ] `terraform.tfstate` locale coerente (nessuna risorsa fantasma in `terraform show`)
- [ ] Il ciclo Fase 3 → Fase 7 è stato ripetuto almeno una volta dopo ogni correzione significativa al codice

## 4. Criterio di uscita

`terraform destroy` pulito, nessuna risorsa residua, stato coerente.

## 5. Chiusura sessione (obbligatoria)

1. Verifica che la checklist rifletta lo stato reale.
2. Se hai corretto codice, committa e pusha.
3. Aggiorna la sub-issue **#11**: spunta i checkbox, commenta l'esito, chiudi se il criterio di uscita è soddisfatto.
4. Genera `collaudo/logbook_fase7_compresso.md` seguendo il template. Nella sezione "Problemi aperti / non risolti", riporta l'elenco consolidato di TUTTO ciò che resta aperto sull'intero collaudo (non solo la Fase 7) — è l'input diretto per il supervisore.
5. Committa e pusha `collaudo/logbook_fase7.md` e `collaudo/logbook_fase7_compresso.md`.
6. **Non aprire una Fase 8**: il collaudo di Fase 1 termina qui. Commenta esplicitamente sulla issue madre **#3** che tutte le sub-issue sono state completate (o elenca quelle rimaste aperte e perché), così il supervisore può verificare la Definition of Done descritta in `handoff_test_and_dev.md` e chiudere la issue madre.

## Note per il supervisore

Questa è l'ultima fase: la chiusura della issue madre #3 e la valutazione complessiva della Definition of Done restano comunque responsabilità della sessione di supervisione, non di questa sessione.
