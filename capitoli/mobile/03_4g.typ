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

= 4G

Vediamo la rete *Long Term Evolution* (LTE) *$4$G*, che viene resa disponibile nella release $8$.

#align(center)[
  #image("assets/03/LTE.png", width: 70%)
]

Come vediamo, non cambiamo molto architetturalmente parlando: vediamo solo una fusione di *NodeB* e *RNC* in una unica *entità eNodeB* e un cambio di nome di alcuni *gateway*. Inoltre, qua si fa solo *hard handover*.

Vediamo le *differenze* principali tra *$3$G* e *$4$G*.

#align(center)[
  #image("assets/03/differenze.png", width: 60%)
]

Prima i moduli potevano essere sia controllo che dati, mentre ora abbiamo una *separazione netta*, con moduli che fanno solo dati o solo controllo.

Vediamo la *divisione logica* di questa *architettura* e andiamo a studiarla.

#align(center)[
  #image("assets/03/architettura.png", width: 70%)
]

Il blocco di sinistra è la *Evolved UTRAN* (E-UTRAN), il blocco centrale è la *rete di backhaul* (connessione tra BS e rete core) e il blocco di destra è la *rete core*.

== Rete Core

Partiamo con la *rete core*. Il blocco per ora più semplice è quello dei *servizi operatore*, che sono esterni alla rete.

La *Mobile Management Entity* (MME) è un nodo che si occupa del solo *traffico di controllo*, quindi *NAS*, e gestisce:
+ contesto dell'*User Equipment* (UE) tramite operazioni NAS;
+ *bearer*, come controllo, autorizzazione, creazione, mantenimento, distruzione, eccetera;
+ *mobilità* all'intero della tracking area;
+ *paging*
+ aspetti di sicurezza e cifratura.

L'*Home Subscribe Server* (HSS) contiene le informazioni dell'utente e dell'abbonamento, come una sorta di database. Per essere precisi contiene:
+ profili di QoS ammessi;
+ restrizioni roaming;
+ informazioni *APN*, ovvero gli IP dei singoli *PDNGW*;
+ identità dell'MME a cui un UE è registrato.

Il *Packed Data Network Gateway* (PDNGW) è il ponte verso il mondo esterno, che:
+ assegna un IP ad ogni UE;
+ garantisce le *QoS policy*;
+ filtra i pacchetti *IP DL* in bearer differenti;
+ gestisce la mobilità tra reti non-$3$GPP.

Il *Serving Gateway* (SGW) gestisce il *traffico user plane*. In particolare:
+ gestisce tutti i pacchetti nella rete dell'operatore;
+ fa da *àncora mobile* quando si è in handover;
+ *bufferizza* quando un UE è in IDLE-CONNECTED.

Il *Policy Control and Charging Rules Function* (PCRF) svolge:
+ controllo e autorizzazione di singoli flussi a livello PGW;
+ autorizza i QoS secondo i profili utenti dall'HSS.

== E-UTRAN

Nel *E-UTRAN* abbiamo solo la *BS*, che è detta *eNodeB*. Questa dà connessione agli UE e li collega alla rete network, quindi fa sia controllo che dati.

In particolare, deve:
+ gestire le risorse radio e l'accesso al canale tramite OFDMA;
+ fare compressione delle risorse radio;
+ fare connessione con SGW e MME per traffico dati e controllo;
+ dare informazioni posizione UE;
+ dare sicurezza e crittografia al canale radio.

=== Trasmissione

Siamo nella *E-UTRAN*, vediamo come avviene la *trasmissione* con *QPSK*.

#align(center)[
  #image("assets/03/trasmissione_QPSK.png", width: 70%)
]

Come vediamo, dopo essere passati *dai bit ai simboli*, guardiamo la costellazione e moduliamo su una *frequenza intermedia IF* di OFDMA, con tutte le sue sotto-portanti. Infine, dopo il *Digital to Analog Converter* (DAC) portiamo tutto in banda traslata e trasmettiamo.

