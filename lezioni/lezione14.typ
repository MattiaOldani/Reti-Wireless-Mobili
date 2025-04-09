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

= Lezione 14 [09/04]

Se un nodo intermedio non può rispondere con RREP (flag destination only) allora deve inoltrare RREQ ai vicini:
- incrementa hop count di $1$
- pongo il DST SN come il massimo tra quello che ho e quello che ho nella routing table
- mando broadcast $255.255.255.255$

[ESEMPIO]

Se avesi link tra A e E cosa si salva $D$? Si tiene la prima, visto che abbiamo anche la request ID

Ora $H$ se vuole comunicare con $A$ ha il percorso fatto

La route reply RREP ha:
- type = 2
- flag $A$ di ack richiesto in risposta a RREP per prevenire link non affidabile / unidirezionale
- prefix size utilizzato per la subnet
- hop count
- destination IP address (chi fa la reply)
- destination sequence number
- originator IP address (chi ha fatto al RREQ)
- lifetime (determinato da chi ha fatto la RREP) in millisecondi di validità

Chi può generare una RREP?

Ovviamente la destinazione:
- incremento il SN
- hop a $0$
- aggiorna la lista dei precursori (aggiorno le mie entry)
- metto lifetime MY_ROUTE_TIMEOUT (default 6 secondi)
- invio la RREP lungo il reverse unicast (non con indirizzo originator, ma di quello che uso per raggiungere originator)
- droppo la RREQ (se mi arriva una nuova RREQ ma che ha stesso ID e stessa persone bro non ti ascolto)

Ma anche un nodo intermedio. Sotto quali condizioni (and):
- entry con un percorso valido, ovvero non deve essere invalidato
- flag D a zero, posso rispondere
- DST SN della entry è $gt.eq$ DST SN della RREQ, quello che ho io è più nuovo di quello che richiede il bro

Allora:
- hop count della entry
- aggiorno la lista dei precursori
- lifetime della entry
- invio RREP in reverse
- droppo la RREQ
- se flag G 1 allora invio RREP anche alla destinazione

Se un nodo riceve la RREP:
- aggiorno la entry nella tabella se:
  - entry non valida
  - DST SN della RREP maggiore di quello che ho nella entry
  - numero di hop minore rispetto a quello della entry
- aggiorna:
  - entry valida
  - next hop nodo da cui arriva la RREP
  - aggiorno hop count nella RREP di uno
  - aggiorno lifetime
  - aggiorno precursori

[ESEMPIO]

Se avessi anche il flag gratuitous: è una scelta dell'originator, se si riceve una RREQ con questo flag a uno il nodo deve occuparsi di costruire il rimanente percorso verso la destinazione della RREQ

Vengono quindi inviate due RREP indipendenti:
- verso il nodo originator
- verso la destinazione della RREQ, come se lei mi avesse fatto una RREP:
  - hop count uguale alla entry verso origine RREQ
  - altro

[ESEMPIO]

Quelli sul percorso gratuitous scoprono come arrivare all'originator

Precursori sono quelli che mi usano per arrivare alla destinazione dell'entry

Ogni nodo può indicare informazioni circa la propria connettività inviando periodicamente in broadcast degli "hello message" ai propri vicini

Questo ha un TTL = 1 in broadcast per conoscere il vicinato:
- DST IP è IP del nodo stesso
- DST SN è SN del nodo stesso
- hop count 0
- lifetime è ALLOWED_HELLO_LOSS \* HELLO_INTERVAL

I vicini che ricevono hello message estendono o creano la entry per il nodo

È compito dei singoli nodi di tenere traccia della connettività con i nodi che sono indicati come next hop nella entry della tabella di routing. Abbiamo diversi meccanismi:
- livello data-link si invia il pacchetto RTS/CTS/ACK, in caso di mancanza di CTS/ACK o fallimento di invio dopo max ritrasmissioni
- livello di rete, con ricezione di qualsiasi pacchetto dal next hop, RREQ con destinazione il next hop o ICMP echo unicast per il next hop

Che fare se il percorso è interrotto/scaduto e fa parte di un percorso attivo:
- invalida i percorsi esistenti
- identifica le destinazioni per le quali viene usato come next hop
- determinare quali vicini possono essere affetti da questo problema, e li troviamo nella lista dei precursori
- inviamo a questi vicini un Route ERRor (RERR)

Formato:
- tipo = 3
- flag N indica alla destinazione della RERR di non eliminare la entry perché il percorso è stato riparato localmente da chi ha mandato la RERR
- dest count quante coppie di IP + SN che non si riescono più a raggiungere
- posso aggiungere tante coppie IP + SN che sono extra e che non sono raggiungibili (32 bit quindi IPv4)
