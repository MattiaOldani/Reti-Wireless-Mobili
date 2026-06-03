// Setup

#import "../alias.typ": *

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

= Rete cellulare

Passiamo finalmente alla *rete cellulare*. Siamo in un ambito molto diverso dalle reti *WPAN* e *WLAN*, visto che qua abbiamo una *copertura* molto più grande.

== Storia

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

== Celle e riuso delle frequenze

La *Base Station* (BS) è formata da varia parti.

#align(center)[
  #image("assets/01/BS.png", width: 40%)
]

Abbiamo una *antenna* con una *Remote Radio Head*, che è staccata dalla parte di controllo. Questa parte radio è collegata via *fibra ottica* alle *Baseband Unit*, che sono quelle che gestiscono i segnali in banda base. La comunicazione poi va avanti sulla *fibra ottica*.

La *celle* seguono una *geometria* ben specifica, almeno nella *teoria*: infatti, sono pensate per avere la stessa distanza tra tutte le BS che appartengono a celle adiacenti della rete.

#align(center)[
  #image("assets/01/celle.png", width: 70%)
]

Ovviamente è *teorica* come disposizione: se abbiamo ostacoli la copertura della cella si adatta e questa viene distorta.

#align(center)[
  #image("assets/01/deformazione.png", width: 60%)
]

Abbiamo un *problema*: lavorando sempre con la stessa banda di frequenza in tutte le celle, i dispositivi che si trovano al bordo di due celle ricevono il segnale da due BS diverse e si ha una continua *interferenza*.

#align(center)[
  #image("assets/01/interferenza.png", width: 60%)
]

Dobbiamo dare delle *politiche di riuso delle frequenze*.

// Primo modo è quello di utilizzare CDMA, quindi ogni dispositivo ha codice ortogonale dato dalle BS (ogni cella ha il suo codice). Le BS parlano tra loro, si accordano
Una prima soluzione è stare sulle stesse frequenze ma usare *CDMA* come tecnica di codifica per evitare le interferenze.

// Secondo modo (più semplice ma costosa) uso bande di frequenze diverse tra celle vicine con frequenze di guardia, margine per evitare interferenza, ma ci servono più bande (costoso, spettro licensed). Usato spesso in 2G, HW semplice configurato con una data frequenza
Una seconda soluzione assegna *bande diverse* a celle vicine, ma questo mi obbliga ad avere più bande, ma questo si ottiene con:
+ *riduzione della banda* oppure
+ sborsare grandi soldoni $dollar dollar dollar$ per avere bande licensed.

#align(center)[
  #image("assets/01/colori.png", width: 60%)
]

// Terzo modo soluzione più intelligente, che richiede HW più sofisticato (4G in poi), usiamo frequenze diverse solo sul bordo, dentro uso sempre la solita. Difficile perché richiede preciso posizionamento
Una terza soluzione assegna sì delle frequenze diverse a celle vicine ma *solo sui bordi*. Questo è molto comodo: assegniamo una sola banda al bordo, così dividiamo le celle, e poi tutte le altre bande le usiamo al centro della cella.

#align(center)[
  #image("assets/01/bordi.png", width: 70%)
]

Questo ci permette un *grande data rate*, ma richiede un sofisticato controllo di potenza e coordinamento tra le varie BS, che quindi avviene solo nelle versioni *$4$G* e *$5$G*.

== Obiettivi

Un altro degli scopi della *rete mobile*, oltre alla *mobilità*, è garantire la *scalabilità*, ovvero offrire un servizio a tantissimi dispositivi, magari con un *data rate minore*.

Possiamo ottenere questa *scalabilità* in vari modi:
+ aggiungere *più canali* e spettro;
+ farsi *prestare frequenze* dalle celle vicine, con una gestione dinamica dell'assegnamento delle frequenze;
+ *suddivisione in più celle*, andando nell'ordine delle *macro(BS)/micro/pico/femto(AP domestico) cells*, e le mettiamo in zone dove si ha un traffico elevato, visto che tutti i dispositivi sotto una cella da sola non va bene. Questo però ci obbliga a:
  - maggior *traffico di controllo* per gestire gli utenti;
  - più *frequenti handoff/handover* (cambi di cella), che sono dispendiosi.