Vediamo ora la fase di *ricezione*, che sicuramente vedrà un'onda distorta visto il rumore termico e lo sfasamento indotto dalla mobilità $psi$.

#align(center)[
  #image("assets/03/ricezione_QPSK.png", width: 70%)
]

In questo caso torniamo in banda base, filtriamo per rimuovere il rumore e convertiamo con l'*Analog to Digital Converter* (ADC). A questo punto non abbiamo la fase $phi.alt$ trasmessa ma $phi.alt + psi$ che è distorta.

Quello che facciamo è una *channel estimation* tramite *pilot*, che essendo segnali standard possono essere confrontati e usati per capire il fattore di errore da togliere come fase.

Avviene poi la trasformazione da simboli a bit e il gioco è fatto.

Questa soluzione di *channel estimation* è usata anche per capire se si deve fare o meno un *handover*.

Nella rete E-UTRAN si usano quattro diverse modulazioni:
+ *BPSK* (binary), usata per segnali a basso livello mandati dalla BS per comunicare come funziona la BS stessa, il duplex, eccetera. Infatti, devono essere *facilmente decodificabili* anche a fronte di un canale pessimo;
+ *QPSK* (quadrature), usata per controllo e trasmissione se abbiamo scarsa qualità del segnale;
+ *$16$/$64$-QAM*, usata per la trasmissione dati.

#align(center)[
  #image("assets/03/CQI.png", width: 65%)
]

In questa tabella vediamo il *Channel Quality Index*, che ci indica, in base a quanto è buono il canale stimato, che modulazione usare con anche il coding rate.

=== Resource Block

Anche in *LTE* andiamo a *riusare tutte le frequenze*, ma la gestione è più semplice perché con l'*interfaccia X$2$* abbiamo una comunicazione apposita tra BS.

Un *simbolo* in LTE dura $66.7micros$, che è molto più grande di WiFi visto l'effetto *multipath-fading* molto più accentuato. La BS organizza le risorse fisiche in slot da $0.5millis$. Ogni *slot* è formato da $6 slash 7$ simboli, in base al *prefisso ciclico*, che viene aggiunto per evitare la sovrapposizione tra simboli.

In particolare, nel *Normal Cyclic Prefix* abbiamo $7$ simboli e un prefisso ciclico breve, mentre nell'*Extended Cyclic Prefix* abbiamo $6$ simboli ma con un prefisso ciclico molto più esteso per via dell'area più estesa che dobbiamo coprire.

Il *duplex* può scegliere se fare *FDD* o *TDD*. In particolare, in *TDD* abbiamo diverse *configurazioni*, che sono annunciate dalla *BS*, con cui quest'ultima andrà a parlare con gli UE.

#align(center)[
  #image("assets/03/TDD.png", width: 60%)
]

Viene aggiunto un *periodo di guardia* dopo ogni DL e un inizio di UL per permette l'*Uplink Timing Advance*.

Infatti, può avvenire che un dispositivo lontano inizi a trasmettere sforando il prefisso ciclico. Viene quindi detto dalla BS di *quanto anticipare* la trasmissione per arrivare in tempo con la trasmissione. Inoltre, visto questo anticipo abbiamo anche un periodo di vuoto della BS così da evitare l'*interferenza*.

#align(center)[
  #image("assets/03/advance.png", width: 70%)
]

Definiamo ora le *risorse minime* che possiamo dare agli utenti.

I *Resource Block* sono come le RU di WiFi$6$, ma qui siamo più *flessibili*, visto che dobbiamo garantire *flessibilità di sistema*.

Usiamo *OFDMA*, dividendo la banda in sotto-portanti, avendo quindi simboli più lunghi e distanza tra sotto-portanti più bassa. Più sotto-bande sono organizzate in questi *Resource Block*, che sono la minima quantità di risorse allocabili.

Sappiamo benissimo come funziona *OFDMA*, ma qua dobbiamo assegnare le sotto-portanti agli utenti, quindi è un pelo diversa la situazione.

#align(center)[
  #image("assets/03/OFDMA.png", width: 60%)
]

