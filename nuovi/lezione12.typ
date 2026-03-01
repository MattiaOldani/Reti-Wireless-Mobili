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
// Slide 55 07_LTE.pdf

= Lezione 12 [27/02]

== Rete cellulare

=== E-UTRAN

==== Architettura

Abbandoniamo il livello fisico e vediamo in generale l'*architettura* della rete RAN, che *interfacce* ci sono e che *protocolli* hanno a bordo i dispositivi.

#align(center)[
  #image("assets/12/interfacce.png", width: 50%)
]

In questa *architettura* i "fili" sono *interfacce logiche*, sulle quali abbiamo dei *protocolli* specifici che ci dicono cosa può viaggiare.

Le linee tratteggiate ci collegano alla rete core tramite *interfaccia S$1$*, mentre le linee continua permettono agli eNodeB di *parlare tra loro* senza interpellare la rete core usando il *protocollo X$2$*.

Infatti, questa è una innovazione di LTE, che permette ai eNodeB di fare *auto config*, gestire l'*handover* e regolare la *potenza di trasmissione*.

Ovviamente, sono *connessioni logiche*, quindi possono essere *realizzate* in vari modi, usando ponti radio oppure usando la fibra verso la rete IP classica.

==== Tracking area

Gli *eNodeB* sono raggruppati in aree geografiche, e ogni eNodeB viene gestito da un *pool di MME*, che sono nodi di rete core che permettono di fare load balancing e fault tolerance.

#align(center)[
  #image("assets/12/tracking.png", width: 70%)
]

Queste aree geografiche sono le *tracking area*: abbiamo gruppi di SGW e MME che gestiscono le varie aree, tramite *associazione dinamica*, permettendo di fare del *load balancing* (gestione del carico di rete) e *fault tolerance* (se un MME cade ci sono altri a coprirlo).

==== Interfaccia X2

L'*interfaccia X$2$* permette la *comunicazione diretta tra eNodeB*, e questo ci permette di:
+ gestire l'*handover* in alternativa al protocollo S$1$;
+ avere le *Self-Organizing Network* (SON) facendo load balancing e gestione delle interferenze (potenza di trasmissione);
+ mantenere uno *storico* delle ultime celle visitate per gestire l'effetto ping-pong tra le celle, negando l'handover se uno zio vuole fare troppi handover di fila.

==== Architettura ma più densa

Purtroppo, quando vediamo il link dalla rete E-UTRAN alla rete core, questo non è un *semplice hop* ma è un percorso ben più complicato.

#align(center)[
  #image("assets/12/delay.png", width: 70%)
]

Come vediamo, noi siamo in basso a sinistra con la *rete E-UTRAN*, ma per arrivare alla *rete core* in basso a destra dobbiamo passare per un sacco di reti, che magari sono pure intasate.

Quindi, ovviamente, abbiamo molto *delay* e non un singolo hop come di solito facciamo vedere.

==== Control Plane

Vediamo come funziona il *Control Plane*.

#align(center)[
  #image("assets/12/control.png", width: 70%)
]

Al *livello fisico* abbiamo RAN a sinistra e quello che vogliamo a destra. Al *livello MAC* abbiamo invece lo scheduler dei RB. Sopra questi abbiamo alcuni *protocolli nuovi*, che ora vediamo.

Partiamo con i protocolli *tra UE ed eNodeB*.

Il *protocollo Radio Resource Control* (RRC) gestisce le risorse radio, ma non il link radio. Si occupa di *paging*, *mobilità* (handover) e raccoglie le misurazione degli UE per la QoS.

Il *Packet Data Convergence Protocol* (PDCP) permette la compressione degli header, mappando i dati sui canali fisici sottostanti.

Il *protocollo Radio Link Control* (RLC) si occupa di controllare il link al livello due, facendo correzione degli errori, gestione della ritrasmissione e segmentazione/assemblaggio dei pacchetti dei livelli superiori mettendoli in blocchi MAC.

