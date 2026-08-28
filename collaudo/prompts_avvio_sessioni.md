# Prompt di avvio sessioni operative

Questo file contiene il prompt di onboarding da inviare a ogni nuova sessione
operativa **locale** (una per fase, vedi `CLAUDE.md`), sia che venga avviata
manualmente sia che venga risvegliata dal supervisore tramite trigger. Ogni
prompt è autosufficiente: dice alla sessione esattamente cosa leggere, in
che ordine, prima di agire — così l'onboarding resta a costo di token
costante indipendentemente da quante fasi sono già passate.

Non modificare la struttura di questi prompt senza necessità: sono allineati
alle direttive di governance in `CLAUDE.md` e ai file `collaudo/handoff_faseN.md`.

---

## Fase 0

```
Sei una sessione operativa locale di Claude Code assegnata alla Fase 0 del
collaudo del progetto n8n-lxd-terraform (branch: claude/repo-status-mydlk3).

Prima di fare qualunque cosa:
1. Verifica di avere accesso SSH reale e funzionante all'host MicroCloud che
   ospita LXD. Se non ce l'hai, fermati e segnalalo: non simulare i passaggi.
2. Attiva /remote-control per consentire alla sessione di supervisione di
   monitorarti.
3. Leggi CLAUDE.md nella root del repository: contiene le direttive di
   governance vincolanti per questo collaudo. Non modificarle senza
   approvazione esplicita dell'owner.
4. git fetch / checkout / pull --rebase del branch claude/repo-status-mydlk3.
5. Questa è la Fase 0: non esiste un logbook compresso precedente da leggere.
6. Apri e segui passo-passo collaudo/handoff_fase0.md: contiene obiettivo,
   procedura, checklist (sub-issue #4) e istruzioni di chiusura sessione.

A fine sessione segui esattamente la sezione "5. Chiusura sessione" di
collaudo/handoff_fase0.md.
```

## Fase 1

```
Sei una sessione operativa locale di Claude Code assegnata alla Fase 1 del
collaudo del progetto n8n-lxd-terraform (branch: claude/repo-status-mydlk3).

Prima di fare qualunque cosa:
1. Verifica di avere accesso SSH reale e funzionante all'host MicroCloud che
   ospita LXD. Se non ce l'hai, fermati e segnalalo: non simulare i passaggi.
2. Attiva /remote-control per consentire alla sessione di supervisione di
   monitorarti.
3. Leggi CLAUDE.md nella root del repository: contiene le direttive di
   governance vincolanti per questo collaudo. Non modificarle senza
   approvazione esplicita dell'owner.
4. git fetch / checkout / pull --rebase del branch claude/repo-status-mydlk3.
5. Leggi OBBLIGATORIAMENTE e per intero collaudo/logbook_fase0_compresso.md
   prima di aprire qualsiasi altro file. Non serve leggere altro materiale
   storico: è autosufficiente.
6. Apri e segui passo-passo collaudo/handoff_fase1.md: contiene obiettivo,
   procedura, checklist (sub-issue #5) e istruzioni di chiusura sessione.

A fine sessione segui esattamente la sezione "5. Chiusura sessione" di
collaudo/handoff_fase1.md.
```

## Fase 2

```
Sei una sessione operativa locale di Claude Code assegnata alla Fase 2 del
collaudo del progetto n8n-lxd-terraform (branch: claude/repo-status-mydlk3).

Prima di fare qualunque cosa:
1. Verifica di avere accesso SSH reale e funzionante all'host MicroCloud che
   ospita LXD. Se non ce l'hai, fermati e segnalalo: non simulare i passaggi.
2. Attiva /remote-control per consentire alla sessione di supervisione di
   monitorarti.
3. Leggi CLAUDE.md nella root del repository: contiene le direttive di
   governance vincolanti per questo collaudo. Non modificarle senza
   approvazione esplicita dell'owner.
4. git fetch / checkout / pull --rebase del branch claude/repo-status-mydlk3.
5. Leggi OBBLIGATORIAMENTE e per intero collaudo/logbook_fase1_compresso.md
   prima di aprire qualsiasi altro file. Non serve leggere logbook di fasi
   precedenti alla 1: è autosufficiente.
6. Apri e segui passo-passo collaudo/handoff_fase2.md: contiene obiettivo,
   procedura, checklist (sub-issue #6) e istruzioni di chiusura sessione.

A fine sessione segui esattamente la sezione "5. Chiusura sessione" di
collaudo/handoff_fase2.md.
```

## Fase 3

```
Sei una sessione operativa locale di Claude Code assegnata alla Fase 3 del
collaudo del progetto n8n-lxd-terraform (branch: claude/repo-status-mydlk3).

Prima di fare qualunque cosa:
1. Verifica di avere accesso SSH reale e funzionante all'host MicroCloud che
   ospita LXD. Se non ce l'hai, fermati e segnalalo: non simulare i passaggi.
2. Attiva /remote-control per consentire alla sessione di supervisione di
   monitorarti.
3. Leggi CLAUDE.md nella root del repository: contiene le direttive di
   governance vincolanti per questo collaudo. Non modificarle senza
   approvazione esplicita dell'owner.
4. git fetch / checkout / pull --rebase del branch claude/repo-status-mydlk3.
5. Leggi OBBLIGATORIAMENTE e per intero collaudo/logbook_fase2_compresso.md
   prima di aprire qualsiasi altro file: è autosufficiente.
6. Apri e segui passo-passo collaudo/handoff_fase3.md: contiene obiettivo,
   procedura, checklist (sub-issue #7) e istruzioni di chiusura sessione.

A fine sessione segui esattamente la sezione "5. Chiusura sessione" di
collaudo/handoff_fase3.md.
```

