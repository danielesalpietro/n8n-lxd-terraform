# Handoff — Fase 0: Verifica ambiente e accessi

> Istruzioni operative per la sessione dedicata a questa fase. Sessione con accesso SSH diretto all'host MicroCloud che ospita LXD.

## 0. Prima di iniziare (obbligatorio)

- Contesto progetto: repository `n8n-lxd-terraform` — Terraform + cloud-init per il deployment automatico di n8n su un container LXD/LXC in un host MicroCloud. Il codice non è mai stato collaudato in modo formale/documentato: questa è la primissima fase di collaudo strutturato. Per la visione d'insieme completa vedi `README.md` e `handoff_test_and_dev.md` (non obbligatorio rileggerlo tutto: questo file contiene già ciò che serve per la Fase 0).
- **Nota (emersa durante la prima esecuzione di questa fase, 28/08/2026):** sull'host può esistere già un container `n8n-server` funzionante, non collegato a questo collaudo (deployment manuale precedente, ~3 mesi prima). **Non va mai toccato, modificato o distrutto.** Il container di questa fase e delle successive dovrà avere un nome diverso e inequivocabile (es. `n8n-collaudo-f1`), scelto in Fase 1. Vedi il commento del supervisore sulla sub-issue #4 per il dettaglio.
- Branch di lavoro condiviso da tutte le fasi:
  ```bash
  git fetch origin claude/repo-status-mydlk3
  git checkout claude/repo-status-mydlk3
  git pull --rebase origin claude/repo-status-mydlk3
  ```
- Questa è la Fase 0: **non esiste** un logbook compresso precedente da leggere.
- Sub-issue GitHub di questa fase: **#4** (figlia di #3 "Handoff Test & Dev"). Aggiornane i checkbox man mano che completi le verifiche.
- Crea il logbook esteso di questa fase: `collaudo/logbook_fase0.md` (testo libero, append-only: ogni comando rilevante eseguito, ogni anomalia riscontrata). È la tua memoria di lavoro; da lì produrrai il logbook compresso a fine sessione.

## 1. Obiettivo della fase

Verificare che l'host MicroCloud/LXD e gli accessi siano pronti per il collaudo, **prima di toccare il codice** — per non scambiare un problema di ambiente per un bug della procedura.

## 2. Procedura

Esegui e annota l'esito di ciascun comando nel logbook esteso:

```bash
lxc list
lxc storage list
lxc network list
lxc image list ubuntu:24.04
terraform version
git clone <repo> && cd n8n-lxd-terraform   # se non già presente sull'host
```

Verifica anche l'accesso internet in uscita dall'host (necessario a `terraform init` per scaricare i provider da registry.terraform.io) — non serve ancora verificarlo dal container, sarà oggetto della Fase 4.

## 3. Checklist (= checklist della sub-issue #4)

- [ ] SSH funzionante verso l'host MicroCloud
- [ ] `lxc list` restituisce output senza errori (client LXD configurato)
- [ ] `lxc storage list` — il pool che userai come `storage_pool` esiste davvero (es. pool Ceph)
- [ ] `lxc network list` — presenza di un bridge/rete che assegni IP via DHCP ai container
- [ ] `lxc image list ubuntu:24.04` — l'host può scaricare/ha in cache l'immagine
- [ ] `terraform version` eseguito e annotato (richiesto provider `terraform-lxd/lxd ~> 2.0`)
- [ ] Accesso internet in uscita dall'host verificato
- [ ] Repository clonato e branch `claude/repo-status-mydlk3` in checkout
- [ ] `lxc list` ispezionato per container pre-esistenti che potrebbero collidere per nome con quello del collaudo (in particolare `n8n-server`, noto e da NON toccare): annotarne nome, stato e data di creazione nel logbook, senza modificarli

## 4. Criterio di uscita

Tutti i punti della checklist verificati. Annotate nel logbook compresso le versioni esatte di LXD/Terraform e il nome esatto del pool/rete da usare in `terraform.tfvars` nella Fase 1.

## 5. Chiusura sessione (obbligatoria)

1. Verifica che la checklist rifletta lo stato reale (non spuntare voci non verificate).
2. Se hai dovuto modificare qualcosa nel codice (improbabile in questa fase, che è solo di verifica ambiente), committa e pusha su `claude/repo-status-mydlk3`.
3. Aggiorna la sub-issue **#4** su GitHub: spunta i checkbox verificati, aggiungi un commento con l'esito finale (COMPLETATA / COMPLETATA CON RISERVE / BLOCCATA). Se il criterio di uscita è soddisfatto, chiudi la sub-issue; altrimenti lasciala aperta spiegando cosa manca.
4. Genera `collaudo/logbook_fase0_compresso.md` seguendo ESATTAMENTE `collaudo/logbook_template_compresso.md`. È l'unico documento che la sessione della Fase 1 è obbligata a leggere: deve essere compresso (100–200 righe), mai il trascritto della sessione. Riporta in particolare, nella sezione "Configurazione rilevante": nome esatto del pool di storage, nome/tipo di rete, versioni installate.
5. Committa e pusha `collaudo/logbook_fase0.md` e `collaudo/logbook_fase0_compresso.md` su `claude/repo-status-mydlk3`.
6. Indica che la sessione successiva deve aprire `collaudo/handoff_fase1.md`.

## Note per il supervisore

Questa sessione NON chiude autonomamente la issue madre #3. La chiusura complessiva della Fase 1 di collaudo è responsabilità della sessione di supervisione.