Il *protocollo Medium Access Control* (MAC) classico gestisce l'accesso al canale radio è gestisce lo scheduler dei RB, ma solo nell'eNodeB.

Vediamo ora i protocolli *tra eNodeB e MME*.

Il *protocollo S$1$-AP* si trova al livello applicazione per permettere il trasporto del *traffico di controllo*.

Lo *Stream Control Transmission Protocol* (SCTP) si trova al livello trasporto e viene usato per ottimizzare il trasporto del traffico di segnalazione. Lo vedremo tra poco nello specifico.

Il *protocollo IP* riguarda gli indirizzi *interni*, privati dentro la rete dell'operatore, e fa routing dei messaggi del control plane.

Ovviamente, l'eNodeB è *dual stack*, visto che deve parlare radio con gli UE e cablato con l'MME.

Infine, *tra UE e MME* abbiamo solo il *protocollo Non-Access Stratum* (NAS), che permette messaggi di livello $7$ direttamente tra UE e MME usando gli eNodeB come *relay* (ripetitore).

===== SCTP

Diamo un occhio nello specifico al *protocollo SCTP*, e perché è stato scelto questo e non il classico protocollo TCP.

Il *protocollo TCP* non va bene per LTE:
+ ha trasporto affidabile e in ordine, ma non la consegna solo affidabile e l'ordine parziale;
+ *Head of Line Blocking Problem*;
+ è *stream-oriented* e usa dei marker per delimitare i messaggi;
+ manca il *Multi-Homing*, ovvero la quadrupla (IP IP porta porta) non ci copre se un MME cade o cambia IP.

L'*HOL Blocking Problem* lo abbiamo quando dobbiamo spedire dei pacchetti. Uno dei primi viene perso e tutti quelli dopo sono bloccati nel buffer perché TCP deve aspettare per ritrasmettere.

Questo è un problema in LTE perché supponiamo di avere diversi messaggi di controllo che arrivano all'eNodeB e devono essere inoltrati all'MME. Se perdiamo un blocco di uno dei messaggi iniziali tutti gli altri non saranno processati, anche se appartengono a *dispositivi diversi* e sono totalmente ok.

#align(center)[
  #image("assets/12/HOL_01.png", width: 70%)
]

Una possibile soluzione è creare *più connessioni TCP* tra eNodeB e MME, togliendo il delay che avevamo poco fa, ma questo non scala per niente visto che ci servono tantissime risorse.

#align(center)[
  #image("assets/12/HOL_02.png", width: 70%)
]

La soluzione che usa *SCTP* è quella che usano anche HTTP/$2$ e Quick, ovvero si aumenta leggermente l'*overhead* dell'header aggiungendo uno *stream ID*. Con questa noi abbiamo un *unico flusso SCTP* ma i pacchetti sono *taggati*, quindi anche se viene perso qualcosa viene bloccato solo quel flusso e non tutti gli altri.

Questo ovviamente introduce un *ordine parziale* nei pacchetti.

SCTP ci permette anche di avere un *pool di IP sorgente* e un *pool di IP destinazione*, visto che abbiamo un pool di MME che gestisce la nostra tracking area. Inoltre, questo ci permette la fault tolerance e il load balancing: visto che possiamo mandare i pacchetti su più path, sfruttiamo questo per parallelizzare l'invio dei pacchetti, tanto sono numerati.

Finiamo con l'ultima differenza tra SCTP e TCP.

In *TCP* abbiamo uno *stream*, ed è compito dell'applicazione delimitare i vari messaggi. Con "delimitare" intendiamo che in un blocco dati possiamo avere i dati di più messaggi, per questo il marker è fondamentale.

#align(center)[
  #image("assets/12/TCP.png", width: 70%)
]

Noi vogliamo eliminare il marker per evitare il parsing.

Sfruttiamo quello che fa *UDP*: ogni blocco dati è riferito ad un *messaggio solo*, quindi non serve nessun marker e nessuna divisione, è SCTP che assembla e riassembla.

#align(center)[
  #image("assets/12/SCTP.png", width: 70%)
]

