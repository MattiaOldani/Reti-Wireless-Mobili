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
// Slide 82 04_wifi.pdf

= Lezione 08 [13/02]

// Slide 35 05_AODV.pdf

== AODV

=== Introduzione

Siamo sempre in ambito *WLAN* ma al *livello applicazione/rete*. Abbiamo visto che le reti WiFi possono essere con coordinatore (AP) oppure senza (ad-hoc): oggi ci occupiamo di queste ultime.

Vediamo *Ad Hoc Distance Vector*, un protocollo a livello applicazione/rete per le reti wireless, in particolare utilizza il WiFi.

In queste reti:
+ siamo *senza infrastruttura* e la *topologia* può cambiare;
+ ogni nodo è anche un router;
+ abbiamo dei cammini multi-hop;
+ i nodi e i vicinati possono variare per mobilità, spegnimento e/o accensione.

L'*obiettivo* di *AODV* è creare un percorso tra sorgente e destinazione tenendo in considerazione che la rete è dinamica, e i link possono cambiare in qualunque momento. In poche parole, vogliamo riempire le *tabelle di routing* del livello rete.

Gli altri *obiettivi* che abbiamo sono:
+ gestione *dinamica* della rete ad hoc;
+ protocollo *auto inizializzante*, ovvero non necessita di rotte preconfigurate;
+ *loop-free*, eliminando il counting to infinity;
+ ottenimento di una rotta per una nuova destinazione in tempi rapidi;
+ risposta rapida alla rottura dei link e al cambio di topologia.

Le *funzionalità* che offrono sono:
+ scoprire e costruire percorsi per le nuove destinazioni;
+ mantenere percorsi in *modalità soft-state*;
+ riconoscimento di errori e cancellazione di percorsi.

Operiamo al *livello applicazione* sulla porta $654$ *UDP*, ma il protocollo lavora al *livello rete* perché deve popolare le tabelle di routing IP.

Andiamo ad usare un *approccio stateless*, quindi quello che sappiamo adesso è effimero e può cambiare in pochissimo tempo. In realtà, abbiamo uno *stato*, ma lo teniamo per poco perché la rete è dinamica.

#align(center)[
  #image("assets/08/rete.png", width: 70%)
]

Una rete AODV è quindi un *grafo orientato senza cappi*, in cui abbiamo dei *link radio* se e solo se entrambi i nodi sono nel raggio di copertura dell'altro.

#align(center)[
  #image("assets/08/dati.png", width: 70%)
]

Abbiamo poi la *trasmissione dati*, quindi dei *pacchetti IP* che viaggiano su *percorsi simmetrici* tramite delle *tabelle di routing*, che indicano quali sono i prossimi hop da seguire.

Esiste un nodo *originator*, che è quello che richiede la creazione di un percorso, un nodo *destinazione* e tutti i nodi interni al percorso.

#align(center)[
  #image("assets/08/RREQ.png", width: 70%)
]

I messaggi di *Route Request* (RREQ) chiedono la creazione di un percorso. Vengono mandati con un *broadcast controllato* (senza loop) al livello IP dal nodo originator e da tutti i nodi centrali eliminando l'invio multiplo.

#align(center)[
  #image("assets/08/RREP.png", width: 70%)
]

I messaggi di *Route Reply* (RREP) sono invece mandati *Unicast* al nodo originator seguendo lo stesso percorso della RREQ. Anche i nodi intermedi possono rispondere con una RREP se conoscono il percorso per il nodo richiesto e se l'informazione è *abbastanza aggiornata*.

#align(center)[
  #image("assets/08/RERR.png", width: 70%)
]

Infine, i messaggi di *Route Error* (RERR) vengono mandati quando un nodo, durante il *controllo* dei suoi next hop, rileva una rottura di un link e deve avvisare tutti i nodi che lo usano.

I pacchetti dati sono dei veri e propri *pacchetti IP*, mentre i tre messaggi di controllo sono specifici di *AODV*, che lavora a livello applicazione sulla porta $654$ UDP.

=== Tabelle di routing

