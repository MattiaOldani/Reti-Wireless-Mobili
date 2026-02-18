// Setup

#import "alias.typ": *

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


// Lezione
// Slide 36 05_AODV

= Lezione 09 [16/02]

== AODV

/*
Aggiorna ultima foto della rete che manca una entry
*/

=== RREP

Abbiamo il processo di *RREQ*: con questo messaggio avevamo costruito il *percorso reverse* da *A* ad *H*, così che ora *H* possa fare una *RREP* sulla stessa rotta.

Partiamo con il formato di una *RREP*.

#align(center)[
  #image("assets/09/RREP.png")
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
  #image("assets/09/esempio_01.png")
]

Il nodo *D* aggiorna la sua entry, mentre *F* ha una entry valida per *H*, il suo SN è più fresco e il flag D è $0$, quindi *F* risponde al nodo *A* con una RREP. Il nodo *D* invece inoltra la RREQ ad *E* ed *H*.

#align(center)[
  #image("assets/09/esempio_02.png")
]

Facciamo finta che adesso *H* abbiamo risposto nello stesso momento di *F*.

#align(center)[
  #image("assets/09/esempio_03.png")
]

La RREP che arriva da *F* raggiunge *C*, che aggiorna la entry per *H* perché già ce l'aveva. La RREP che invece arriva da *H* raggiunge *D*, che invece aggiunge la entry per *H* perché non lo conosceva.

I nodi *C* e *D* ora inoltrano le loro RREP Unicast verso *A*.

#align(center)[
  #image("assets/09/esempio_04.png")
]

Al nostro *originator A* arriva la RREP da *C*, che quindi crea le entry per *H* e ha finalmente creato un percorso per la comunicazione. Al nodo *B* invece arriva la RREP da *D*, con conseguente aggiunta di una entry.

Piccolo problema: il percorso non è *asimmetrico*, visto che *H* per andare da *A* passa da *D* (sopra) mentre *A* per andare da *H* passa da *C* (sotto).

Con l'ultimo inoltro che vediamo ora sistemeremo questo problema.

#align(center)[
  #image("assets/09/esempio_05.png")
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
  #image("assets/09/esempio_06.png")
]

Il nodo *F* riceve la RREQ, può rispondere e lo fa, ma avendo *G* settato deve mandare una *seconda RREP*, che è *gratuitous*, verso il nodo *H*, come se il nodo *H* avesse chiesto di trovare una rotta per *A*.

Mandiamo quindi le due RREP verso *A* ed *H*.

#align(center)[
  #image("assets/09/esempio_07.png")
]

Il nodo *C* ora conosce *H*, mentre il nodo *G* conosce *A*, anche se *H* non ha mai mandato una RREQ per scoprire *A*.

Facciamo ora l'ultimo inoltro delle due RREP.

#align(center)[
  #image("assets/09/esempio_08.png")
]

La procedura si completa: *A* conosce *H* e *H* conosce *A*, grazie ad *F* che ha fatto la doppia RREP.

=== Esercizio

Facciamo un *esercizio* su RREQ e RREP. Ci viene data la seguente *topologia*, e dobbiamo mandare un messaggio da *A* ad *E*.

#align(center)[
  #image("assets/09/esercizio.svg", width: 50%)
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
  #image("assets/09/hello.png", width: 70%)
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
  #image("assets/09/RERR.png")
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
// Inizio 06_cellulare.pdf

== Rete cellulare

Passiamo finalmente alla *rete cellulare*. Siamo in un ambito molto diverso dalle reti *WPAN* e *WLAN*, visto che qua abbiamo una *copertura* molto più grande.

=== Storia