Altra opzione per aumentare la *scalabilità* è il *cell sectoring*: al posto di avere una BS con una *antenna omnidirezionale* capace di gestire una cella sola, scegliamo di usare una *antenna direzionale* sulla stessa BS, così che questa diriga *più celle*.

#align(center)[
  #image("assets/01/sectoring.png", width: 70%)
]

Sulla *stessa BS* abbiamo quindi più celle, ma il gioco è quello di prima: o usiamo CDMA oppure usiamo frequenze diverse, vista la vicinanza tra le celle.

== Struttura

Vediamo la *struttura generale* della rete mobile.

#align(center)[
  #image("assets/01/RAN.png", width: 60%)
]

Indipendentemente dalla generazione, abbiamo questa *macro-divisione*:
+ quello che vediamo noi è la *Radio Access Network* (RAN), che contiene gli endpoint, le BS e le *BS controller*, che coordinano le BS, creano link radio con i vari dispositivo e trasportano le informazioni verso la core network;
+ la *core network*, o *Mobile Telecommunications Switching Office* (MTSO), si occupa degli switch per portare la comunicazione in giro, fa *traffico di controllo* e da fa ponte con il mondo esterno, che offre internet e servizi;
+ *servizi* e *internet*.

Tutte le operazioni della rete cellulare sono *automatiche* e non richiedono alcun intervento da parte dell'utente.

Abbiamo *due tipi di canali* che trasportano *due tipologie di traffico*:
+ *canali di controllo*, che trasportano le informazioni per la gestione delle operazioni, e questo è il *control plane*;
+ *canali di traffico*, che trasportano voce e dati, e questo è il *data plane*.

La divisione di questi è *esplicita*.

== Operazioni

La rete cellulare offre alcune *operazioni* importanti.

=== Inizializzazione e monitoraggio segnale

Nella fase di *inizializzazione* il dispositivo utente monitora i segnali delle celle per identificare quella con il segnale migliore.

#align(center)[
  #image("assets/01/inizializzazione.png", width: 55%)
]

Periodicamente ogni *BS* invia dei *pilot* che permettono ai dispositivi di determinare la qualità del segnale della cella. I pilot sono inviati basandosi sulla *coerenza del mezzo radio*, ovvero basandosi sulle condizioni del segnale che rimangono simili per un certo intervallo di tempo.

I pilot sono dei *segnali standard codificati standard con dati standard* che si sincronizzano alla BS. Questi pilot *non sono gratis*: sono del data plane, quindi abbassano il data rate.

In questa prima fase non abbiamo interpellato l'MTSO.

=== Comunicazione iniziata dal dispositivo

Un dispositivo può *iniziare la comunicazione*.

#align(center)[
  #image("assets/01/monitoraggio.png", width: 55%)
]

Per fare ciò dobbiamo:
+ trovare *disponibilità di canali* nella BS, perché senza questi la comunicazione non può partire. È la BS che sa i canali liberi, visto che gestisce *tutto* il traffico;
+ attivare un *canale di controllo* con la rete core;
+ creare dei collegamenti sul *data plane* dopo che abbiamo ottenuto l'*autorizzazione*.

=== Paging

L'operazione di *paging* rappresenta dei dati *DownLink* che partono dall'MTSO. La *rete core* non conosce tutte le BS con le celle, sono veramente troppe, quindi quando viene chiesto di localizzare un dispositivo la rete core deve chiedere alle BS di farlo.

#align(center)[
  #image("assets/01/paging.png", width: 55%)
]

La rete core chiede quindi alle BS la posizione di un dispositivo, ovvero la *cella a cui è associato*. Questa operazione è ottima perché permette ai dispositivi di andare in idle, rilasciando risorse e risparmiando batteria.

Come operazione è molto onerosa, quindi si cerca di limitarla.

=== Chiamate

Possiamo effettuare delle *chiamate*.

#align(center)[
  #image("assets/01/chiamata.png", width: 55%)
]

Il dispositivo destinatario *accetta* la chiamata, la rete core crea un circuito e le BS impostano i canali radio data plane. Durante la chiamata i due dispositivi scambiano informazioni attraverso le BS a cui sono collegate e l'MTSO.

