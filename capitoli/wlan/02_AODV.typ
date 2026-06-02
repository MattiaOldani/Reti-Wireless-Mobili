// Setup

#import "../alias.typ": *

#import "@preview/tablex:0.0.9": colspanx, rowspanx, tablex

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


// Capitolo

/*********************************************/
/***** DA CANCELLARE PRIMA DI COMMITTARE *****/
/*********************************************/
// #set heading(numbering: "1.")

// #show outline.entry.where(level: 1): it => {
//   v(12pt, weak: true)
//   strong(it)
// }

// #outline(indent: auto)
/*********************************************/
/***** DA CANCELLARE PRIMA DI COMMITTARE *****/
/*********************************************/

= AODV

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
  #image("assets/02/rete.png", width: 70%)
]

Una rete AODV è quindi un *grafo orientato senza cappi*, in cui abbiamo dei *link radio* se e solo se entrambi i nodi sono nel raggio di copertura dell'altro.

#align(center)[
  #image("assets/02/dati.png", width: 70%)
]

Abbiamo poi la *trasmissione dati*, quindi dei *pacchetti IP* che viaggiano su *percorsi simmetrici* tramite delle *tabelle di routing*, che indicano quali sono i prossimi hop da seguire.

Esiste un nodo *originator*, che è quello che richiede la creazione di un percorso, un nodo *destinazione* e tutti i nodi interni al percorso.

#align(center)[
  #image("assets/02/_RREQ.png", width: 70%)
]

I messaggi di *Route Request* (RREQ) chiedono la creazione di un percorso. Vengono mandati con un *broadcast controllato* (senza loop) al livello IP dal nodo originator e da tutti i nodi centrali eliminando l'invio multiplo.

#align(center)[
  #image("assets/02/_RREP.png", width: 70%)
]

I messaggi di *Route Reply* (RREP) sono invece mandati *Unicast* al nodo originator seguendo lo stesso percorso della RREQ. Anche i nodi intermedi possono rispondere con una RREP se conoscono il percorso per il nodo richiesto e se l'informazione è *abbastanza aggiornata*.

#align(center)[
  #image("assets/02/_RERR.png", width: 70%)
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
  #image("assets/02/pacchetto.png")
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
  #image("assets/02/PDS.png", width: 70%)
]

La tupla rappresenta un *ID* unico nella rete di una RREQ perché abbiamo, insieme alla RREQ ID, anche l'indirizzo IP dell'originator. Grazie a questa accortezza, evitiamo *forward* e *invii multipli*.

==== Expanding ring search

Per evitare di diffondere la RREQ inutilmente in tutta la rete, visto che magari la DST è vicina all'originator, usiamo il *Time To Live* (TTL) dell'header IP per impostare un massimo numero di hop.

Se *non conosciamo la destinazione*, impostiamo un *timer*, nel quale la RREQ deve andare a buon fine: questo primo tempo è detto *TTL_START*.

#align(center)[
  #image("assets/02/TTL_START.png")
]


Se la DST non viene trovata in questo periodo andiamo ad aumentare il timer di un tempo *TTL_INCREMENT* e riproviamo, fino a quando non troviamo la destinazione o fino a quando non raggiungiamo il tempo massimo *NET_DIAMETER*.

#align(center)[
  #image("assets/02/TTL_INC.png")

  #image("assets/02/NET_DIAMETER.png")
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
  #image("assets/02/eesempio_01.png")
]

Il nodo *A* è *originator*, e vuole una rotta per *H*, di cui sa che il suo ultimo SN è pari a $140$. I nodi *D* e *F* hanno alcune informazioni su *A* ed *H*, mentre *E* in qualche modo sa arrivare ad *A*.

#align(center)[
  #image("assets/02/eesempio_02.png")
]

Mandiamo la RREQ *broadcast* a *B* e *C*, che non avendo una entry per *A* la vanno ad aggiungere per costruire il *percorso reverse*, indicando il nodo da cui hanno ricevuto la RREQ come next hop per raggiungere l'originator *A*. Fatto ciò, *inoltrano* la RREQ aumentando l'hop count.