La *rete pre-cellulare* (prima degli anni $'80$) aveva la telefonia mobile ma:
+ avevamo pochi trasmettitori e ricevitori, tutti ad alta potenza;
+ avevamo solo $25$ canali di multiplexing;
+ avevamo $80$km di copertura.

Volevamo risolvere un *problema*: non eravamo capaci di fornire un servizio di telefonia voce mobile che fosse comparabile con la telefonia fissa.

La prima mossa è stata alzare il *numero di trasmettitori*, abbassando però la *potenza* sotto i $100$W e ottenendo quindi un *minore raggio di copertura*. L'area geografica viene divisa in *celle*, ognuna con almeno un'antenna. Ogni cella ha una *Base Station* (BS) che fa da trasmettitore, ricevitore e unità di controllo.

Le celle possono operare *Unlicensed* ma anche *Licensed* a suon di miliardi di euro se un operatore telefonico compra quel pezzo di spettro.

La rete cellulare permette la *gestione automatica della mobilità* degli utenti e la *continuità* (roaming). Nel tempo però abbiamo visto queste aggiunte:
+ *$1$G* ($1980$), con *Advanced Mobile Phone Service* (AMPS) introduce la voce analogica in mobilità, purtroppo in chiaro non cifrata;
+ *$2$G* ($1990$), con *Global System for Mobile Communications* (GSM) introduce lo standard per la voce digitale;
+ *$3$G* ($2000$), con *Universal Mobile Telecommunications System* (UMTS) introduce il servizio internet in ambito mobile;
+ *$4$G* ($2010$), con *Long Term Evolution* (LTE) introduce la convergenza di IP e un aumento delle prestazioni tramite banda larga in mobilità:
+ *$5$G* ($2020$) introduce la softwarizzazione della rete e la sua virtualizzazione, oltre a slicing e bassa latenza;
+ *$6$G* ($2030$) introdurrà quello non fatto in $5$G oltre ad algoritmi di ML e AI.

Nel tempo si è anche vista una netta separazione tra *canali di controllo* e *canali radio*. L'evoluzione non è comunque avvenuta a compartimenti stagni, ma è stata una cosa graduale e in continua evoluzione.

=== Base Station

La *Base Station* (BS) è formata da varia parti.

#align(center)[
  #image("assets/09/BS.png", width: 40%)
]

Abbiamo una *antenna* con una *Remote Radio Head*, che è staccata dalla parte di controllo. Questa parte radio è collegata via *fibra ottica* alle *Baseband Unit*, che sono quelle che gestiscono i segnali in banda base. La comunicazione poi va avanti sulla *fibra ottica*.

=== Celle e riuso delle frequenze

La *celle* seguono una *geometria* ben specifica, almeno nella *teoria*: infatti, sono pensate per avere la stessa distanza tra tutte le BS che appartengono a celle adiacenti della rete.

#align(center)[
  #image("assets/09/celle.png", width: 70%)
]

Ovviamente è *teorica* come disposizione: se abbiamo ostacoli la copertura della cella si adatta e questa viene distorta.

#align(center)[
  #image("assets/09/deformazione.png", width: 70%)
]

Abbiamo un *problema*: lavorando sempre con la stessa banda di frequenza in tutte le celle, i dispositivi che si trovano al bordo di due celle ricevono il segnale da due BS diverse e si ha una continua *interferenza*.

#align(center)[
  #image("assets/09/interferenza.png", width: 70%)
]

Dobbiamo dare delle *politiche di riuso delle frequenze*.

==== CDMA

Una prima soluzione è stare sulle stesse frequenze ma usare *CDMA* come tecnica di codifica per evitare le interferenze.

==== Frequenze diverse

Una seconda soluzione assegna *bande diverse* a celle vicine, ma questo mi obbliga ad avere più bande, ma questo si ottiene con:
+ *riduzione della banda* oppure
+ sborsare grandi soldoni $dollar dollar dollar$ per avere bande licensed.

#align(center)[
  #image("assets/09/colori.png", width: 70%)
]

==== Bordi

Una terza soluzione assegna sì delle frequenze diverse a celle vicine ma *solo sui bordi*. Questo è molto comodo: assegniamo una sola banda al bordo, così dividiamo le celle, e poi tutte le altre bande le usiamo al centro della cella.

#align(center)[
  #image("assets/09/bordi.png", width: 70%)
]

Questo ci permette un *grande data rate*, ma richiede un sofisticato controllo di potenza e coordinamento tra le varie BS, che quindi avviene solo nelle versioni *$4$G* e *$5$G*.

// Slide 16 05_cellulare.pdf