In questo caso in trasmissione ci serve il *resource element mapping*, che mappa i vari dispositivi nelle loro sotto-portanti. In ricezione abbiamo invece il *resource element selection*, che fa una *equalizzazione*, un *filtro*, ottenendo solo le sotto-portanti che ci sono state assegnate.

Ogni *Resource Block* è un blocco di $12$ sotto-bande, ognuna di $7$ simboli. Ogni *eNodeB* deve essere in grado di garantire $6$ *RB* per $10millis$, quindi un totale di $20$ colonne.

Gli *eNodeB* poi hanno uno *scheduler* che sceglie chi allocare e dove.

#align(center)[
  #image("assets/03/RB.png", width: 70%)
]

La *velocità* che offre la rete LTE dipende da molti fattori:
+ capacità del dispositivo;
+ qualità del segnale radio, che determina la codifica;
+ larghezza della banda, che determina il numero di RB;
+ configurazione del TDD;
+ numero di dispositivi collegati;
+ congestione delle rete backhaul e dei PGW.

Le massime velocità teoriche sono:
+ $300"M"bps$ in *download*;
+ $75"M"bps$ in *upload*.

=== Frequenze

Finiamo la parte *E-UTRAN* vedendo come sono allocate le frequenze in Italia nel $2011$.

#align(center)[
  #image("assets/03/lotti.png", width: 70%)
]

Ognuno di questi lotti è pagato a peso d'oro, visto che si hanno pochi lotti ma ognuno di questo permette una scalabilità immensa.

== Architettura

Abbandoniamo il livello fisico e vediamo in generale l'*architettura* della rete RAN, che *interfacce* ci sono e che *protocolli* hanno a bordo i dispositivi.

#align(center)[
  #image("assets/03/interfacce.png", width: 50%)
]

In questa *architettura* i "fili" sono *interfacce logiche*, sulle quali abbiamo dei *protocolli* specifici che ci dicono cosa può viaggiare.

Le linee tratteggiate ci collegano alla rete core tramite *interfaccia S$1$*, mentre le linee continua permettono agli eNodeB di *parlare tra loro* senza interpellare la rete core usando il *protocollo X$2$*.

Infatti, questa è una innovazione di LTE, che permette ai eNodeB di fare *auto config*, gestire l'*handover* e regolare la *potenza di trasmissione*.

Ovviamente, sono *connessioni logiche*, quindi possono essere *realizzate* in vari modi, usando ponti radio oppure usando la fibra verso la rete IP classica.

=== Tracking area

Gli *eNodeB* sono raggruppati in aree geografiche, e ogni eNodeB viene gestito da un *pool di MME*, che sono nodi di rete core che permettono di fare load balancing e fault tolerance.

#align(center)[
  #image("assets/03/tracking.png", width: 70%)
]

Queste aree geografiche sono le *tracking area*: abbiamo gruppi di SGW e MME che gestiscono le varie aree, tramite *associazione dinamica*, permettendo di fare del *load balancing* (gestione del carico di rete) e *fault tolerance* (se un MME cade ci sono altri a coprirlo).

=== Interfaccia X2

L'*interfaccia X$2$* permette la *comunicazione diretta tra eNodeB*, e questo ci permette di:
+ gestire l'*handover* in alternativa al protocollo S$1$;
+ avere le *Self-Organizing Network* (SON) facendo load balancing e gestione delle interferenze (potenza di trasmissione);
+ mantenere uno *storico* delle ultime celle visitate per gestire l'effetto ping-pong tra le celle, negando l'handover se uno zio vuole fare troppi handover di fila.

=== Architettura densa

Purtroppo, quando vediamo il link dalla rete E-UTRAN alla rete core, questo non è un *semplice hop* ma è un percorso ben più complicato.

#align(center)[
  #image("assets/03/delay.png", width: 70%)
]

Come vediamo, noi siamo in basso a sinistra con la *rete E-UTRAN*, ma per arrivare alla *rete core* in basso a destra dobbiamo passare per un sacco di reti, che magari sono pure intasate.

