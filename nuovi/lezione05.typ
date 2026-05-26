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
// Slide 42 02_bluetooth.pdf

= Lezione 05 [02/02]

// Inizio 03_zigbee.pdf

== Low-rate WPAN

Vediamo un altro pezzo delle *WPAN*, quindi quelle tecnologie sotto al *protocollo* $802.15$. In particolare vedremo l'ambito *low-rate*, con il protocollo $802.15.4$.

=== ZigBee

Nel protocollo $802.15.4$ abbiamo diverse tecnologie, tra cui *ZigBee*. Di questa tecnologia ci occuperemo quasi principalmente del *modulo MAC*.

I *requisiti* di ZigBee sono molto stringenti:
+ *affidabilità* e *basso* -- anzi bassissimo -- *costo*;
+ *lunga durata* della batteria;
+ *bassa complessità*;
+ utilizzare le *bande ISM*;
+ *scalabilità* su un alto numero di nodi;
+ interoperabilità tra vendors, ovvero non vogliamo essere vincolati al costruttori. Siamo compliant allo standard e quindi siamo in grado di comunicare;
+ *sicurezza*, ma noi non guardiamo questa parte.

// Scrivi altro
ZigBee viene utilizzato molto in ambiti come la *domotica*, il *controllo industriale* e le attuazioni dei processi industriali.

Le *topologie di rete* possibili sono ancora quella *a stella* (come Bluetooth e BLE), ma anche ad *albero* (per favore basta alberi, non ne posso più) e a *mesh*.

Possiamo classificare i nodi in base alle *funzioni* a loro disposizione oppure in base al loro *ruolo* nella rete.

Dividiamo i nodi in due gruppi, basandoci sulle *funzioni* che possono fare:
+ i *Full Function Device* (FFD), che sono spesso i coordinatori e i router della rete, e hanno a loro disposizione tutte le funzioni possibili;
+ i *Reduced Function Device* (RFD), che sono spesso gli end-point della rete, e posseggono solo le funzioni minime per eseguire il loro lavoro.

Dividiamo invece i nodi in tre gruppi, basandoci sul *ruolo* che hanno nella rete:
+ *coordinator* (PAN coordinator), che è un FFD, *unico* nella rete, che crea lui e di cui mantiene tutte le informazioni, come le chiavi di sicurezza;
+ *router*, anche lui un FFD, che ha la capacità di inoltrare i dati tra i vari dispositivi ZigBee;
+ *end device*, che sono invece RFD, e possono solo parlare con il router/coordinatore. Sono dispositivi a *bassa complessità* ed *elevato risparmio energetico*, visto che sono ridotti all'osso in termini di complessità.

Possiamo mandare tre tipi di dati:
+ *periodici*, usati spesso dai sensori, in cui abbiamo un intervallo di trasmissione fissato;
+ *intermittenti*, usati ad esempio dagli interruttori, sono *asincroni* e avvengono tramite stimoli esterni o applicazioni;
+ *ripetitivi e a bassa latenza*, usati dalle periferiche, in cui si hanno time slot prefissati per comunicare.

==== Architettura

Vediamo l'architettura del protocollo ZigBee.

#align(center)[
  #image("assets/05/zigbee.png")
]

I due blocchi inferiori, che sono quello fisico e MAC, sono *sempre presenti* in ogni dispositivo ZigBee.

Sopra poi abbiamo i blocchi azzurri, che sono decisi dalla Alliance dei produttori, mentre i blocchi rossi sono le applicazioni scritte singolarmente dai produttori.

==== Livello fisico

Il *livello fisico* ha a disposizione tre bande diverse. Ogni banda ha un proprio *numero di canali*, tipo di *DSSS*, *modulazione*, symbol rate e *data rate*, che nel migliore dei casi è di $250"k"bps$.

==== Livello MAC

Il *livello MAC* ha diverse responsabilità:
+ gestire l'invio dei *beacon* (coordinator);
+ *sincronizzazione* con i beacon del coordinatore (router e end device);
+ *associazione/dissociazione* tramite beacon;
+ accesso al canale tramite *CSMA/CA*;
+ gestire il MAC address;
+ gestire le trasmissioni dirette dispositivo-coordinatore oppure indirette coordinatore-dispositivi (tipo broadcast);
+ gestire il *duty-cycle* del dispositivo.

I *beacon* sono dei pacchetti importantissimi per la gestione della rete.

CSMA/CA è la politica *Carrier Sense Multiple Access* con *Collision Avoidance*, in cui noi ascoltiamo il canale prima di trasmettere per evitare delle collisioni.

Il *duty-cycle* è una tecnica di *risparmio di batteria*, in cui noi teniamo spenta la radio in ricezione per risparmiare la batteria. Avremo quindi dei periodi di accensione e spegnimento: più stiamo spenti e meno stiamo accesi e più risparmiamo, mentre con la soluzione opposta abbiamo un dispendio energetico più alto.

Il trasferimento dei dati avviene in due modalità:
+ *slotted* (CHIEDE ALL'ESAME), con l'ausilio dei beacon;
+ *unslotted* (NON CHIESTA), che invece usa il bacon.

===== Slotted

In modalità *slotted CSMA/CA* il coordinatore invia periodicamente dei *beacon* per:
+ sincronizzare gli altri dispositivi;
+ organizzare i periodi di trasmissione per le diverse tipologie di trasmissione;
+ gestire la *trasmissione indiretta* (permette ai dispositivi di ascoltare solo quando hanno dei frame che gli interessano).

Il *superframe* è il "pacchetto dati" che va da un beacon al successivo.

#align(center)[
  #image("assets/05/superframe.png", width: 70%)
]