#align(center)[
  #image("assets/02/eesempio_03.png")
]

Ora i nodi che ricevono la RREQ sono *D* e *F*, che però fanno due cose diverse:
+ *D* conosce *A*, quindi *aggiorna* la sua entry perché il SN della RREQ è più fresco. A parità di SN avremmo dovuto invece aggiornare l'hop count, se questo ovviamente era minore di quello a nostra disposizione;
+ *F* non conosce *A*, quindi *aggiunge* una entry usando *C* come next hop per raggiungere *A*.

Inoltre, il nodo *F* potrebbe rispondere perché conosce un percorso per la destinazione, ma non lo fa perché il flag *D* è pari a $1$ e, inoltre, conosceva un percorso vecchio, avendo $139$ come SN, minore del $140$ di *A*.

Anche questi due nodi ora *inoltrano broadcast*.

#align(center)[
  #image("assets/02/eesempio_04.png")
]

Ora i nodi che hanno ricevuto la RREQ sono tre: *E*, *G* ed *H*.

I nodi *E* e *G* aggiornano/aggiungo la entry per il nodo *A*. Il nodo *H* invece, oltre ad aggiungere la entry, è anche la destinazione e dovrà rispondere con una RREP.

La *RREP* avverrò *Unicast*, così seguiamo un solo percorso, quello reverse, che abbiamo astutamente costruito durante la RREQ. Questo questo sembra *contro-intuitivo* ma funziona.

// Slide 35 05_AODV.pdf

== AODV

/*
Aggiorna ultima foto della rete che manca una entry
*/

=== RREP

Abbiamo il processo di *RREQ*: con questo messaggio avevamo costruito il *percorso reverse* da *A* ad *H*, così che ora *H* possa fare una *RREP* sulla stessa rotta.

Partiamo con il formato di una *RREP*.

#align(center)[
  #image("assets/02/RREP.png")
]

Il campo *type* in questo caso è $2$, seguito da un bit riservato e un *bit di ACK* se vogliamo creare un percorso affidabile, ma questo non ci interessa.

Abbiamo poi la *prefix size* per identificare le subnet e l'*hop count* che, come nella RREQ, indica quanti hop sta facendo il messaggio.

Per la parte *indirizzi* abbiamo:
+ *destination IP address*, che è l'IP di chi ha ricevuto la RREQ;
+ *destination SN*, che è quello della DST o quello contenuto in una entry di un nodo intermedio se la RREQ aveva il *flag D* a $0$;
+ *originator IP*, che è quello che creato la RREQ.

Infine, abbiamo la *lifetime* in millisecondi, che indica per quanto deve stare valida una entry nelle tabelle di routing.

Una *RREP* può essere *generata* da:
+ *la destinazione della RREQ*, che deve:
  - incrementare il suo SN;
  - settare l'hop count a $0$;
  - impostare il campo lifetime al valore *MY_ROUTE_TIMEOUT* (parametro che di default vale $6$ secondi);
  - inviare la *RREP Unicast* sul percorso reverse;
  - droppare la RREQ;
+ un *nodo intermedio* se (devono valere tutte):
  - abbiamo una entry valida per quel percorso;
  - *flag D* pari a $0$;
  - il DST SN della entry è più *fresco* di quello della RREQ, quindi DST SN $gt.eq$ DST RREQ.
  Se valgono queste allora il nodo deve:
  - settare l'hop count pari all'hop count della sua entry;
  - aggiornare la lista dei precursori;
  - impostare il campo lifetime pari alla lifetime della sua entry;
  - inviare la *RREP Unicast* sul percorso reverse;
  - droppare la RREQ;
  - se il *flag G* è pari a $1$ deve inviare una seconda RREP verso la DST.

I *precursori* vengono aggiornati solo durante le *RREP*: infatti, durante le RREQ non sappiamo se quei percorsi poi verranno utilizzati. Alla lista dei precursori aggiungiamo il nodo da cui abbiamo ricevuto la RREP, visto che sappiamo che lui usa noi per raggiungere la destinazione.