Quindi, ovviamente, abbiamo molto *delay* e non un singolo hop come di solito facciamo vedere.

=== Control Plane

Vediamo come funziona il *Control Plane*.

#align(center)[
  #image("assets/03/control.png", width: 70%)
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

=== SCTP

Diamo un occhio nello specifico al *protocollo SCTP*, e perché è stato scelto questo e non il classico protocollo TCP.

Il *protocollo TCP* non va bene per LTE:
+ ha trasporto affidabile e in ordine, ma non la consegna solo affidabile e l'ordine parziale;
+ *Head of Line Blocking Problem*;
+ è *stream-oriented* e usa dei marker per delimitare i messaggi;
+ manca il *Multi-Homing*, ovvero la quadrupla (IP IP porta porta) non ci copre se un MME cade o cambia IP.

L'*HOL Blocking Problem* lo abbiamo quando dobbiamo spedire dei pacchetti. Uno dei primi viene perso e tutti quelli dopo sono bloccati nel buffer perché TCP deve aspettare per ritrasmettere.

Questo è un problema in LTE perché supponiamo di avere diversi messaggi di controllo che arrivano all'eNodeB e devono essere inoltrati all'MME. Se perdiamo un blocco di uno dei messaggi iniziali tutti gli altri non saranno processati, anche se appartengono a *dispositivi diversi* e sono totalmente ok.

#align(center)[
  #image("assets/03/HOL_01.png", width: 70%)
]

Una possibile soluzione è creare *più connessioni TCP* tra eNodeB e MME, togliendo il delay che avevamo poco fa, ma questo non scala per niente visto che ci servono tantissime risorse.

#align(center)[
  #image("assets/03/HOL_02.png", width: 70%)
]

La soluzione che usa *SCTP* è quella che usano anche HTTP/$2$ e Quick, ovvero si aumenta leggermente l'*overhead* dell'header aggiungendo uno *stream ID*. Con questa noi abbiamo un *unico flusso SCTP* ma i pacchetti sono *taggati*, quindi anche se viene perso qualcosa viene bloccato solo quel flusso e non tutti gli altri.

Questo ovviamente introduce un *ordine parziale* nei pacchetti.

SCTP ci permette anche di avere un *pool di IP sorgente* e un *pool di IP destinazione*, visto che abbiamo un pool di MME che gestisce la nostra tracking area. Inoltre, questo ci permette la fault tolerance e il load balancing: visto che possiamo mandare i pacchetti su più path, sfruttiamo questo per parallelizzare l'invio dei pacchetti, tanto sono numerati.

Finiamo con l'ultima differenza tra SCTP e TCP.

In *TCP* abbiamo uno *stream*, ed è compito dell'applicazione delimitare i vari messaggi. Con "delimitare" intendiamo che in un blocco dati possiamo avere i dati di più messaggi, per questo il marker è fondamentale.

#align(center)[
  #image("assets/03/TCP.png", width: 60%)
]

Noi vogliamo eliminare il marker per evitare il parsing.

Sfruttiamo quello che fa *UDP*: ogni blocco dati è riferito ad un *messaggio solo*, quindi non serve nessun marker e nessuna divisione, è SCTP che assembla e riassembla.

#align(center)[
  #image("assets/03/SCTP.png", width: 60%)
]

Vediamo, per riassumere, le *differenze* tra TCP e SCTP.

#align(center)[
  #image("assets/03/ddifferenze.png", width: 60%)
]

Come vediamo, siamo sia *connection-oriented* che *message-oriented*, con una serie di qualità ottime a fare da contorno al protocollo.

=== User Plane

Passiamo ora allo *User Plane*, in cui ci sono ancora UE ed eNodeB.

#align(center)[
  #image("assets/03/data.png", width: 70%)
]

In questo caso riconosciamo molti più protocolli di prima. Rimangono *PDCP* e *RLC* per il controllo errori, ma scompare *RRC* per lasciare spazio al solo *IP* con sopra la classica parte ISO/OSI. Inoltre, viene usato *UDP* e *GTP-U*, che riprendiamo dopo.