Nelle *tabelle di routing* di ogni nodo teniamo le destinazione conosciute con l'indicazione del *prossimo hop* lungo il percorso. In realtà, teniamo molte più informazioni:
+ *IP* di destinazione;
+ *SEQN* della destinazione;
+ *flag di validità* del SEQN della destinazione;
+ *stato* del percorso (valido, invalido, sospeso, eccetera);
+ interfaccia di rete;
+ *hop count* per raggiungere la destinazione;
+ *lista dei precursori*, ovvero i nodi che usano questo nodo per raggiungere la destinazione;
+ *lifetime* della entry.

Il *SEQN* -- da cui in poi *SN* -- codifica l'informazione circa la *freschezza della entry*.

Il SN di un nodo è *incrementato* solo dal nodo possessore, e avviene in due casi:
+ quando il nodo inizia una RREQ, così da prevenire conflitti con i percorsi inversi stabiliti dalla precedente RREQ;
+ quando un nodo risponde ad una RREQ con una RREP, ma questo non avviene sempre.

Gli altri nodi possono *aggiornare* il SN di una entry se:
+ sono io il nodo stesso, quindi offro un nuovo percorso per me stesso;
+ il nodo riceve informazioni più aggiornate per una destinazione;
+ il percorso verso quella destinazione è scaduto o interrotto.

Per capire chi ha le informazioni *più aggiornate* basta vedere il SN.

=== RREQ

==== Formato

Vediamo il formato di un *messaggio RREQ*.

#align(center)[
  #image("assets/08/pacchetto.png")
]

Il *tipo* di un messaggio RREQ è sempre $1$. Abbiamo poi *tre flag* importanti:
+ *Gratuitous RREP flag* (G), che indica ad un nodo intermedio che, oltre a rispondere all'origine, deve informare la destinazione della creazione di un percorso reverse con l'origine;
+ *Destination Only flag* (D), che indica che solo la destinazione può rispondere;
+ *Unknown Sequence Number flag* (U), che indica che l'origine non conosce il SN della destinazione.

Abbiamo poi l'*hop count*, che indica, al *momento dell'invio*, quanti hop ha già fatto la richiesta.

Infine, ci sono cinque campi che permettono di fare *routing*:
+ *RREQ ID*, che ad ogni richiesta è aumentato di uno ed è usato per capire se ci sono richieste *duplicate* nella rete;
+ *IP di destinazione* con l'ultimo *SN* conosciuto dall'originator;
+ *IP dell'originator* con il suo *SN* appena incrementato.

Mando una *RREQ* se non conosco la DST oppure se la entry per la DST è scaduta. Dobbiamo:
+ aumentare il *RREQ ID* e il nostro *SN* di $1$;
+ se la DST è sconosciuta mettiamo il flag *U* a $1$;
+ teniamo una copia della *tupla* $chevron.l "IP-Origine", "RREQ-ID" chevron.r$ per un tempo detto *PATH_DISCOVERY_TIME*, che è il tempo che dovrebbe impiegare la RREQ per andare fino in fondo e poi tornare indietro.

Il *PATH_DISCOVERY_TIME* è un *tempo di validità*, ed è descritto nella *RFC* come:

#align(center)[
  #image("assets/08/PDS.png", width: 70%)
]

La tupla rappresenta un *ID* unico nella rete di una RREQ perché abbiamo, insieme alla RREQ ID, anche l'indirizzo IP dell'originator. Grazie a questa accortezza, evitiamo *forward* e *invii multipli*.

==== Expanding ring search

Per evitare di diffondere la RREQ inutilmente in tutta la rete, visto che magari la DST è vicina all'originator, usiamo il *Time To Live* (TTL) dell'header IP per impostare un massimo numero di hop.

Se *non conosciamo la destinazione*, impostiamo un *timer*, nel quale la RREQ deve andare a buon fine: questo primo tempo è detto *TTL_START*.

#align(center)[
  #image("assets/08/TTL_START.png")
]


Se la DST non viene trovata in questo periodo andiamo ad aumentare il timer di un tempo *TTL_INCREMENT* e riproviamo, fino a quando non troviamo la destinazione o fino a quando non raggiungiamo il tempo massimo *NET_DIAMETER*.

#align(center)[
  #image("assets/08/TTL_INC.png")

  #image("assets/08/NET_DIAMETER.png")
]

Tutti questi valori sono dei *parametri* che possiamo scegliere.