Se invece riceviamo una RREP *aggiorniamo* la entry della tabella se (if-else):
+ la entry corrente non è valida;
+ il DST SN della RREP è $>$ del DST SN della entry;
+ il numero di hop della RREP è $<$ del numero di hop della entry, a parità di SN.

Se si verifica uno di questi casi dobbiamo:
+ segnare la entry come valida;
+ impostare il nodo da cui proviene la RREP come *next hop* per la DST richiesta nella RREQ (*percorso reverse*);
+ aggiorno il RREP hop count aumentandolo di $1$;
+ aggiorno la lifetime della entry;
+ aggiorno la lista dei precursori.

==== Senza G

Riprendiamo l'esempio dell'altra volta, o almeno la sua *topologia*. In questo caso andiamo con *flag D* a $0$ e *flag G* a $0$.

Siamo tornati al secondo hop, con una RREQ che arriva a *D* ed *F*.

#align(center)[
  #image("assets/02/esempio_01.png")
]

Il nodo *D* aggiorna la sua entry, mentre *F* ha una entry valida per *H*, il suo SN è più fresco e il flag D è $0$, quindi *F* risponde al nodo *A* con una RREP. Il nodo *D* invece inoltra la RREQ ad *E* ed *H*.

#align(center)[
  #image("assets/02/esempio_02.png")
]

Facciamo finta che adesso *H* abbiamo risposto nello stesso momento di *F*.

#align(center)[
  #image("assets/02/esempio_03.png")
]

La RREP che arriva da *F* raggiunge *C*, che aggiorna la entry per *H* perché già ce l'aveva. La RREP che invece arriva da *H* raggiunge *D*, che invece aggiunge la entry per *H* perché non lo conosceva.

I nodi *C* e *D* ora inoltrano le loro RREP Unicast verso *A*.

#align(center)[
  #image("assets/02/esempio_04.png")
]

Al nostro *originator A* arriva la RREP da *C*, che quindi crea le entry per *H* e ha finalmente creato un percorso per la comunicazione. Al nodo *B* invece arriva la RREP da *D*, con conseguente aggiunta di una entry.

Piccolo problema: il percorso non è *asimmetrico*, visto che *H* per andare da *A* passa da *D* (sopra) mentre *A* per andare da *H* passa da *C* (sotto).

Con l'ultimo inoltro che vediamo ora sistemeremo questo problema.

#align(center)[
  #image("assets/02/esempio_05.png")
]

Al nodo *A* arriva una RREP con *SN migliore*, quindi avviene un cambio di entry. Con questa ultima mossa abbiamo costruito finalmente il *percorso simmetrico* che volevamo.

==== Con G

Utilizzando il *flag G* a $1$ un nodo intermedio che risponde con una RREP si deve occupare di "costruire" il *rimanente percorso* che manca da lui fino alla DST della RREQ.

Per fare ciò vengono mandate *due RREP*:
+ una verso il *nodo originator*, che ha creato la RREQ;
+ una verso la *DST della RREQ*, con:
  - hop count pari all'hop count che il nodo ha nella entry verso l'originator;
  - destinazione pari all'IP di origine della RREQ;
  - destination SN pari al SN che il nodo ha nella entry verso l'originator;
  - originator IP pari all'IP di DST della RREQ;
  - lifetime pari al lifetime che il nodo ha nella entry verso l'originator.
  In poche parole, abbiamo *invertito* tutti i campi.

Come vediamo, con questo andiamo a risolvere una *potenziale asimmetria*.

Riprendiamo ancora l'esempio di prima, sempre al secondo hop e con *flag D* a $0$, ma ci occupiamo solo della parte sotto e il *flag G* è $1$.

#align(center)[
  #image("assets/02/esempio_06.png")
]

Il nodo *F* riceve la RREQ, può rispondere e lo fa, ma avendo *G* settato deve mandare una *seconda RREP*, che è *gratuitous*, verso il nodo *H*, come se il nodo *H* avesse chiesto di trovare una rotta per *A*.