Come vediamo, tra UE ed eNodeB siamo identici, mentre tra *eNodeB* e i vari *gateway* abbiamo qualcosa di diverso.

Dal *server* in poi abbiamo il mondo esterno, che dialoga direttamente con la parte client dell'UE in maniera *end-to-end*.

Nell'architettura abbiamo *tre livelli IP* diversi:
+ *tra UE e PGW* abbiamo indirizzi *IP interni*, assegnati da NAT e DHCP, quindi non riguardano il servizio dell'operatore;
+ *tra PGW e server* abbiamo *indirizzi IP pubblici dell'operatore mobile*, ovvero del servizio che viene offerto;
+ *tra eNodeB e gateway* abbiamo *indirizzi IP interni* che usiamo per fare routing.

Dentro la rete usiamo *GTP-User Plane* (GPT-U), che abbiamo visto l'altra volta, ma riprendiamo velocemente perché ho voglia di rifarlo.

Abbiamo un UE che ha una *Packet Data Network Session* (PDN Session), ovvero un collegamento con il PGW che deve essere mantenuto anche se l'UE si muove. In questa sessione, quando ci spostiamo, dovremmo ogni volta modificare le tabelle di routing che abbiamo tra l'UE e il PGW, facendo *overhead di controllo* se cambiamo continuamente l'eNodeB a cui siamo agganciati.

*GTP* inizia proprio all'*uscita di un eNodeB* verso la rete core.

#align(center)[
  #image("assets/03/GTP.png", width: 70%)
]

Come vediamo, andiamo ad impacchettare il pacchetto utente in un *pacchetto GTP*, che incapsula appunto il messaggio con l'IP del SGW, la porta UDP usata e il *Tunnel Endpoint ID* (TEID).

Grazie a questo escamotage le tabelle interne dei vari *router* sono *fisse*, non cambiano mai e quindi tutto quello che fa l'UE non va a modificare la struttura interna della rete.

Quando arriviamo al PGW, dopo molteplici incapsulamenti e decapsulamenti, abbiamo solo il *pacchetto utente inalterato*. Questo vale in uplink e in downlink.

Questo *overhead* di header è bassissimo considerando la *mobilità utente*: cambiamo spesso gli eNodeB, ma le tabelle di routing dentro la rete rimangono fisse.

== Bearer

In LTE possiamo definire la *QoS* tramite i *Bearer*, dei canali radio che trasportano dati con una QoS ben definita. La QoS viene definita *tra l'UE e il PGW* tramite *Evolved Packet Switch Bearer* (EPS Bearer), che viene però diviso in vari pezzi seguendo la divisione dell'architettura.

#align(center)[
  #image("assets/03/bearer.png", width: 60%)
]

Dobbiamo essere in grado di *bilanciare* le varie parti per ottenere al massimo il delay richiesto dall'utente.

Ogni *UE* può avere al massimo $8$ *bearer attivi*. Ogni UE ne ha sempre almeno uno, il *default bearer*, che viene creato dal PGW quando ci colleghiamo alla rete. Ogni bearer ha un *IP differente*.

Gli UE possono avere più *default bearer attivi*.

I *dedicated bearer* sono dei "*fork*" sul default bearer, in cui prendiamo l'IP del bearer da cui siamo generati. Siamo inoltre connessi allo stesso PGW, ma possiamo definire una *diversa QoS*.

Possiamo connetterci ad *altri PGW*, creando quindi altri default bearer, da cui possiamo derivare altri dedicated bearer.

#align(center)[
  #image("assets/03/molti_bearer.png", width: 90%)
]

Tra default e dedicated possiamo avere al massimo $8$ canali attivi.

Vediamo la tabella delle varie *QoS*.

#align(center)[
  #image("assets/03/QCI.png")
]