Se invece abbiamo un record nella tabella di routing per quella destinazione andiamo ad usare l'*hop count* come *TTL_START*, visto che può essere una buona stima sul valore iniziale.

La tecnica si chiama *Expanding Ring Search* perché dal punto di vista del nodo è come se stessimo espandendo il cerchio di ricerca. Tecnica ottima perché se la destinazione è vicina la richiesta rimane si broadcast ma vicina, e non la mando in culo ovunque.

Tutto questo solo per impostare il TTL della RREQ.

L'originator può riprovare la RREQ se la prima non va, ma lo può fare per un numero massimo di volte pari a *RREQ_RETRIES*. Ovviamente, ad *ogni tentativo* dobbiamo aumentare RREQ ID e SN di $1$.

==== Processamento e inoltro

Quando un nodo riceve una RREQ *controlla* se ha già ricevuto una tupla RREQ ID e indirizzo IP uguale *entro il PATH_DISCOVERY_TIME*: se sì, scarta la RREQ per evitare dei loop.

In caso contrario, deve aggiornare il *percorso reverse*:
+ confronta il SN dell'origine con quello nella sua tabella, e se il primo è maggiore lo *aggiorno*. Ovviamente, se non avevamo la entry la inseriamo;
+ marca come *valida* la entry;
+ aggiorna/aggiunge la/alla entry impostando come *next hop* il nodo da cui è arrivata la RREQ (non per forza l'originator, ma il nodo che ha fatto inoltro/invio);
+ aggiorna/aggiunge la/alla entry il campo *hop count* con il campo hop count della RREQ.

Se il nodo intermedio non può rispondere alla RREP -- flag *D* settata a $1$ -- allora dobbiamo inoltrare la RREQ. Per fare ciò dobbiamo *modificare* il messaggio:
+ aumentiamo l'*hop count* di $1$;
+ impostiamo il SN della DEST pari al massimo tra quello della RREQ e quello nella mia routing table;
+ mandiamo broadcast la RREQ a livello IP.

==== Esempio senza RREP intermedia

Vediamo un *esempio* di come funziona la RREQ.

#align(center)[
  #image("assets/08/esempio_01.png")
]

Il nodo *A* è *originator*, e vuole una rotta per *H*, di cui sa che il suo ultimo SN è pari a $140$. I nodi *D* e *F* hanno alcune informazioni su *A* ed *H*, mentre *E* in qualche modo sa arrivare ad *A*.

#align(center)[
  #image("assets/08/esempio_02.png")
]

Mandiamo la RREQ *broadcast* a *B* e *C*, che non avendo una entry per *A* la vanno ad aggiungere per costruire il *percorso reverse*, indicando il nodo da cui hanno ricevuto la RREQ come next hop per raggiungere l'originator *A*. Fatto ciò, *inoltrano* la RREQ aumentando l'hop count.

#align(center)[
  #image("assets/08/esempio_03.png")
]

Ora i nodi che ricevono la RREQ sono *D* e *F*, che però fanno due cose diverse:
+ *D* conosce *A*, quindi *aggiorna* la sua entry perché il SN della RREQ è più fresco. A parità di SN avremmo dovuto invece aggiornare l'hop count, se questo ovviamente era minore di quello a nostra disposizione;
+ *F* non conosce *A*, quindi *aggiunge* una entry usando *C* come next hop per raggiungere *A*.

Inoltre, il nodo *F* potrebbe rispondere perché conosce un percorso per la destinazione, ma non lo fa perché il flag *D* è pari a $1$ e, inoltre, conosceva un percorso vecchio, avendo $139$ come SN, minore del $140$ di *A*.

Anche questi due nodi ora *inoltrano broadcast*.

#align(center)[
  #image("assets/08/esempio_04.png")
]

Ora i nodi che hanno ricevuto la RREQ sono tre: *E*, *G* ed *H*.

I nodi *E* e *G* aggiornano/aggiungo la entry per il nodo *A*. Il nodo *H* invece, oltre ad aggiungere la entry, è anche la destinazione e dovrà rispondere con una RREP.

La *RREP* avverrò *Unicast*, così seguiamo un solo percorso, quello reverse, che abbiamo astutamente costruito durante la RREQ. Questo questo sembra *contro-intuitivo* ma funziona.

// Slide 35 05_AODV.pdf