Mandiamo quindi le due RREP verso *A* ed *H*.

#align(center)[
  #image("assets/02/esempio_07.png")
]

Il nodo *C* ora conosce *H*, mentre il nodo *G* conosce *A*, anche se *H* non ha mai mandato una RREQ per scoprire *A*.

Facciamo ora l'ultimo inoltro delle due RREP.

#align(center)[
  #image("assets/02/esempio_08.png")
]

La procedura si completa: *A* conosce *H* e *H* conosce *A*, grazie ad *F* che ha fatto la doppia RREP.

=== Esercizio

Facciamo un *esercizio* su RREQ e RREP. Ci viene data la seguente *topologia*, e dobbiamo mandare un messaggio da *A* ad *E*.

#align(center)[
  #image("assets/02/esercizio.svg", width: 50%)
]

Assumiamo che il SN di *A* sia già stato incrementato. Vediamo come cambiano le *tabelle di routing* durante le varie fasi. Una *fase* è mando + ricevo + aggiorno, in questo ordine.

#align(center)[
  #tablex(
    rows: 23,
    columns: 17,
    inset: 10pt,
    align: center + horizon,
    fill: (x, y) => if x >= 1 and x <= 4 {
      red.lighten(50%)
    } else if x >= 5 and x <= 8 {
      orange.lighten(50%)
    } else if x >= 9 and x <= 12 {
      yellow.lighten(50%)
    } else if x >= 13 {
      green.lighten(50%)
    },

    [],
    colspanx(4)[*Inizio*],
    colspanx(4)[*Primo passo*],
    colspanx(4)[*Secondo passo*],
    colspanx(4)[*Terzo passo*],

    rowspanx(5)[*A*],
    colspanx(2)[*SN*],
    colspanx(2)[$10$],
    colspanx(2)[*SN*],
    colspanx(2)[$10$],
    colspanx(2)[*SN*],
    colspanx(2)[$10$],
    colspanx(2)[*SN*],
    colspanx(2)[$10$],
    [*DST*],
    [*SN*],
    [*HC*],
    [*NH*],
    [*DST*],
    [*SN*],
    [*HC*],
    [*NH*],
    [*DST*],
    [*SN*],
    [*HC*],
    [*NH*],
    [*DST*],
    [*SN*],
    [*HC*],
    [*NH*],
    [B],
    [$10$],
    [$1$],
    [B],
    [B],
    [$10$],
    [$1$],
    [B],
    [B],
    [$10$],
    [$1$],
    [B],
    [B],
    [$10$],
    [$1$],
    [B],
    [C],
    [$20$],
    [$1$],
    [C],
    [C],
    [$20$],
    [$1$],
    [C],
    [C],
    [$20$],
    [$1$],
    [C],
    [C],
    [$20$],
    [$1$],
    [C],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [E],
    [$10$],
    [$3$],
    [B],
    [E],
    [$10$],
    [$3$],
    [B],

    colspanx(17)[],

    rowspanx(5)[*B*],
    colspanx(2)[*SN*],
    colspanx(2)[$10$],
    colspanx(2)[*SN*],
    colspanx(2)[$10$],
    colspanx(2)[*SN*],
    colspanx(2)[$10$],
    colspanx(2)[*SN*],
    colspanx(2)[$10$],
    [*DST*],
    [*SN*],
    [*HC*],
    [*NH*],
    [*DST*],
    [*SN*],
    [*HC*],
    [*NH*],
    [*DST*],
    [*SN*],
    [*HC*],
    [*NH*],
    [*DST*],
    [*SN*],
    [*HC*],
    [*NH*],
    [A],
    [$5$],
    [$1$],
    [A],
    [A],
    [$10$],
    [$1$],
    [A],
    [A],
    [$10$],
    [$1$],
    [A],
    [A],
    [$10$],
    [$1$],
    [A],
    [D],
    [$10$],
    [$1$],
    [D],
    [D],
    [$10$],
    [$1$],
    [D],
    [D],
    [$10$],
    [$1$],
    [D],
    [D],
    [$10$],
    [$1$],
    [D],
    [E],
    [$10$],
    [$1$],
    [D],
    [E],
    [$10$],
    [$1$],
    [D],
    [E],
    [$10$],
    [$1$],
    [D],
    [E],
    [$10$],
    [$1$],
    [D],

    colspanx(17)[],

    rowspanx(4)[*C*],
    colspanx(2)[*SN*],
    colspanx(2)[$20$],
    colspanx(2)[*SN*],
    colspanx(2)[$20$],
    colspanx(2)[*SN*],
    colspanx(2)[$20$],
    colspanx(2)[*SN*],
    colspanx(2)[$20$],
    [*DST*],
    [*SN*],
    [*HC*],
    [*NH*],
    [*DST*],
    [*SN*],
    [*HC*],
    [*NH*],
    [*DST*],
    [*SN*],
    [*HC*],
    [*NH*],
    [*DST*],
    [*SN*],
    [*HC*],
    [*NH*],
    [A],
    [$5$],
    [$1$],
    [A],
    [A],
    [$10$],
    [$1$],
    [A],
    [A],
    [$10$],
    [$1$],
    [A],
    [A],
    [$10$],
    [$1$],
    [A],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [],
    [E],
    [$31$],
    [$1$],
    [E],

    colspanx(17)[],

    rowspanx(5)[*E*],
    colspanx(2)[*SN*],
    colspanx(2)[$30$],
    colspanx(2)[*SN*],
    colspanx(2)[$30$],
    colspanx(2)[*SN*],
    colspanx(2)[$31$],
    colspanx(2)[*SN*],
    colspanx(2)[$31$],
    [*DST*],
    [*SN*],
    [*HC*],
    [*NH*],
    [*DST*],
    [*SN*],
    [*HC*],
    [*NH*],
    [*DST*],
    [*SN*],
    [*HC*],
    [*NH*],
    [*DST*],
    [*SN*],
    [*HC*],
    [*NH*],
    [B],
    [$10$],
    [$2$],
    [D],
    [B],
    [$10$],
    [$2$],
    [D],
    [B],
    [$10$],
    [$2$],
    [D],
    [B],
    [$10$],
    [$2$],
    [D],
    [D],
    [$10$],
    [$1$],
    [D],
    [D],
    [$10$],
    [$1$],
    [D],
    [D],
    [$10$],
    [$1$],
    [D],
    [D],
    [$10$],
    [$1$],
    [D],
    [],
    [$$],
    [$$],
    [],
    [],
    [$$],
    [$$],
    [],
    [A],
    [$10$],
    [$2$],
    [C],
    [A],
    [$10$],
    [$2$],
    [C],
  )
]