// slide 28 ci sono altre operazioni, segnale nella review
=== Handover

L'*handover* permette ai dispositivi di muoversi dove vogliono e di mantenere le sessioni attive, ovvero *non percepiamo l'interruzione di servizio*.

#align(center)[
  #image("assets/01/handover.png")
]

Questo avviene in *tre fasi*:
+ decisione di una nuova associazione
+ gestione della nuova associazione, nella quale prima cerchiamo la nuova associazione e poi molliamo quella vecchia, dobbiamo avere subito le risorse pronte per non avere una interruzione di servizio;
+ riconfigurazione dei percorsi di comunicazione.

== Ambiente

Il contesto nel quale opera la rete cellulare è molto più *dinamico* e *imprevedibile* degli altri scenari wireless. Dobbiamo capire come gestire:
+ la *potenza del segnale*, che deve essere sufficiente per offrire un buon segnale ma non troppo per non creare interferenza, e inoltre dobbiamo stare attenti agli *ostacoli* mobili e fissi;
+ il *fading*, che è l'attenuazione del segnale per via della frequenza e del tipo di ambiente, grazie a cui possiamo calcolare il *path loss*.

Inoltre, i vari operatori usano *frequenze differenti* per scopi differenti, per avere maggiore/minore copertura ma pochi/tanti canali.

Il cosa/come/dove della rete prende il nome di *Network Planning*, e sceglie il posizionamento e il dimensionamento delle BS, la rete di trasporto verso la rete core, che bande utilizzare, eccetera.

La pianificazione, o *deployment*, avviene con molta attenzione visto che dobbiamo *ottimizzare* al meglio la rete.

== Handover

L'*handover* consente ad un dispositivo di cambiare la BS a cui è associato. La procedura può essere decisa da:
+ *la rete* (BS), che si basa sul segnale ricevuto uplink dal dispositivo;
+ *dal dispositivo coinvolto*, che analizza il segnale downlink che riceve.

La BS raccoglie le informazioni, controlla alcune *metriche* e prende la decisione se cambiare o meno la BS del dispositivo.

Vediamo quattro casi in cui possiamo fare *handover*.

=== Casistiche

#align(center)[
  #image("assets/01/grafico.png", width: 60%)
]

Abbiamo un dispositivo che si muova dalla *BS A* alla *BS B*. Il dispositivo si allontana dalla *BS A* quindi perde di segnale, che inizia invece a salire nella *BS B*.

Nella *potenza relativa* quando le due curve si intersecano andiamo a *triggerare* l'handover.

#align(center)[
  #image("assets/01/relativa.png", width: 60%)
]

Come soluzione potrebbe andare bene, perché alla fine il dispositivo ora sente meglio *B*, però il segnale non è sempre stabile e, *oscillando*, può farci rimbalzare avanti e indietro tra le due celle, creando l'*effetto ping-pong*.

Questo è molto *dispendioso* perché mandiamo solo traffico di controllo, quindi abbiamo poco data rate e abbiamo la rete core che fa un sacco di overhead.

Come unica condizione abbiamo che *RXa $<$ RXb*.

Una soluzione alternativa è l'uso di una *threshold*, una *soglia*, che è un *valore assoluto* che imponiamo noi al di sotto del cui imponiamo l'handover. Ovviamente, deve sopravvivere anche la condizione precedente.

#align(center)[
  #image("assets/01/soglia.png", width: 60%)
]

Anche se ci sono BS migliori noi aspettiamo a fare il cambio, il segnale è ancora ok. Appena andiamo sotto la soglia vediamo se la BS nuova ha un segnale migliore, e se sì cambiamo.

In questo caso dobbiamo verificare *due condizioni*, una è quella precedente, e l'altra è che *RXa $<$ T*.

La challenge di questa configurazione è *settare la threshold*.

Una soluzione alternativa è usare ancora la potenza relativa associata all'isteresi.

Le *isteresi* sono *funzioni* il cui output dipende dall'input e dallo stato precedente del sistema. Abbiamo *H*, una soglia di isteresi, che usiamo per calcolare, assieme alla differenza di potenza, se dobbiamo fare o meno handover.

