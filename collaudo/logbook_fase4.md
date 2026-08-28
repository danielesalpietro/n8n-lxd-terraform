# Logbook esteso — Fase 4: Apply e monitoraggio provisioning

## Sessione
- Sessione operativa locale (Windows, accesso SSH reale via PuTTY `plink` verso host MicroCloud `micro01`, 192.168.1.100).
- `/remote-control` non disponibile in questo ambiente: invariato, monitoraggio in tempo reale non attivo.
- `CLAUDE.md` riletto, nessuna modifica alle direttive.
- Branch `claude/repo-status-mydlk3`: sincronizzato su entrambi i clone (Windows e host `/home/dsalpietro/n8n-lxd-terraform`) fino a `5cb2761` prima di iniziare.
- `collaudo/logbook_fase3_compresso.md` letto per intero prima di procedere.
- Prima fase che crea infrastruttura reale: proceduto con cautela, ogni `destroy`/`apply` confermato esplicitamente dall'utente prima dell'esecuzione (azioni distruttive/irreversibili bloccate di default dal classifier dei permessi, confermate manualmente in chat).

## Verifica del piano prima dell'apply
- `tfplan` salvato dalla Fase 3 risultava recente (~6 minuti) ma rigenerato comunque da zero (`rm tfplan && terraform plan -out=tfplan`) per non fidarsi ciecamente di un piano non prodotto in questa sessione, come indicato nelle istruzioni. Risultato identico: `1 to add, 0 to change, 0 to destroy`.

## Ciclo 1: primo apply — FALLITO (cloud-init non applicato)

`terraform apply tfplan` → container `n8n-collaudo-f1` creato correttamente (RUNNING, IP `10.126.229.9`), `n8n-server` non toccato.

`lxc exec n8n-collaudo-f1 -- cloud-init status --wait` → `status: done` ma **exit code 2** (degraded). Dettaglio (`cloud-init status --long`):
```
extended_status: degraded done
recoverable_errors:
WARNING:
	- Unhandled non-multipart (text/x-not-multipart) userdata: 'b'# cloud-init.yaml.tpl'...'
```

Verificato (senza modificare nulla a mano nel container, come da istruzione) che il provisioning non era affatto avvenuto: `/opt/n8n/` inesistente, `node`/`n8n`/`pm2`/`psql` assenti.

**Causa**: `cloud-init.yaml.tpl` iniziava con una riga di commento (`# cloud-init.yaml.tpl`) PRIMA di `#cloud-config`. cloud-init richiede che `#cloud-config` sia la primissima riga del file per riconoscere il formato; con un commento davanti, l'intero user-data viene trattato come dato non gestito e **tutte le direttive (packages, write_files, runcmd) vengono ignorate silenziosamente**, senza errore bloccante a livello di `terraform apply` (che infatti termina con successo: LXD accetta qualunque stringa come `user.user-data`, la validazione del formato è competenza di cloud-init dentro il container).

**Fix** (commit `ea1b9a8`): rimossa la riga di commento iniziale da `cloud-init.yaml.tpl`, in modo che `#cloud-config` sia la prima riga del file.

**Rimedio applicato**: come da istruzione dell'handoff ("preferisci correggere il codice sorgente piuttosto che patchare a mano dentro il container" + "ripeti l'intero ciclo: destroy del container precedente, poi apply"), NON sono state applicate patch manuali dentro `n8n-collaudo-f1`. Richiesta ed ottenuta conferma esplicita dell'utente prima di eseguire `terraform destroy -auto-approve` (azione distruttiva, bloccata di default dal classifier dei permessi). Verificato con `terraform state list` che lo stato Terraform contenesse solo `lxd_instance.n8n_node` prima di procedere, per escludere che `destroy` potesse in alcun modo interessare `n8n-server` (mai importato in questo state). Destroy eseguito: `1 to destroy` (solo `n8n-collaudo-f1`), completato in 8s.