Nella prima fase abbiamo la *RREQ* da *A* a *B* e da *A* a *C*.

Nella seconda fase abbiamo la *RREQ* da *C* ad *E* e la *RREP* da *B* ad *A*.

Nella terza fase abbiamo la *RREP* da *E* a *C*.

=== Responsabilità dei nodi

I nodi hanno alcune *responsabilità*.

Una prima è quella di indicare la sua presenza ai nodi vicini, per *mantenere la connettività* e quindi mantenere le entry valide nelle loro tabelle di routing.

Usiamo quindi gli *hello message*, che sono *messaggi di controllo* AODV *broadcast* in cui ogni nodo indica le informazioni circa la propria connettività. Visto che la rete è dinamica facciamo sapere ai vicini che ci siamo anche noi.

#align(center)[
  #image("assets/02/hello.png", width: 70%)
]

Questi messaggi sono *RREP* con *TTL unitario* e:
+ *DST IP* pari al nostro IP;
+ *DST SN* pari al nostro SN;
+ *hop count* pari 0;
+ *lifetime* pari al prodotto tra *ALLOWED_HELLO_LOSS* e *HELLO_INTERVAL*.

Sono messaggi che non *vengono inoltrati*, ma servono solo per creare/modificare le entry e le lifetime. Ovviamente non sempre arrivano, visto che siamo in UDP.