Vediamo, per riassumere, le *differenze* tra TCP e SCTP.

#align(center)[
  #image("assets/12/differenze.png", width: 70%)
]

Come vediamo, siamo sia *connection-oriented* che *message-oriented*, con una serie di qualità ottime a fare da contorno al protocollo.

==== User Plane

Passiamo ora allo *User Plane*, in cui ci sono ancora UE ed eNodeB.

#align(center)[
  #image("assets/12/data.png", width: 70%)
]

In questo caso riconosciamo molti più protocolli di prima. Rimangono *PDCP* e *RLC* per il controllo errori, ma scompare *RRC* per lasciare spazio al solo *IP* con sopra la classica parte ISO/OSI. Inoltre, viene usato *UDP* e *GTP-U*, che riprendiamo dopo.

Come vediamo, tra UE ed eNodeB siamo identici, mentre tra *eNodeB* e i vari *gateway* abbiamo qualcosa di diverso.

Dal *server* in poi abbiamo il mondo esterno, che dialoga direttamente con la parte client dell'UE in maniera *end-to-end*.

Nell'architettura abbiamo *tre livelli IP* diversi:
+ *tra UE e PGW* abbiamo indirizzi *IP interni*, assegnati da NAT e DHCP, quindi non riguardano il servizio dell'operatore;
+ *tra PGW e server* abbiamo *indirizzi IP pubblici dell'operatore mobile*, ovvero del servizio che viene offerto;
+ *tra eNodeB e gateway* abbiamo *indirizzi IP interni* che usiamo per fare routing.

Dentro la rete usiamo *GTP-User Plane* (GPT-U), che abbiamo visto l'altra volta, ma riprendiamo velocemente perché ho voglia di rifarlo.

Abbiamo un UE che ha una *Packet Data Network Session* (PDN Session), ovvero un collegamento con il PGW che deve essere mantenuto anche se l'UE si muove. In questa sessione, quando ci spostiamo, dovremmo ogni volta modificare le tabelle di routing che abbiamo tra l'UE e il PGW, facendo *overhead di controllo* gigante se cambiamo continuamente l'eNodeB a cui siamo agganciati.

*GTP* inizia proprio all'*uscita di un eNodeB* verso la rete core.

#align(center)[
  #image("assets/12/GTP.png", width: 70%)
]

Come vediamo, andiamo ad impacchettare il pacchetto utente in un *pacchetto GTP*, che incapsula appunto il messaggio con l'IP del SGW, la porta UDP usata e il *Tunnel Endpoint ID* (TEID).

Grazie a questo escamotage le tabelle interne dei vari *router* sono *fisse*, non cambiano mai e quindi tutto quello che fa l'UE non va a modificare la struttura interna della rete.

Quando arriviamo al PGW, dopo molteplici incapsulamenti e decapsulamenti, abbiamo solo il *pacchetto utente inalterato*.

Questo vale in uplink e in downlink.

Questo *overhead* di header è bassissimo considerando la *mobilità utente*: cambiamo spesso gli eNodeB, ma le tabelle di routing dentro la rete rimangono fisse.

==== Bearer

In LTE possiamo definire la *QoS* tramite i *Bearer*, dei canali radio che trasportano dati con una QoS ben definita.

La QoS viene definita *tra l'UE e il PGW* tramite *Evolved Packet Switch Bearer* (EPS Bearer), che viene però diviso in vari pezzi seguendo la divisione dell'architettura.

#align(center)[
  #image("assets/12/bearer.png", width: 70%)
]

Dobbiamo essere in grado di *bilanciare* le varie parti per ottenere al massimo il delay richiesto dall'utente.

Ogni *UE* può avere al massimo $8$ *bearer attivi*. Ogni UE ne ha sempre almeno uno, il *default bearer*, che viene creato dal PGW quando ci colleghiamo alla rete. Ogni bearer ha un *IP differente*.

Gli UE possono avere più *default bearer attivi*.

I *dedicated bearer* sono dei "*fork*" sul default bearer, in cui prendiamo l'IP del bearer da cui siamo generati. Siamo inoltre connessi allo stesso PGW, ma possiamo definire una *diversa QoS*.