## Ciclo 2: secondo apply — FALLITO (bug nell'ultimo comando runcmd)

Sincronizzato il fix sul clone host, rigenerato `tfplan` (`1 to add, 0 to change, 0 to destroy`), rieseguito `terraform apply tfplan` → container ricreato (stessa IP `10.126.229.9`).

`cloud-init status --wait` questa volta ha impiegato ~11-12 minuti (atteso: `npm install -g n8n pm2` installa ~2000 pacchetti) ed è terminato con **status: error, exit code 1**:
```
errors:
	- ('scripts_user', RuntimeError('Runparts: 1 failures (runcmd) in 1 attempted commands'))
```

Analizzato `/var/log/cloud-init-output.log`: tutti gli step precedenti (GPG NodeSource, `apt-get install nodejs`, creazione DB/utente/grant Postgres nell'ordine corretto, `npm install -g n8n pm2`, `pm2 start`, `pm2 save`) completati con successo. L'ultimo comando del `runcmd`:

```
bash -c "env PATH=$PATH:/usr/bin pm2 startup systemd -u root --hp /root | tail -1 | bash"
```

ha prodotto nel log: `Created symlink /etc/systemd/system/multi-user.target.wants/pm2-root.service → ...` (conferma che pm2, eseguito come root, configura ed abilita **da solo** il systemd unit — non serve alcun comando successivo da copiare/incollare), seguito da `bash: line 1: $: command not found`. Verificato con `systemctl is-enabled pm2-root` → `enabled`, confermando che l'unit era già stata creata correttamente dal comando `pm2 startup` stesso.

**Causa**: assunzione errata nel template che l'ultima riga stampata da `pm2 startup systemd -u root --hp /root` fosse sempre un comando eseguibile da incollare (comportamento di versioni più vecchie di pm2 quando eseguito da utente non-root). Eseguito già come root, pm2 applica la configurazione automaticamente e l'ultima riga stampata è solo un suggerimento informativo in stile prompt (`$ pm2 unstartup systemd`, il comando per *rimuovere* lo startup, non per crearlo). La pipe `| tail -1 | bash` eseguiva quindi letteralmente quel testo, che inizia con `$` — bash lo interpreta come inizio di un'espansione di parametro non valida e fallisce con `$: command not found`. Questo comando fallito (`bash -c "..."`) fa fallire l'intero step `runcmd` di cloud-init (`Runparts: 1 failures`), anche se il risultato pratico (servizio abilitato) era già stato raggiunto.

**Fix** (commit `e8b49f9`): rimossa la pipe fragile; il comando ora è semplicemente `env PATH=$PATH:/usr/bin pm2 startup systemd -u root --hp /root`, senza eseguire il suo output stampato come shell.

**Rimedio applicato**: stessa procedura del ciclo precedente — nessuna patch manuale nel container, conferma esplicita dell'utente ottenuta prima di un secondo `terraform destroy -auto-approve` (`1 to destroy`, solo `n8n-collaudo-f1`, completato in 10s), poi `terraform plan` + `terraform apply` con il fix.

## Ciclo 3: terzo apply — SUCCESSO

Container ricreato (stessa IP `10.126.229.9`). `cloud-init status --wait` → **`status: done`, exit code 0**. `cloud-init status --long`: `errors: []`, `recoverable_errors: {}`.

Verifiche puntuali sul log e sullo stato del container (checklist della sub-issue #8):
- **Container RUNNING**: confermato con `lxc list`.
- **`cloud-init status --wait` → `status: done`**: confermato, exit 0.
- **Download/import chiave GPG NodeSource**: repository NodeSource aggiunto e pacchetto scaricato senza errori (`nodejs_20.20.2-1nodesource1_amd64.deb`, 32.2 MB).
- **`apt-get install -y nodejs` senza conflitti**: `Setting up nodejs (20.20.2-1nodesource1)` completato; `node -v` → `v20.20.2`, `npm -v` → `10.8.2`.
- **Comandi `psql` in ordine corretto**: log conferma sequenza `CREATE DATABASE` → `CREATE ROLE` → `GRANT` → `ALTER DATABASE` (creazione utente prima dei grant, come richiesto). Verificato a runtime: ruolo `n8n_user` esistente (`\du`), database `n8n` con owner `n8n_user` (`\l`).
- **`npm install -g n8n pm2` completa**: log conferma `added 1996 packages in 10m`; `which n8n pm2` → entrambi presenti in `/usr/bin`.
- **`pm2 startup systemd` produce ed esegue un comando valido**: `systemctl is-enabled pm2-root` → `enabled`; nessun errore residuo nel log (nessuna occorrenza di "command not found").

Verifica applicativa aggiuntiva (oltre alla checklist minima): `pm2 list` mostra il processo `n8n` `online`; `curl -s -o /dev/null -w "%{http_code}" http://localhost:5678/` dal container → `HTTP 200`.

## Container `n8n-server`

Verificato con `lxc list` prima e dopo ciascuno dei tre cicli (create iniziale, 2 destroy/recreate): sempre RUNNING, stesso IP (`10.126.229.7`), stesso numero di snapshot (1), MAI incluso in nessun comando Terraform (mai presente in `terraform state list`) né in alcun comando `lxc` diverso da `lxc list` (sola lettura).

## Bug riscontrati e fix applicati (riepilogo)

| Bug | Fix applicato | Commit |
|-----|----------------|--------|
| Commento prima del magic header `#cloud-config` in `cloud-init.yaml.tpl` → cloud-init non riconosce il formato, ignora silenziosamente packages/write_files/runcmd (status: degraded done, exit 2) | Rimossa la riga di commento iniziale | `ea1b9a8` |
| Ultimo comando `runcmd` eseguiva `pm2 startup systemd ... \| tail -1 \| bash`, assumendo che l'ultima riga stampata fosse un comando da eseguire; da root pm2 si auto-configura e l'ultima riga è solo un suggerimento testuale (`$ pm2 unstartup systemd`) → la pipe lo esegue letteralmente e fallisce (`$: command not found`), facendo fallire l'intero runcmd (status: error, exit 1) | Rimossa la pipe; invocato `pm2 startup systemd -u root --hp /root` direttamente | `e8b49f9` |

## Nota per il supervisore: gap nella CI `e2e-regression.yml`

Ispezionato `.github/workflows/e2e-regression.yml` (non modificato in questa fase, fuori dallo scope della sub-issue #8): lo step "Attendi completamento cloud-init" verifica il completamento con `lxc exec ... -- cloud-init status | grep -q "status: done"`. Il bug #1 di questa fase (magic header mancante) produceva un output `cloud-init status --long` con **prima riga `status: done`** e solo `extended_status: degraded done` a indicare il problema — quindi quella grep **non lo avrebbe intercettato**: la CI sarebbe passata anche con un container completamente non provisionato (nessun pacchetto installato). Il bug #2 (pipe `pm2 startup`) invece produceva `status: error` e sarebbe stato correttamente intercettato. Segnalato al supervisore via commento sulla sub-issue #8; eventuale fix della CI (es. usare `cloud-init status --wait` con controllo dell'exit code, o verificare anche `extended_status`) lasciato a una decisione successiva, non applicato qui per non uscire dallo scope di questa fase.

## Esito

Container `n8n-collaudo-f1` creato con successo al terzo tentativo, cloud-init `done` senza errori, n8n online e raggiungibile su HTTP. `n8n-server` mai toccato. Il container va lasciato acceso per la Fase 5 (verifica servizi), come previsto dall'handoff.

## Riferimenti
- Handoff seguito: `collaudo/handoff_fase4.md`
- Sub-issue: https://github.com/danielesalpietro/n8n-lxd-terraform/issues/8