La prima divisione è tra la *parte attiva* e quella *inattiva*: in quest'ultima non avviene la comunicazione, e tutti i dispositivi spengono la radio per risparmiare batteria.

La *parte attiva* viene divisa in altre due parti:
+ *Contention Access Period* (CAP);
+ *Guaranteed Time Slot* (GTS), in cui avviene il *Contention Free Period* (CFP).

Questo periodo di parte attiva è diviso in $16$ slot. In CFP ci sono da $0$ a $7$ *time slot garantiti* alla comunicazione senza dover eseguire Carrier Sense. In CAP invece abbiamo l'uso del Carrier Sense per comunicare. Infatti, tutti i dispositivi sono in contesa, ovvero competono per accedere agli slot temporali.

Le durate delle varie parti sono indicate nel beacon. Come le possiamo calcolare?

La *aBaseSuperframeDuration* (BSD) è l'unità fondamentale della trasmissione, ed è pari a $960$ simboli. La *parte attiva* dipende da questo valore, ed è $aBSD dot 2^SO$, dove *SO* è il *Superframe Order*.

Il *beacon interval* (BI) è il periodo tra due beacon, ed è $aBSD dot 2^BO$, dove *BO* è il *Beacon Order*.

Il *duty-cycle* è il rapporto tra queste due grandezze, ovvero $ DC = frac(2^SO, 2^BO) . $

Come vediamo, il *beacon* si trova prima del superframe, e permette di *sincronizzare* i nodi della rete, *identificare* la PAN e indicare la struttura del *superframe*.

Il beacon è a tutti gli effetti un *frame MAC*.

#align(center)[
  #image("assets/05/beacon.png", width: 70%)
]

Questo pacchetto contiene diversi valori importanti, come il *beacon SEQN*, la *source PAN ID* (ID della rete) e il *source address* di chi sta trasmettendo.

Il pezzo più importante è il *superframe specification*, messo nel *payload*. È formato da una serie di campi *fondamentali* per conoscere la durata di un superframe:
+ *Beacon Order*, di $4$ bit;
+ *Superframe Order*, di $4$ bit;
+ *Final CAP Slot*, di $4$ bit, che indica quale è l'ultimo slot che viene usato in CAP.

Vediamo come avviene la *comunicazione* con un esempio. Per fare ciò ci servono alcune cose:
+ *variabile NumeroBackoff* (NB), che inizia da $0$ e incrementa di $1$ ogni volta che il canale è occupato, con un valore massimo di $4$;
+ *variabile BackoffExponent* (BE), che ha un valore massimo di $5$ e indica il range del *periodo di backoff* $[0, 2^(BE) - 1]$;
+ *variabile ContentionWindow* (CW), che indica il numero di slot liberi consecutivi necessari da avere prima di poter trasmettere;
+ *metodo ClearChannelAssessment* (CCA), un metodo del livello fisico che fa Carrier Sense di $8$ simboli e ritorna True se il canale è libero, False altrimenti.

Prima vediamo una *comunicazione con successo*.

#example([Trasmissione con successo])[
  Partiamo con $ NB = 0 quad bar quad BE = 3 quad bar quad CW = 2 . $

  #align(center)[
    #image("assets/05/successo_01.png")
  ]

  Scegliamo un numero casuale in $[0,7]$, ed effettuiamo due CCA, che ci ritornano True entrambi, quindi azzeriamo CW. Per semplicità abbiamo fatto ciò: nella realtà i due CCA sono consecutivi e CW diventa prima uno e poi zero.

  #align(center)[
    #image("assets/05/successo_02.png")
  ]

  Ora che abbiamo la certezza che nessuno sta comunicando possiamo iniziare a spedire i nostri dati.
]

Mentre ora vediamo una *comunicazione con canale occupato*.

#example([Trasmissione con canale occupato])[
  Partiamo con $ NB = 0 quad bar quad BE = 3 quad bar quad CW = 2 . $

  #align(center)[
    #image("assets/05/occupato.png")
  ]

  In questo caso, dopo il backoff abbiamo un *CCA negativo*. In questo dobbiamo *aumentare* NB di uno, ma anche BE perché non sono da solo, ci sono *altri dispositivi*, quindi fare collisioni è più probabile, e vogliamo scegliere tra più numeri random. In questo periodo di attesa ovviamente la *radio è spenta*, anche nell'esempio precedente.

  Dopo $4$ tentativi fallimentari il livello MAC dichiara *failure*.

  Il *backoff* è *fondamentale*: essendo tutti allineati al beacon dobbiamo avere un modo per differenziarci.
]

Se il numero di *contention slot* che devo aspettare *eccede* il numero di *contention slot rimanenti*, al giro successivo il conteggio riparte dal valore con il quale abbiamo smesso di contare al superframe precedente.

Facciamo la stessa cosa anche se ci accorgiamo che non facciamo in tempo a *trasmettere tutti i dati* nei contention slot rimanenti.

#align(center)[
  #image("assets/05/trasmissione.png", width: 70%)
]

Infatti, tutta la comunicazione ha come *tempo totale*:
+ il tempo dei *dati*;
+ il tempo di *turnaround*, nel quale dobbiamo invertire l'antenna;
+ il tempo per l'*ACK*;
+ il tempo LIFS, tra un frame e l'altro.

Se non riusciamo a stare in questo tempo dobbiamo aspettare il superframe successivo.

===== Unslotted

Nel caso *unslotted* invece non usiamo i *beacon*, quindi i dispositivi accedono con CSMA/CA senza vincoli di slot. Ovviamente, non abbiamo *sincronizzazione* e il tempo diventa continuo (e non più discreto).

Inoltre, il controller è *sempre acceso*, ma per lui è più semplice.

// Slide 28 03_zigbee.pdf