Possiamo connetterci ad *altri PGW*, creando quindi altri default bearer, da cui possiamo derivare altri dedicated bearer.

#align(center)[
  #image("assets/12/molti_bearer.png", width: 90%)
]

Tra default e dedicated possiamo avere al massimo $8$ canali attivi.

Vediamo la tabella delle varie *QoS*.

#align(center)[
  #image("assets/12/QCI.png")
]

Questa tabella contiene i *Quality of Service Class Identifiers* (QCI), che sono ID che si riferiscono ad alcune classi di servizio ben definite. Ci sono quattro *parametri* che definiscono una QoS:
+ *Minimum Guaranteed Bit Rate* (GBR), ovvero quello che la rete si impegna a darmi, ovviamente se ne ha le possibilità;
+ *priorità*, usato dalle code con priorità per lo scheduling;
+ *Packet Delay Budget* (PDB) in millisecondi, che indica il delay massimo che vogliamo avere tra l'UE e il PGW;
+ *Packet Error Loss Rate* (PELR), che è la probabilità di avere un errore sui bit trasmessi.

Il traffico viene *mappato sui bearer* tramite *Traffic Flow Template* (TFT), ovvero i dispositivi ricevono i dati con la QoS richiesta e mappano il flusso su uno dei canali che riesce a garantire quanto richiesto. Questo avviene se ovviamente siamo autorizzati, ovvero se abbiamo pagato.

==== Collegamento alla rete dell'operatore

Ora vediamo la procedura di *collegamento* alla *rete operatore*.

Quando l'UE viene acceso siamo in:
+ *EMM_DEREGISTERED*, dove EMM sta per *EPS Mobility Management*, e indica che non siamo registrati ad un MME, quindi la nostra mobilità non viene gestita;
+ *ECM_IDLE*, dove ECM sta per *EPS Connection Management*, e indica che la connessione tra UE e MME per il traffico di controllo non è attiva;
+ *RRC_IDLE*, che indica che non siamo connessi ad alcun eNodeB.

#align(center)[
  #image("assets/12/collegamento_01.png", width: 70%)
]

Infatti, la rete RAN *non ci conosce*.

Come prima cosa facciamo *network selection*, in cui ascoltiamo gli eNodeB per capire il loro segnale.

La *Closed Subscriber Group* (CSG) è una lista di client che sono autorizzati all'accesso della *femtocella*, ma questa procedura è opzionale come anche la sua spiegazione in questi appunti.

Tra tutti gli *eNodeB candidati* scegliamo quello con il *segnale migliore* facendo una *cell selection*. Alcune *metriche* per capire la cella migliore sono la potenza di trasmissione dell'UE (il mio raggio di copertura) e la potenza del segnale che riceviamo dall'eNodeB.

#align(center)[
  #image("assets/12/collegamento_02.png", width: 70%)
]

Come vediamo, non abbiamo ancora contattato nessuno.

Lo UE inizia quindi la procedura di *contesa* per l'accesso al *Random Access Channel*, ovvero lo scheduling della cella selezionata.

Dopo la *RRC Connection Setup*, in cui configuriamo i due livelli più bassi dello stack, siamo ufficialmente connessi all'eNodeB, ma non abbiamo ancora parlato con la *rete core*.

#align(center)[
  #image("assets/12/collegamento_03.png", width: 70%)
]

Con la *procedura di attachment* ci attacchiamo ad un MME, che ci rende trovabili tramite paging e abilitati per l'handover.

#align(center)[
  #image("assets/12/collegamento_04.png", width: 70%)
]

Se rimaniamo inattivi per un po' di tempo possiamo andare in *idle*, ma mantenendo ancora il *Mobility Management*, ovvero si riesce sempre ad avere traccia della nostra posizione, lasciamo solo i *RB* ad altri.

#align(center)[
  #image("assets/12/collegamento_05.png", width: 70%)
]

// Slide 129 LTE.pdf
