# Handoff — Fase 5: Checklist funzionale dei servizi

> Istruzioni operative per la sessione dedicata a questa fase. Sessione con accesso SSH diretto all'host MicroCloud che ospita LXD.

## 0. Prima di iniziare (obbligatorio)

- Contesto progetto: repository `n8n-lxd-terraform` — Terraform + cloud-init per il deployment automatico di n8n su un container LXD/LXC in un host MicroCloud.
- Branch di lavoro condiviso:
  ```bash
  git fetch origin claude/repo-status-mydlk3
  git checkout claude/repo-status-mydlk3
  git pull --rebase origin claude/repo-status-mydlk3
  ```
- **Leggi OBBLIGATORIAMENTE, per intero, `collaudo/logbook_fase4_compresso.md`** prima di fare qualunque cosa. Da lì recupera se il container di test è ancora acceso e il suo nome/IP.
- **Attenzione ai clone multipli:** opera sul clone che sta fisicamente sull'host MicroCloud (serve il socket LXD locale per `terraform output`/`lxc exec`) — verifica il percorso esatto nel logbook compresso.
- Sub-issue GitHub di questa fase: **#9**.
- Crea il logbook esteso: `collaudo/logbook_fase5.md`.

## 1. Obiettivo della fase

Verificare che i servizi (PostgreSQL, Node.js, n8n via PM2) siano davvero funzionanti — non solo "in esecuzione". Questa checklist è pensata per essere rieseguita ad ogni iterazione di fix, non solo una volta a fine fase.

## 2. Procedura

Comandi via `lxc exec <container_name> -- <comando>` salvo diversa indicazione.

```bash
# Sistema di base
lxc exec <c> -- cloud-init status
lxc exec <c> -- node -v
lxc exec <c> -- npm -v

# PostgreSQL
lxc exec <c> -- systemctl is-active postgresql
lxc exec <c> -- sudo -u postgres psql -lqt
lxc exec <c> -- sudo -u postgres psql -c "\du"
lxc exec <c> -- bash -c 'PGPASSWORD=<db_password> psql -h localhost -U <db_user> -d n8n -c "\conninfo"'

# n8n / PM2
lxc exec <c> -- pm2 list
lxc exec <c> -- pm2 logs n8n --lines 50 --nostream
lxc exec <c> -- curl -I http://localhost:5678
terraform output instance_ip
# login da browser/curl con n8n_user/n8n_password, creazione workflow di prova, salvataggio
lxc exec <c> -- pm2 restart n8n
# riverifica che il workflow di prova sia ancora presente dopo il riavvio

# Fuso orario
lxc exec <c> -- date
lxc exec <c> -- timedatectl
# nodo Schedule/Cron di prova: verificare attivazione all'ora locale attesa
```

## 3. Checklist (= checklist della sub-issue #9)

### Sistema di base
- [ ] `cloud-init status` → `done`
- [ ] `node -v` → versione Node 20.x
- [ ] `npm -v` risponde

### PostgreSQL
- [ ] `systemctl is-active postgresql` → `active`
- [ ] Il database `n8n` esiste
- [ ] L'utente `db_user` esiste con i permessi corretti
- [ ] Connessione applicativa con le credenziali reali riuscita

### n8n / PM2
- [ ] `pm2 list` → processo `n8n` `online`, non in restart loop
- [ ] `pm2 logs n8n` → nessun errore di connessione al DB
- [ ] `curl -I http://localhost:5678` → risposta HTTP (401 atteso con basic auth attiva)
- [ ] Login con credenziali `n8n_user`/`n8n_password` riuscito
- [ ] Raggiungibilità via `terraform output instance_ip`
- [ ] Workflow di prova creato e salvato → scrittura effettiva su Postgres
- [ ] `pm2 restart n8n` → workflow di prova ancora presente dopo il riavvio

### Fuso orario
- [ ] `date`/`timedatectl` coerente con `timezone` impostato
- [ ] Nodo Schedule/Cron di prova attivato all'orario locale atteso

## 4. Criterio di uscita

Tutte le voci verificate su almeno un ciclo completo apply → checklist.

## 5. Chiusura sessione (obbligatoria)

1. Verifica che la checklist rifletta lo stato reale.
2. Se hai corretto codice, committa e pusha, e ripeti la checklist sul nuovo apply prima di chiudere.
3. Aggiorna la sub-issue **#9**: spunta i checkbox, commenta l'esito, chiudi se il criterio di uscita è soddisfatto.
4. Genera `collaudo/logbook_fase5_compresso.md` seguendo il template.
5. Committa e pusha `collaudo/logbook_fase5.md` e `collaudo/logbook_fase5_compresso.md`.
6. Indica che la sessione successiva deve aprire `collaudo/handoff_fase6.md`. Lascia il container acceso se la Fase 6 (resilienza) può riutilizzarlo — indicalo nel logbook compresso.

## Note per il supervisore

Questa sessione NON chiude autonomamente la issue madre #3. Nota: un sottoinsieme di questa checklist (Postgres attivo, PM2/n8n online, risposta HTTP) è coperto anche automaticamente dalla CI `.github/workflows/e2e-regression.yml` — il supervisore può usarla come controllo incrociato indipendente.
