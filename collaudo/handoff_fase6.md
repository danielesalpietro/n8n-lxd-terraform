# Handoff — Fase 6: Test di resilienza

> Istruzioni operative per la sessione dedicata a questa fase. Sessione con accesso SSH diretto all'host MicroCloud che ospita LXD.

## 0. Prima di iniziare (obbligatorio)

- Contesto progetto: repository `n8n-lxd-terraform` — Terraform + cloud-init per il deployment automatico di n8n su un container LXD/LXC in un host MicroCloud.
- Branch di lavoro condiviso:
  ```bash
  git fetch origin claude/repo-status-mydlk3
  git checkout claude/repo-status-mydlk3
  git pull --rebase origin claude/repo-status-mydlk3
  ```
- **Leggi OBBLIGATORIAMENTE, per intero, `collaudo/logbook_fase5_compresso.md`** prima di fare qualunque cosa.
- Sub-issue GitHub di questa fase: **#10**.
- Crea il logbook esteso: `collaudo/logbook_fase6.md`.
- Il riavvio dell'host MicroCloud è un'**azione impattante**: prima di eseguirlo, verifica con chi ti ha affidato la sessione che sia autorizzato in questo momento (potrebbero esserci altri carichi sull'host).

## 1. Obiettivo della fase

Verificare la persistenza reale del servizio dopo riavvii — non solo che "funzioni finché il container non viene riavviato". Presuppone che la Fase 5 sia passata in modo pulito.

## 2. Procedura

```bash
lxc restart <container_name>
# attendere il boot, poi ripetere la sezione PM2/n8n della checklist Fase 5
lxc exec <container_name> -- pm2 list
lxc exec <container_name> -- curl -I http://localhost:5678

# Solo se autorizzato esplicitamente:
# riavvio dell'host MicroCloud, poi verificare che il container riparta
# automaticamente e n8n torni disponibile senza intervento manuale
```

## 3. Checklist (= checklist della sub-issue #10)

- [ ] `lxc restart <container_name>` → PM2 riparte automaticamente (verifica reale di `pm2 startup systemd` + `pm2 save`)
- [ ] Riavvio dell'host MicroCloud (se autorizzato) → il container riparte automaticamente e n8n torna disponibile senza intervento manuale
- [ ] I dati creati in Fase 5 (workflow di prova) sopravvivono a entrambi i riavvii

## 4. Criterio di uscita

n8n si autoripristina dopo restart del container senza intervento manuale.

## 5. Chiusura sessione (obbligatoria)

1. Verifica che la checklist rifletta lo stato reale (se il riavvio host non è stato autorizzato/eseguito, marca quel punto come "non verificato" e spiegalo, non come completato).
2. Se hai corretto codice (es. lo script di `pm2 startup`), committa e pusha, e ripeti il test di restart prima di chiudere.
3. Aggiorna la sub-issue **#10**: spunta i checkbox, commenta l'esito, chiudi se il criterio di uscita è soddisfatto.
4. Genera `collaudo/logbook_fase6_compresso.md` seguendo il template.
5. Committa e pusha `collaudo/logbook_fase6.md` e `collaudo/logbook_fase6_compresso.md`.
6. Indica che la sessione successiva deve aprire `collaudo/handoff_fase7.md`.

## Note per il supervisore

Questa sessione NON chiude autonomamente la issue madre #3. Se il riavvio dell'host non è stato autorizzato in questa sessione, il supervisore deve pianificare esplicitamente quando farlo eseguire, perché è l'unico punto della checklist che richiede un'azione impattante concordata.