Questa tabella contiene i *Quality of Service Class Identifiers* (QCI), che sono ID che si riferiscono ad alcune classi di servizio ben definite. Ci sono quattro *parametri* che definiscono una QoS:
+ *Minimum Guaranteed Bit Rate* (GBR), ovvero quello che la rete si impegna a darmi, ovviamente se ne ha le possibilità;
+ *priorità*, usato dalle code con priorità per lo scheduling;
+ *Packet Delay Budget* (PDB) in millisecondi, che indica il delay massimo che vogliamo avere tra l'UE e il PGW;
+ *Packet Error Loss Rate* (PELR), che è la probabilità di avere un errore sui bit trasmessi.

Il traffico viene *mappato sui bearer* tramite *Traffic Flow Template* (TFT), ovvero i dispositivi ricevono i dati con la QoS richiesta e mappano il flusso su uno dei canali che riesce a garantire quanto richiesto. Questo avviene se ovviamente siamo autorizzati, ovvero se abbiamo pagato.

== Collegamento alla rete dell'operatore

Ora vediamo la procedura di *collegamento* alla *rete operatore*.

Quando l'UE viene acceso siamo in:
+ *EMM_DEREGISTERED*, dove EMM sta per *EPS Mobility Management*, e indica che non siamo registrati ad un MME, quindi la nostra mobilità non viene gestita;
+ *ECM_IDLE*, dove ECM sta per *EPS Connection Management*, e indica che la connessione tra UE e MME per il traffico di controllo non è attiva;
+ *RRC_IDLE*, che indica che non siamo connessi ad alcun eNodeB.

#align(center)[
  #image("assets/03/collegamento_01.png", width: 70%)
]

Infatti, la rete RAN *non ci conosce*.

Come prima cosa facciamo *network selection*, in cui ascoltiamo gli eNodeB per capire il loro segnale.

La *Closed Subscriber Group* (CSG) è una lista di client che sono autorizzati all'accesso della *femtocella*, ma questa procedura è opzionale come anche la sua spiegazione in questi appunti.

Tra tutti gli *eNodeB candidati* scegliamo quello con il *segnale migliore* facendo una *cell selection*. Alcune *metriche* per capire la cella migliore sono la potenza di trasmissione dell'UE (il mio raggio di copertura) e la potenza del segnale che riceviamo dall'eNodeB.

#align(center)[
  #image("assets/03/collegamento_02.png", width: 70%)
]

Come vediamo, non abbiamo ancora contattato nessuno.

Lo UE inizia quindi la procedura di *contesa* per l'accesso al *Random Access Channel*, ovvero lo scheduling della cella selezionata.

Dopo la *RRC Connection Setup*, in cui configuriamo i due livelli più bassi dello stack, siamo ufficialmente connessi all'eNodeB, ma non abbiamo ancora parlato con la *rete core*.

#align(center)[
  #image("assets/03/collegamento_03.png", width: 70%)
]

Con la *procedura di attachment* ci attacchiamo ad un MME, che ci rende trovabili tramite paging e abilitati per l'handover.

#align(center)[
  #image("assets/03/collegamento_04.png", width: 70%)
]

Se rimaniamo inattivi per un po' di tempo possiamo andare in *idle*, ma mantenendo ancora il *Mobility Management*, ovvero si riesce sempre ad avere traccia della nostra posizione, lasciamo solo i *RB* ad altri.

#align(center)[
  #image("assets/03/collegamento_05.png", width: 70%)
]

== Handover

In *LTE* avviene solo l'*hard handover*, ovvero non si ha un nodo centralizzato tra gli eNodeB, ma abbiamo due modalità possibili:
+ *seamless*, *senza continuità*, che presenta minore latenza ma ammette delle ritrasmissioni, ed è usato ad esempio nel *traffico VoIP* e *realtime*;
+ *lossless*, *con continuità*, che presenta maggiore latenza ma perché si riduce la perdita dei pacchetti, ed è usato per il *traffico HTTP o FTP*.

L'handover lossless si attiva durante un *flusso in download*, con un uso del *buffer* cruciale per evitare che si perda quello che veniva spedito.

