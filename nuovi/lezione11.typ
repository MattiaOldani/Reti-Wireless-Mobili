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
// Slide 58 06_cellulare.pdf

= Lezione 11 [23/02]

// Inizio 07_LTE.pdf

=== LTE (4G)

Vediamo la rete *Long Term Evolution* (LTE) *$4$G*, che viene resa disponibile nella release $8$.

#align(center)[
  #image("assets/11/LTE.png", width: 70%)
]

Come vediamo, non cambiamo molto architetturalmente parlando: vediamo solo una fusione di *NodeB* e *RNC* in una unica *entità eNodeB* e un cambio di nome di alcuni *gateway*. Inoltre, qua si fa solo *hard handover*.

Vediamo le *differenze* principali tra *$3$G* e *$4$G*.

#align(center)[
  #image("assets/11/differenze.png", width: 70%)
]

Prima i moduli potevano essere sia controllo che dati, mentre ora abbiamo una *separazione netta*, con moduli che fanno solo dati o solo controllo. In *$5$G* vedremo che questa cosa sarà super esagerata.

Vediamo la *divisione logica* di questa *architettura* e andiamo a studiarla.

#align(center)[
  #image("assets/11/architettura.png", width: 70%)
]

Il blocco di sinistra è la *Evolved UTRAN* (E-UTRAN), il blocco centrale è la *rete di backhaul* (connessione tra BS e rete core) e il blocco di destra è la *rete core*.

==== Rete Core

Partiamo con la *rete core*. Il blocco per ora più semplice è quello dei *servizi operatore*, che sono esterni alla rete.

===== MME

La *Mobile Management Entity* (MME) è un nodo che si occupa del solo *traffico di controllo*, quindi *NAS*, e gestisce:
+ contesto dell'*User Equipment* (UE) tramite operazioni NAS;
+ *bearer*, come controllo, autorizzazione, creazione, mantenimento, distruzione, eccetera;
+ *mobilità* all'intero della tracking area;
+ *paging*
+ aspetti di sicurezza e cifratura.

===== HSS

L'*Home Subscribe Server* (HSS) contiene le informazioni dell'utente e dell'abbonamento, come una sorta di database. Per essere precisi contiene:
+ profili di QoS ammessi;
+ restrizioni roaming;
+ informazioni *APN*, ovvero gli IP dei singoli *PDNGW*;
+ identità dell'MME a cui un UE è registrato.

===== PDNGW

Il *Packed Data Network Gateway* (PDNGW) è il ponte verso il mondo esterno, che:
+ assegna un IP ad ogni UE;
+ garantisce le *QoS policy*;
+ filtra i pacchetti *IP DL* in bearer differenti;
+ gestisce la mobilità tra reti non-$3$GPP.

===== SGW

Il *Serving Gateway* (SGW) gestisce il *traffico user plane*. In particolare:
+ gestisce tutti i pacchetti nella rete dell'operatore;
+ fa da *àncora mobile* quando si è in handover;
+ *bufferizza* quando un UE è in IDLE-CONNECTED.

===== PCRF

Il *Policy Control and Charging Rules Function* (PCRF) svolge:
+ controllo e autorizzazione di singoli flussi a livello PGW;
+ autorizza i QoS secondo i profili utenti dall'HSS.

==== E-UTRAN

Nel *E-UTRAN* abbiamo solo la *BS*, che è detta *eNodeB*. Questa dà connessione agli UE e li collega alla rete network, quindi fa sia controllo che dati.

In particolare, deve:
+ gestire le risorse radio e l'accesso al canale tramite OFDMA;
+ fare compressione delle risorse radio;
+ fare connessione con SGW e MME per traffico dati e controllo;
+ dare informazioni posizione UE;
+ dare sicurezza e crittografia al canale radio.

===== Trasmissione

Siamo nella *E-UTRAN*, vediamo come avviene la *trasmissione* con *QPSK*.

#align(center)[
  #image("assets/11/trasmissione_QPSK.png", width: 70%)
]

Come vediamo, dopo essere passati *dai bit ai simboli*, guardiamo la costellazione e moduliamo su una *frequenza intermedia IF* di OFDMA, con tutte le sue sotto-portanti. Infine, dopo il *Digital to Analog Converter* (DAC) portiamo tutto in banda traslata e trasmettiamo.