Inoltre, ciascuno nodo è *responsabile* anche di *mantenere la connettività* degli hop sui suoi vicini. Prima eravamo noi che *ci annunciavamo* alla rete, ora dobbiamo vedere se i nostri vicini ci sono ancora.

I nostri vicini sono i *next hop* delle tabelle di routing.

Abbiamo due *meccanismi* principali:
+ al *livello data link* tramite dei pacchetti *RTS/CTS/ACK*, metodo immediato che vede subito se mancano CTS o ACK oppure se andiamo al massimo numero di ritrasmissioni;
+ al *livello rete* se riceviamo pacchetti dai nostri next hop li manteniamo, altrimenti possiamo usare delle RREQ Unicast oppure ancora ICMP Echo Unicast (*ping*).

=== RERR

Quando un nodo trova un *link interrotto* che fa parte di un percorso attivo deve:
+ invalidare i percorsi esistenti;
+ identificare tutte le DST che hanno come next hop il bro del link interrotto;
+ determina quali vicini possono essere affetti da questo problema guardando i *predecessori*;
+ invia a questi vicini una *RERR*.

Vediamo il *formato* di una *RERR*.

#align(center)[
  #image("assets/02/RERR.png")
]

Il campo *type* ora è $3$ (chi l'avrebbe mai detto), poi abbiamo un *flag N* di No Delete che indica alla destinazione della RERR di non eliminare la entry perché il percorso lo abbiamo riparato localmente.

Abbiamo poi un campo *DestCount* ($>0$) che indica il numero di destinazioni non più raggiungibili. Troviamo infine un numero di *coppie* pari a DestCount formate da IP della destinazione non raggiungibile e il SN della entry che avevamo.

Andiamo ad *inviare* una RERR quando:
+ viene identificato un link interrotto quando dobbiamo inoltrare pacchetti DATA su quel link;
+ se riceviamo un pacchetto DATA per una destinazione per cui non abbiamo entry;
+ se riceviamo una RERR da un vicino per uno dei nostri percorsi attivi.

I primi due casi creiamo noi la RERR, nel terzo caso la inoltriamo.

Dobbiamo invece processare e inoltrare una RERR:
+ marchiamo come invalide le entry delle destinazioni indicate nella RERR;
+ ogni entry che viene invalidata viene preservata per un tempo *DELETE_PERIOD* (nel caso ci sia una riparazione, non la buttiamo via subito, la teniamo comunque nella routing table);
+ inoltriamo la RERR ai predecessori.

Le RERR possono essere inviate broadcast o unicast ai vicini, e sono sempre a *TTL unitario*.

La *Local Repair* è il meccanismo che fa un nodo quando riceve un pacchetto DATA, si accorge che il link è interrotto e cerca di sistemarlo. Ovviamente, non dobbiamo andare a perdere troppo tempo: facciamo una ricerca quasi locale, in circa un terzo del diametro, definito da *MAX_REPAIR_TTL*.

Questa riparazione è *reattiva*, non proattiva, ovvero lo facciamo in reazione all'evento di ricezione di un pacchetto DATA.

Come detto facciamo una RREQ limitata, che non deve raggiungere la sorgente. Se falliamo la RREQ mandiamo una RERR, altrimenti aggiorniamo le nostre entry e mandiamo comunque la RERR ma con *flag N* pari a $1$ se troviamo un percorso peggiore del precedente. Chi riceve la RERR poi deciderà se procedere con una nuova RREQ.

In fase di *Reboot* potremmo avere delle informazioni vecchie: aspettiamo quindi un tempo *DELETE_PERIOD* in cui non trasmettiamo RREQ, non inoltriamo niente e se riceviamo dei pacchetti DATA mandiamo una RERR, perché nel mio periodo di spegnimento io non so cosa è successo.

// Fine 05_AODV.pdf