#align(center)[
  #image("assets/03/download.png", width: 50%)
]

In questo caso, si conosce l'eNodeB nuovo che andrà a ricevere il dispositivo, quindi iniziamo a mandare i pacchetti non ancora inviati -- bufferizzati -- a questo eNodeB.

Vediamo però nello specifico come funziona l'*handover*.

=== Interfaccia S1

Partiamo con l'handover su *interfaccia S$1$*.

#align(center)[
  #image("assets/03/s1_handover.png")
]

Si decide che deve avvenire l'*handover* tramite S$1$, quindi mandiamo una handover request al mio MME. La decisione è della rete, l'UE fa ben poco, è tutto a carico dell'eNodeB.

*Inoltriamo* poi la richiesta al nuovo MME, che avrà in carico il traffico di controllo, sempre tramite la S$1$.

Ora dobbiamo dire all'eNodeB nuovo che dovrà tenere in carico l'UE, quindi *inoltriamo* ancora l'*handover request* all'eNodeB. In questo momento conosciamo tutti la situazione attuale, soprattutto gli MME, che tengono al loro interno i *bearer attivi* per ricreare completamente la situazione nel nuovo eNodeB.

Dobbiamo prepararci per accogliere il nuovo UE, quindi facciamo il *setup delle risorse* quali slot, bearer, e tutto quello che serve per tenere il dispositivo. Come conferma all'MME nuovo mandiamo un *ack*.

Siamo pronti per ricevere, quindi facciamo avvenire l'handover: avvisiamo l'MME vecchio che siamo pronti, e lui manda all'eNodeB vecchio l'*handover command*.

In questo momento parliamo finalmente con l'*UE*, che viene avvisato dell'handover. Nel mentre che questo UE si sistema, il vecchio eNodeB ha finito il suo lavoro, e deve solo dire alla sua rete core MME di emettere un *eNodeB status transfer*, e inoltrare i dati al nuovo eNodeB se siamo nel caso *lossless*.

Un messaggio simile è l'*MME status transfer*, dal nuovo MME al nuovo eNodeB per dire che l'MME ora gestisce quel dispositivo.

Quando l'UE è *pronto per il cambio* deve notificare il nuovo eNodeB tramite una *conferma di handover*.

Infine, ultime notifiche sono l'*handover notify*, dall'eNodeB all'MME, notificando che è andato tutto a buon fine, e due messaggi tra gli MME per confermare (con ack) che le risorse sono state spostate correttamente.

Gli ultimi due messaggi in realtà sono la *Tracking Area Update Request*, che aggiorna la tracking area dell'eNodeB, e la *liberazione delle risorse* nel vecchio eNodeB.

L'handover ovviamente avviene se la rete è sicura che questo può avvenire: se non si hanno le risorse per fare l'handover questo non accade.

=== Interfaccia X2

Vediamo invece l'handover su *interfaccia X$2$*. In questo caso, non dovendo contattare la rete core, si fa tutto tramite scambi di messaggi tra eNodeB.

#align(center)[
  #image("assets/03/x2_handover.png")
]

Dopo una serie di *misure di controllo* i due eNodeB decidono che deve avvenire l'*handover*: prima avviene una *handover request* dall'eNodeB vecchio a quello nuovo, che deve fare un *resource setup* contattando anche l'MME, visto che è anche lui uno che riceve i messaggi.

Si manda poi un *ack* all'eNodeB vecchio per confermare che si è pronti, e come prima si manda l'*handover command* all'UE.

Passiamo quindi il comando all'eNodeB nuovo con uno *status transfer*, con anche l'UE che contatta l'eNodeB nuovo per avvisarlo che ha finito il suo setup ed è pronto con una *handover complete*. In questa fase avviene anche il forwarding dei dati su X$2$ se siamo in lossless.

Si parla ancora con la rete core (in realtà prima volta) per richiedere il *path switch*, che ha un ack di ritorno.

Infine, si ha il rilascio delle risorse nel vecchio eNodeB.
