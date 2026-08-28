# Handoff — Fase 4: Apply e monitoraggio provisioning

> Istruzioni operative per la sessione dedicata a questa fase. Sessione con accesso SSH diretto all'host MicroCloud che ospita LXD.

## 0. Prima di iniziare (obbligatorio)

- Contesto progetto: repository `n8n-lxd-terraform` — Terraform + cloud-init per il deployment automatico di n8n su un container LXD/LXC in un host MicroCloud.
- Branch di lavoro condiviso:
  ```bash
  git fetch origin claude/repo-status-mydlk3
  git checkout claude/repo-status-mydlk3
  git pull --rebase origin claude/repo-status-mydlk3
  ```
- **Leggi OBBLIGATORIAMENTE, per intero, `collaudo/logbook_fase3_compresso.md`** prima di fare qualunque cosa.
- **Attenzione ai clone multipli:** i comandi Terraform/`lxc` devono girare sul clone che sta fisicamente sull'host MicroCloud (il provider LXD richiede il socket locale) — verifica nel logbook compresso il percorso esatto e usa il `terraform.tfvars` già presente lì.
- Sub-issue GitHub di questa fase: **#8**.
- Crea il logbook esteso: `collaudo/logbook_fase4.md`.
- **Questa è la prima fase che crea davvero infrastruttura.** Procedi con cautela: se qualcosa va storto a metà provisioning, non lasciare il container "a metà" — annota lo stato esatto nel logbook esteso prima di intervenire manualmente, e preferisci correggere il codice sorgente (cloud-init/Terraform) piuttosto che patchare a mano dentro il container (un fix manuale non sopravvive a un nuovo `apply` e non aiuta la fase successiva).

## 1. Obiettivo della fase

Applicare l'infrastruttura e verificare che il cloud-init completi senza errori negli step critici del `runcmd`.

## 2. Procedura

```bash
terraform apply tfplan   # o terraform apply se il piano della Fase 3 non è più valido
lxc list
lxc exec <container_name> -- cloud-init status --wait
lxc exec <container_name> -- cat /var/log/cloud-init-output.log
```

Controlla in particolare, dentro il log:
- download/import chiave GPG NodeSource (`curl` verso `deb.nodesource.com`)
- `apt-get install -y nodejs` senza conflitti
- i comandi `psql` di creazione DB/utente/permessi (attenzione all'ordine: creazione utente prima dei grant)
- `npm install -g n8n pm2` (può richiedere diversi minuti — non interpretare la lentezza come blocco)
- l'ultimo comando (`pm2 startup systemd ... | tail -1 | bash`): verifica che l'output di `pm2 startup` sia stato davvero un comando eseguibile eseguito con successo dalla pipe, non solo testo informativo stampato a schermo

## 3. Checklist (= checklist della sub-issue #8)

- [ ] Container in stato `RUNNING`
- [ ] `cloud-init status --wait` termina con `status: done` (non `error`)
- [ ] Download/import chiave GPG NodeSource senza errori
- [ ] `apt-get install -y nodejs` completa senza conflitti
- [ ] I comandi `psql` di creazione DB/utente/permessi non falliscono
- [ ] `npm install -g n8n pm2` completa
- [ ] `pm2 startup systemd` produce ed esegue un comando valido

## 4. Criterio di uscita

cloud-init `done`, nessun errore critico in log. In caso di errore, annota lo step esatto nel logbook esteso prima di correggere.

## 5. Chiusura sessione (obbligatoria)

1. Verifica che la checklist rifletta lo stato reale.
2. Se hai corretto `cloud-init.yaml.tpl`/`main.tf`/`variables.tf`, committa e pusha. Se un fix richiede di ripetere l'apply, ripeti l'intero ciclo (destroy del container precedente se già esistente, poi apply) prima di chiudere la fase.
3. Aggiorna la sub-issue **#8**: spunta i checkbox, commenta l'esito, chiudi se il criterio di uscita è soddisfatto.
4. Genera `collaudo/logbook_fase4_compresso.md` seguendo il template. Indica chiaramente se il container va lasciato acceso per la Fase 5 (probabile, dato che la Fase 5 verifica i servizi sullo stesso container) oppure se va distrutto.
5. Committa e pusha `collaudo/logbook_fase4.md` e `collaudo/logbook_fase4_compresso.md`.
6. Indica che la sessione successiva deve aprire `collaudo/handoff_fase5.md`.

## Note per il supervisore

Questa sessione NON chiude autonomamente la issue madre #3. Se questa fase rivela un bug bloccante nel cloud-init, il supervisore va informato tramite commento sulla sub-issue #8 anche se la sessione stessa lo corregge, perché impatta la CI `e2e-regression.yml`.
