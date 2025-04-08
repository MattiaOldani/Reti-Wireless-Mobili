// Setup

#import "alias.typ": *

#import "@preview/lovelace:0.3.0": pseudocode-list

#let settings = (
  line-numbering: "1:",
  stroke: 1pt + blue,
  hooks: 0.2em,
  booktabs: true,
  booktabs-stroke: 2pt + blue,
)

#let pseudocode-list = pseudocode-list.with(..settings)

#import "@local/typst-theorems:1.0.0": *
#show: thmrules.with(qed-symbol: $square.filled$)


// Lezione

/*********************************************/
/***** DA CANCELLARE PRIMA DI COMMITTARE *****/
/*********************************************/
#set heading(numbering: "1.")

#show outline.entry.where(level: 1): it => {
  v(12pt, weak: true)
  strong(it)
}

#outline(indent: auto)
/*********************************************/
/***** DA CANCELLARE PRIMA DI COMMITTARE *****/
/*********************************************/

= Lezione 13 [08/04]

802.11p è una soluzione ad-hoc per il wifi veicolare, usando banda unlicensed. Soluzione per:
- rete super dinamica
- supporto alla guida autonoma (sensori, alert scambiati tra veicoli)
- associazione veloce
- no access point
- supporto per servizi critici (collisione, pedaggi, servizi a bordo strada) a varie latenze
- supporto infotainment

DSRC dedicated short-range communications

Si ha uno standard apposta, WAVE [Wireless Access for Vehicular Environment], che hanno una serie di servizi che non usano indirizzamento IP e altro e hanno uno stack a parte, specifici per questo

Su MAC si usa 802.11e con le varie priorità, messaggi di controllo (veicolare) o messaggi di servizio che vanno ovunque

Inoltre, non abbiamo RTS e CTS pagando il terminale nascosto, di solito si ridonda lo stato più volte

== AODV

Ci muoviamo a livello di rete, vediamo Ad Hoc Distance Vector, protocollo di routing, deve creare e riempire le tabelle di instradamento

Pensato per una rete senza infrastruttura in cui ogni nodo è anche un router, ovvero può fare instradamento. Non abbiamo un concetto di porta ma si deve mandare pacchetto da src a dst. Cerchi sono raggi di copertura radio dei nodi, se non è ampio da arrivare alla destinazione si fa instradamento.

Qui abbiamo raggio di copertura variabile, nodi mobili (liberi) e possono essere attivi/spenti, come facciamo a gestirlo?

Prima domanda: approccio stateful o stateless? La tabella di routing non è statica, perché cambia in continuazione, quindi devo tenere qualcosa dentro da aggiornare

Se per un po' non ricevo faccio decadere le info, inoltre se non mi richiedono un certo percorso non sto a tenere, se si creo

Obiettivi:
- gestione della dinamica della rete ad hoc
- auto inizializzante (non servono rotte preconfigurate)
- loop-free (non si ha counting-to-infinity)
- ottenimento di una rotta per una nuova destinazione in tempi rapidi
- risposta rapida alla rottura dei link e al cambio di topologia

Funzionalità:
- scoprire e costruire i percorsi per le nuove destinazioni
- mantenere i percorsi in soft-state (tengo per un tot)
- riconoscimento di errori e cancellazione di percorsi

Protocollo per creare tabelle di routing a livello rete, si usa la porta 654 con UDP, ma che modifica informazioni a livello di rete

Nodo ORIG è originator (da RFC, come se fosse sorgente). I dati vengono inviati su percorsi simmetrici: se per fare ORIG-->DST passiamo per $n_1,dots,n_k$ lo facciamo anche al ritorno. Inoltre, ogni nodo tiene le tabelle di routing per quel percorso

Percorsi costruiti con il messaggio di Ruote REQuest (RREQ) inviato in broadcast controllato (no loop). I nodi inoltrano RREQ e tengono traccia da dove proviene la richiesta. La destinazione risponde unicast con una Rute REPly (RREP)

