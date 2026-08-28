# Template — Logbook compresso di fase

Ogni sessione, a fine lavoro, DEVE produrre `collaudo/logbook_faseN_compresso.md`
seguendo esattamente questa struttura. È l'unico documento che la sessione
della fase successiva è obbligata a leggere: deve essere **autosufficiente**
(nessun rimando a leggere logbook compressi di fasi precedenti a questa) e
**compresso** (solo informazioni operative, niente narrazione, niente log
grezzi di comandi). Indicativamente 100–200 righe, mai il trascritto della
sessione.

Copia questo template, compila ogni sezione, cancella le istruzioni in corsivo.

---

# Logbook compresso — Fase N

## Stato finale
- Esito: COMPLETATA / COMPLETATA CON RISERVE / BLOCCATA
- Data/ora fine sessione (UTC):
- Sub-issue GitHub: #N — stato: chiusa / aperta (motivo se aperta)
- Commit di riferimento (hash brevi) prodotti in questa sessione:

## Configurazione rilevante per le fasi successive
*Solo i valori che una sessione futura deve conoscere per non dover
ricostruire lo stato da zero. Mai password in chiaro: indicare solo dove
si trovano (es. "in terraform.tfvars sull'host, non versionato").*

- container_name:
- storage_pool:
- rete/bridge usato:
- versioni rilevate: LXD `x.y`, Terraform `x.y`, provider `terraform-lxd/lxd x.y`, Node `x.y`
- IP del container di test (se ancora esistente) o "distrutto a fine sessione"

## Bug riscontrati e fix applicati
*Tabella breve. Se un fix è già stato descritto in un logbook compresso
precedente e resta valido, NON ripeterlo qui: è già "assorbito" dal fatto
che il codice in repo lo contiene. Riportare solo i fix di QUESTA sessione.*

| Bug | Fix applicato | Commit |
|-----|----------------|--------|

## Problemi aperti / non risolti
*Bullet list. Ciò che la fase successiva deve sapere PRIMA di iniziare,
perché irrisolto o perché impatta la fase successiva.*

-

## Esito checklist di fase
*Riporta solo la spunta finale di ogni voce della checklist della sub-issue,
non il dettaglio di come è stata verificata (quello resta nel logbook
esteso, se serve un approfondimento).*

- [ ] ...
- [ ] ...

## Carry-over ancora valido dalle fasi precedenti
*Questa è la sezione che rende il file autosufficiente: riporta qui, in
forma già compressa, tutto ciò che hai ereditato dal logbook compresso
della fase precedente (o da quelle ancora prima, tramite la catena) che
resta rilevante per la fase successiva. Se non c'è nulla di nuovo da
aggiungere rispetto a quanto già scritto sopra in "Configurazione
rilevante", scrivi semplicemente "Nessun carry-over aggiuntivo oltre
quanto già riportato sopra."*

## Riferimenti
- Handoff seguito: `collaudo/handoff_faseN.md`
- Logbook esteso (facoltativo, solo per approfondimento): `collaudo/logbook_faseN.md`
- Sub-issue: https://github.com/danielesalpietro/n8n-lxd-terraform/issues/N