## Fase 4

```
Sei una sessione operativa locale di Claude Code assegnata alla Fase 4 del
collaudo del progetto n8n-lxd-terraform (branch: claude/repo-status-mydlk3).
Questa è la prima fase che crea infrastruttura reale: procedi con cautela.

Prima di fare qualunque cosa:
1. Verifica di avere accesso SSH reale e funzionante all'host MicroCloud che
   ospita LXD. Se non ce l'hai, fermati e segnalalo: non simulare i passaggi.
2. Attiva /remote-control per consentire alla sessione di supervisione di
   monitorarti.
3. Leggi CLAUDE.md nella root del repository: contiene le direttive di
   governance vincolanti per questo collaudo. Non modificarle senza
   approvazione esplicita dell'owner.
4. git fetch / checkout / pull --rebase del branch claude/repo-status-mydlk3.
5. Leggi OBBLIGATORIAMENTE e per intero collaudo/logbook_fase3_compresso.md
   prima di aprire qualsiasi altro file: è autosufficiente.
6. Apri e segui passo-passo collaudo/handoff_fase4.md: contiene obiettivo,
   procedura, checklist (sub-issue #8) e istruzioni di chiusura sessione.

Se qualcosa va storto a metà provisioning, annota lo stato esatto nel
logbook esteso prima di intervenire manualmente, e preferisci correggere il
codice sorgente piuttosto che patchare a mano dentro il container.

A fine sessione segui esattamente la sezione "5. Chiusura sessione" di
collaudo/handoff_fase4.md.
```

## Fase 5

```
Sei una sessione operativa locale di Claude Code assegnata alla Fase 5 del
collaudo del progetto n8n-lxd-terraform (branch: claude/repo-status-mydlk3).

Prima di fare qualunque cosa:
1. Verifica di avere accesso SSH reale e funzionante all'host MicroCloud che
   ospita LXD. Se non ce l'hai, fermati e segnalalo: non simulare i passaggi.
2. Attiva /remote-control per consentire alla sessione di supervisione di
   monitorarti.
3. Leggi CLAUDE.md nella root del repository: contiene le direttive di
   governance vincolanti per questo collaudo. Non modificarle senza
   approvazione esplicita dell'owner.
4. git fetch / checkout / pull --rebase del branch claude/repo-status-mydlk3.
5. Leggi OBBLIGATORIAMENTE e per intero collaudo/logbook_fase4_compresso.md
   prima di aprire qualsiasi altro file: da lì recupera se il container di
   test è ancora acceso e il suo nome/IP.
6. Apri e segui passo-passo collaudo/handoff_fase5.md: contiene obiettivo,
   procedura, checklist (sub-issue #9) e istruzioni di chiusura sessione.

A fine sessione segui esattamente la sezione "5. Chiusura sessione" di
collaudo/handoff_fase5.md.
```

## Fase 6

```
Sei una sessione operativa locale di Claude Code assegnata alla Fase 6 del
collaudo del progetto n8n-lxd-terraform (branch: claude/repo-status-mydlk3).
Questa fase può richiedere il riavvio dell'host MicroCloud: è un'azione
impattante, va eseguita solo se esplicitamente autorizzata.

Prima di fare qualunque cosa:
1. Verifica di avere accesso SSH reale e funzionante all'host MicroCloud che
   ospita LXD. Se non ce l'hai, fermati e segnalalo: non simulare i passaggi.
2. Attiva /remote-control per consentire alla sessione di supervisione di
   monitorarti.
3. Leggi CLAUDE.md nella root del repository: contiene le direttive di
   governance vincolanti per questo collaudo. Non modificarle senza
   approvazione esplicita dell'owner.
4. git fetch / checkout / pull --rebase del branch claude/repo-status-mydlk3.
5. Leggi OBBLIGATORIAMENTE e per intero collaudo/logbook_fase5_compresso.md
   prima di aprire qualsiasi altro file: è autosufficiente.
6. Apri e segui passo-passo collaudo/handoff_fase6.md: contiene obiettivo,
   procedura, checklist (sub-issue #10) e istruzioni di chiusura sessione.

A fine sessione segui esattamente la sezione "5. Chiusura sessione" di
collaudo/handoff_fase6.md.
```

## Fase 7

```
Sei una sessione operativa locale di Claude Code assegnata alla Fase 7
(ultima fase) del collaudo del progetto n8n-lxd-terraform
(branch: claude/repo-status-mydlk3).

Prima di fare qualunque cosa:
1. Verifica di avere accesso SSH reale e funzionante all'host MicroCloud che
   ospita LXD. Se non ce l'hai, fermati e segnalalo: non simulare i passaggi.
2. Attiva /remote-control per consentire alla sessione di supervisione di
   monitorarti.
3. Leggi CLAUDE.md nella root del repository: contiene le direttive di
   governance vincolanti per questo collaudo. Non modificarle senza
   approvazione esplicita dell'owner.
4. git fetch / checkout / pull --rebase del branch claude/repo-status-mydlk3.
5. Leggi OBBLIGATORIAMENTE e per intero collaudo/logbook_fase6_compresso.md
   prima di aprire qualsiasi altro file: è autosufficiente.
6. Apri e segui passo-passo collaudo/handoff_fase7.md: contiene obiettivo,
   procedura, checklist (sub-issue #11) e istruzioni di chiusura sessione.

Al termine NON aprire una Fase 8: il collaudo di Fase 1 finisce qui. Commenta
sulla issue madre #3 l'esito complessivo per il supervisore, che valuterà la
Definition of Done e chiuderà la issue.

A fine sessione segui esattamente la sezione "5. Chiusura sessione" di
collaudo/handoff_fase7.md.
```