Altro messaggio è RERR (Route ERRor) che viene mandato ai vicini che utilizzano lui per andare verso certi percorsi

Ogni nodo mantiene una tabella delle destinazioni conosciute e l'indicazione del prossimo hop lungo il percorso:
- IP destinazione
- sequence number della destinazione
- flag di validità del sequence number della destinazione
- stato del percorso (valido/invalido/altro)
- interfaccia di rete
- hop count (numero di hop per raggiungerlo)
- lista dei precursori (vicini che utilizzano questo nodo per raggiungere la destinazione)
- lifetime della entry (tempo di scadenza)

Sequence number: ogni entry della tabella di routing possiede un sequence number che codifica l'informazione circa la freschezza della entry, Incrementato in due casi:
- se nodo inizia una ricerca di percorso aumento di 1 per prevenire conflitti con i percorsi inverni stabiliti da RREQ prima
- se nodo rispondo (DST) ad una richiesta RREP, aumento di 1 solo in alcuni casi

Il nodo corrente è l'unico che aumenta il sequence number, solo lui è responsabile della freschezza

Gli altri nodi possono solo aggiornare il sequence number di una entry se:
- è il nodo stesso e offre un nuovo percorso per se stesso
- il nodo riceve informazioni più aggiornate per una destinazione
- il percorso verso quella destinazione è scaduto/interrotto

Confronto i SN per capire chi è più aggiornato: metti regola

Formato delle RREQ

[IMMAGINE]

Campi:
- type = 1
- G = gratuitous RREP flag, dice ad un nodo intermedio di costruire un percorso reverse con l'origine, oltre a rispondere
- D = destination only flag, se $1$ io accetto delle risposte solo dalla destinazione
- U = unknown sequence number flag, se $1$ non conosco il SN della destinazione
- hop count: numero di hop attuali (inizio 0) che questa richiesta ha fatto
- RREQ ID: ID della richiesta, se già visto non inoltro, aumentato ad ogni nuova RREQ
- destination IP address + destination SN: per chi stiamo costruendo + cosa conosco per ora
- originator IP address + originator SN: SN più fresco per questa richiesta, ++ ad ogni RREQ

Quando faccio una RREQ: mandata se non conosco DST o la entry è scaduta:
- prima di inviare faccio RREQID++ e SN++
- se DST è sconosciuta faccio U=1
- tengo una copia di \<origineIP,RREQID> per un tempo PATH_DISCOVERY_TIME per evitare il riprocessamento della richiesta che sta circolando

Usiamo expanding ring search

Possiamo dire di propagare la RREQ fino ad un certo punto: usiamo il campo TTL di IP per impostare il max hop che la RREQ può fare.

Impostiamo un timer all'invio con una TTL_START, magari la DST è vicina. Se non mi torna allora a TTL_START non ho niente (chi riceve a TTL 0 non inoltra)

Incrementiamo, quindi facciamo TTL_INCREMENT fino a NET_DIAMETER (massimo valore di TTL possibile)

Ecco perché expanding: parto normale, poi mano a mano aumento l'anello

Se invece ho già un percorso, ma scaduta o interrotta, faccio ripartire la ricerca con il vecchio numero di hop, magari sono ancora li, altrimenti inizio ad aumentare

Abbiamo anche la retry policy: posso riprovare le RREQ se il primo tentativo non va, bla bla bla

Cosa succede se ricevo un RREQ:
- controllo il dizionario di prima, se uguale entro il PATH_DISCOVERY_TIME scarto
- aggiorno il percorso reverse (quello verso originator):
  - quando ricevo RREQ so che dal nodo che me l'ha mandato posso arrivare all'origine
  - confronto il SN dell'origin e il SN che ho in tabella, se è maggiore aggiorno (se non ho entry la butto dentro)
  - entry diventa valida
  - aggiorno/aggiungo la entry impostando come next hop verso orig il nodo da cui mi è arrivata la RREQ
  - io so che da dove ho ricevuto la richiesta ho un certo numero di HOP, messo nel pacchetto, quindi lo metto come hop count nella entry