Vediamo ora la fase di *ricezione*, che sicuramente vedrà un'onda distorta visto il rumore termico e lo sfasamento indotto dalla mobilità $psi$.

#align(center)[
  #image("assets/11/ricezione_QPSK.png", width: 70%)
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
  #image("assets/11/CQI.png", width: 70%)
]

In questa tabella vediamo il *Channel Quality Index*, che ci indica, in base a quanto è buono il canale stimato, che modulazione usare con anche il coding rate.

===== Resource Block

Anche in *LTE* andiamo a *riusare tutte le frequenze*, ma la gestione è più semplice perché con l'*interfaccia X$2$* abbiamo una comunicazione apposita tra BS.

Un *simbolo* in LTE dura $66.7micros$, che è molto più grande di WiFi visto l'effetto *multipath-fading* molto più accentuato.

La BS organizza le risorse fisiche in slot da $0.5millis$. Ogni *slot* è formato da $6 slash 7$ simboli, in base al *prefisso ciclico*, che viene aggiunto per evitare la sovrapposizione tra simboli.

In particolare, nel *Normal Cyclic Prefix* abbiamo $7$ simboli e un prefisso ciclico breve, mentre nell'*Extended Cyclic Prefix* abbiamo $6$ simboli ma con un prefisso ciclico molto più esteso per via dell'area più estesa che dobbiamo coprire.

Il *duplex* può scegliere se fare *FDD* o *TDD*.

In particolare, in *TDD* abbiamo diverse *configurazioni*, che sono annunciate dalla *BS*, con cui quest'ultima andrà a parlare con gli UE.

#align(center)[
  #image("assets/11/TDD.png", width: 70%)
]

// chiedere
Viene aggiunto un *periodo di guardia* dopo ogni DL e un inizio di UL per permette l'*Uplink Timing Advance*.

Infatti, può avvenire che un dispositivo lontano inizi a trasmettere sforando il prefisso ciclico. Viene quindi detto dalla BS di *quanto anticipare* la trasmissione per arrivare in tempo con la trasmissione. Inoltre, visto questo anticipo abbiamo anche un periodo di vuoto della BS così da evitare l'*interferenza*.

#align(center)[
  #image("assets/11/advance.png", width: 70%)
]

Definiamo ora le *risorse minime* che possiamo dare agli utenti.

I *Resource Block* sono come le RU di WiFi$6$, ma qui siamo più *flessibili*, visto che dobbiamo garantire *flessibilità di sistema*.

Usiamo *OFDMA*, dividendo la banda in sotto-portanti, avendo quindi simboli più lunghi e distanza tra sotto-portanti più bassa. Più sotto-bande sono organizzate in questi *Resource Block*, che sono la minima quantità di risorse allocabili.

Sappiamo benissimo come funziona *OFDMA*, ma qua dobbiamo assegnare le sotto-portanti agli utenti, quindi è un pelo diversa la situazione.

#align(center)[
  #image("assets/11/OFDMA.png", width: 60%)
]

In questo caso in trasmissione ci serve il *resource element mapping*, che mappa i vari dispositivi nelle loro sotto-portanti. In ricezione abbiamo invece il *resource element selection*, che fa una *equalizzazione*, un *filtro*, ottenendo solo le sotto-portanti che ci sono state assegnate.

Ogni *Resource Block* è un blocco di $12$ sotto-bande, ognuna di $7$ simboli. Ogni *eNodeB* deve essere in grado di garantire $6$ *RB* per $10millis$, quindi un totale di $20$ colonne.

Gli *eNodeB* poi hanno uno *scheduler* che sceglie chi allocare e dove.

#align(center)[
  #image("assets/11/RB.png", width: 70%)
]

===== Velocità

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

===== Frequenze

Finiamo la parte *E-UTRAN* vedendo come sono allocate le frequenze in Italia nel $2011$.

#align(center)[
  #image("assets/11/lotti.png", width: 70%)
]

Ognuno di questi lotti è pagato a peso d'oro, visto che si hanno pochi lotti ma ognuno di questo permette una scalabilità immensa.

// Slide 54 07_LTE.pdf