#align(center)[
  #image("assets/01/ciclo.png", width: 50%)
]

In questo grafico:
+ se siamo in *A*, una differenza di potenza positiva (quindi *B migliore*) mi porta verso la *B* appena passiamo la soglia *H*;
+ se siamo in *B* abbiamo la stessa cosa ma opposta.

#align(center)[
  #image("assets/01/isteresi.png", width: 60%)
]

In questo caso nel grafico seguiamo quello con la *H*, e facciamo il cambio sull'intersezione nuova: il cambio avviene dopo, sempre con la *condizione* della potenza relativa.

Siamo più robusti al segnale, che assorbiamo nella soglia di isteresi, ma va scelta una soglia corretta e soprattutto siamo ancora con riferimenti relativi.

Uniamo tutto e otteniamo la *soluzione migliore*.

#align(center)[
  #image("assets/01/tutto.png", width: 60%)
]

Le *condizioni* diventano:
+ sono sotto soglia, quindi *RXa $<$ T*;
+ ho un segnale peggiore, quindi *RXa $<$ Rxb*;
+ sono sotto la soglia di isteresi, quindi *RXa < RXbh*.

=== Tipi di handover

Abbiamo due *tipologie di handover*;
+ *hard*, fatto in *$2$G* e da *$4$G* in poi, che obbliga ogni dispositivo ad avere *una sola BS*, in cui si ha un cambio immediato di frequenza con dei protocolli veloci;
+ *soft*, usato solo in *$3$G*, che permette ai dispositivi una connettività a *più BS*, in cui il rilascio si ha quando uno dei due segnali è dominante, ma questo richiede più risorse da allocare.

== Duplex

La gestione del *duplex*, quindi la comunicazione bidirezionale, avviene con:
+ *FDD*, che usa una banda per *UL* e una per *DL*. Soluzione ottima perché non ha delay ma è estremamente costosa;
+ *TDD*, che usa una sola frequenza e divide la comunicazione in slot temporali. In questo caso abbiamo del ritardo perché dobbiamo aspettare.

== Architettura delle Mobile Station

// forse immagine
Una *Mobile Station* (MS) è formata da due parti:
+ *Mobile Equipment* (ME), che è il dispositivo;
+ la *SIM*.

Ogni dispositivo ha un identificativo unico detto *International Mobile Equipment Identity* (IMEI), formato da $15$ cifre. Questo identifica in maniera *univoca* un dispositivo mobile.

La *SIM* contiene informazioni utili per identificare un *utente abbonato* e la chiave segreta usata per autenticazione, generazione di chiavi di cifratura, reti preferite/proibite, PIN, PUK, eccetera.

La SIM è definita da un ID unico detto *International Mobile Subscriber Identity* (IMSI), formato da al massimo $15$ cifre, divise in:
+ *Mobile Country Code* (MCC), che è lo stato dell'operatore;
+ *Mobile Network Code* (MNC), che è unico a livello nazionale;
+ *Mobile Subscriber Identification Number*.

IMSI *non* è il numero di telefono, sono due cose diverse.

Le SIM nel tempo hanno cambiato *formato*: prima erano grandi come il badge UNIMI, ora sono *embedded* dentro i dispositivi.

Sono programmabili e sono ottime perché:
+ nei dispositivi IoT non dobbiamo cambiare la SIM;
+ l'utente non deve avere una SIM fisica se vuole caricare piani diversi;
+ per i costruttori si ha meno ingombro.

#align(center)[
  #image("assets/01/SIM.png")
]

Il *numero di telefono* è definito dal *Mobile Subscriber Integrated Service Digital Number* (MSISDN), di massimo $15$ cifre, che viene usato per fornire la voce digitale come in ISDN (rete cavo classica).

Il numero di telefono viene definito dal prefisso, dalla network di destinazione e dal numero utente, ma questo lo sappiamo.

Prima avevamo un mapping IMSI $1":"1$ MSISDN, mentre ora abbiamo un mapping $1":"N$, quindi possiamo avere *più numeri sulla stessa SIM*.
