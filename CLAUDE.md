# CLAUDE.md

Istruzioni di progetto per sessioni Claude Code che lavorano su questo repository.

## Direttive di governance — Collaudo Fase 1 (n8n su LXD/MicroCloud)

> **Queste direttive sono vincolanti per ogni sessione che lavora al collaudo descritto in `handoff_test_and_dev.md` e nei file `collaudo/handoff_faseN.md`.**
> Qualunque modifica a questa sezione richiede l'approvazione esplicita dell'owner del progetto (Daniele Salpietro) **prima** di essere applicata. Nessuna sessione — operativa o di supervisione — può modificare autonomamente queste regole, nemmeno se ritiene di aver trovato un'alternativa migliore: può solo proporla e attendere conferma.

### 1. Le sessioni operative devono essere locali

Ogni sessione che esegue una fase del collaudo (Fase 0–7, vedi `collaudo/handoff_faseN.md`) necessita di **accesso SSH diretto all'host MicroCloud**. Questo accesso richiede una rete/interfaccia locale che una sessione cloud effimera non ha. Di conseguenza:

- Le sessioni operative devono essere **sessioni locali di Claude Code** (eseguite su una macchina con accesso di rete/SSH reale verso l'host MicroCloud), mai sessioni remote/cloud.
- Non avviare una fase del collaudo da una sessione cloud: se manca l'accesso SSH reale, la sessione deve fermarsi e segnalarlo, non simulare o saltare i passaggi.

### 2. Le sessioni operative devono abilitare `/remote-control`

Ogni sessione operativa deve attivare **`/remote-control`** all'avvio del proprio turno di lavoro, in modo che la sessione di supervisione possa osservarne l'andamento in tempo reale. Questo non sostituisce il logbook (che resta la fonte di verità scritta), ma consente al supervisore di intervenire tempestivamente se una sessione si blocca o devia dal piano.

### 3. Comunicazione supervisore ↔ sessioni operative: solo tramite trigger

Il canale di comunicazione tra la sessione di supervisione e le sessioni operative **è il sistema di trigger/Routine** (`create_trigger` / `fire_trigger` / `list_triggers`), non messaggistica diretta libera o ad-hoc. In pratica:

- Il supervisore usa un trigger per **avviare/risvegliare** la sessione operativa della fase successiva quando la fase precedente risulta chiusa (sub-issue chiusa + logbook compresso pubblicato).
- Il supervisore usa trigger periodici di **check-in** per monitorare una sessione operativa in corso (in aggiunta all'osservazione via `/remote-control` e agli eventi GitHub sulla relativa sub-issue).
- Una sessione operativa che ha bisogno di allertare il supervisore fuori da un check-in programmato lo fa commentando la sub-issue GitHub della propria fase (vedi `collaudo/handoff_faseN.md`, sezione "Chiusura sessione") — il commento è l'evento che il supervisore intercetta.

### 4. Ruolo del supervisore

Il supervisore:
- non esegue comandi SSH sull'host MicroCloud e non modifica il codice sotto test;
- verifica, per ogni fase, che la sub-issue collegata (#4–#11, figlie di #3 "Handoff Test & Dev") sia stata chiusa con il relativo `collaudo/logbook_faseN_compresso.md` pubblicato e coerente con il criterio di uscita descritto nell'handoff di fase;
- solo dopo questa verifica autorizza (via trigger) l'avvio della sessione operativa della fase successiva;
- è l'unico responsabile della chiusura finale della issue madre #3, secondo la Definition of Done in `handoff_test_and_dev.md`.

---

*Ultima modifica di queste direttive concordata con l'owner in data 2026-08-28.*
