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
// Slide 29 03_zigbee.pdf

= Lezione 06 [06/02]

== WPAN

=== ZigBee

/*
AGGIUNGI ALLA LEZIONE PRIMA

[SLIDE 18] Riprendiamo la slide

Dopo il superframe specification abbiamo informazioni sugli slot senza contesa:
+ GTS (guaranteed time slot) fields dice quanti campi sono senza contesa
+ pending address field (indirizzi dei dispositivi per cui il coordinatore ha qualcosa da mandare). In questo modo loro ascoltano, altrimenti spengono la radio e fanno duty-cycle

[SLIDE 28] Aggiungi anche qui a quella PRIMA

Unslotted senza beacon, non abbiamo sincronizzazione, quindi router e coordinatore sempre accesi, tempo continuo e non discreto (slot). Unico vincolo sono i quanti dei numeri di simboli, sennò tempo continuo. Controller più semplice, end device non deve leggere beacon, CSMA/CA e poi basta.
*/

Vediamo brevemente il *frame* di ZigBee, anche se non ci serve a niente.

#align(center)[
  #image("assets/06/frame.png", width: 70%)
]

Il *livello di rete* di ZigBee è proprietario di quest'ultimo, ed è responsabile di:
+ gestire *join* e *leave*;
+ gestire l'*indirizzamento* al livello $3$;
+ *sincronizzazione*;
+ routing (anche se abbiamo pochi hop) in reti a stella, albero, mesh e AODV.

Un componente importante è il *ZigBee Device Object*, che definisce il ruolo del dispositivo, scopre nuovi dispositivi con le loro funzionalità e fa da *interfaccia* con le applicazioni proprietarie definite dai manufacturer.

=== Matter e Thread

Matter e Thread sono l'evoluzione e il *nuovo standard* per la domotica.

#align(center)[
  #image("assets/06/matter.png", width: 70%)
]

Come vediamo, a *livello fisico* e *data link* ci basiamo ancora su $802.15.4$, ma vengono modificati quelli superiori.

Thread ai livelli superiori si appoggia a *Matter*, una libreria che tramite *bridge* ci permette di utilizzare altre tecnologie radio, come WiFi, Bluetooth, eccetera.

Vediamo brevemente lo *stack* di Thread.

#align(center)[
  #image("assets/06/thread.png", width: 50%)
]

Come vediamo, abbiamo una parte comune a ZigBee, ma lo stack superiore invece è molto più simile allo stack *UDP/IP*.

La rete viene *espansa* rispetto a ZigBee. Come prima abbiamo una distinzione tra *Full Thread Device* e *Minimal Thread Device*. La distinzione principale si basa però sul *routing*.

I *Routing Full Thread Device* possono essere:
+ *router*, che effettuano routing e forniscono servizi di accesso e sicurezza;
+ *leader*, in grado di eleggere e sostituire i REED.

I *Non-Routing Full Thread Device* possono essere:
+ *REED*, ovvero Router-Eligible End Device, che possono essere eletti a router per creare dei nuovi percorsi;
+ *Full End Device* (FED), che invece non possono essere eletti.

Passando ai minimal, abbiamo i *Non-Routing Minimal Thread Device*, che possono essere:
+ *Minimal End Device* (MED), che comunica solo con il router genitore ed ha la radio sempre attiva;
+ *Sleepy End Device* (SED), che comunica solo con il router genitore e ha duty-cycle;
+ *Synchronized Sleepy End Device* (SSED), che comunica solo con il router genitore e ha duty-cycle schedulati;

Questi sono dispositivi con requisiti hardware minori.

Infine, abbiamo i *Border Router*, che sono *Full Thread Device* che offrono connettività verso altre reti che hanno un *livello fisico diverso*.

#align(center)[
  #image("assets/06/rete.png", width: 50%)
]

In Thread abbiamo anche l'indirizzamento tramite *IPv6*, lo standard *6LoWPAN* con compressione di header e supporto a reti mesh, il *Distance Vector Routing* e il calcolo del costo dei link in maniera variabile tramite *RSSI* (Received Signal Strength Indicator).

// Fine 03_zigbee.pdf
// Inizio 04_wifi.pdf

== WiFi

Passiamo finalmente al *WiFi*. Ora siamo in *WLAN*, non più WPAN.

Il *protocollo* è il $802.11$, e abbiamo una serie di *requisiti* da soddisfare:
+ *throughput* elevato grazie ad un uso efficiente del canale radio;
+ *elevato numero di nodi*, nell'ordine delle centinaia per più celle;
+ *connessione* verso la dorsale cablata (backbone);
+ *raggio di copertura* di $100"-"300$ metri;
+ *utilizzo efficiente della batteria*, ma non estremo come Bluetooth e ZigBee;
+ coesistenza di più WLAN;
+ poter operare sulle *bande unlicensed*;
+ potersi configurare dinamicamente.

In questo standard vedremo due *modalità*:
+ *WiFi* (Wireless Fidelity), in cui abbiamo una backbone alla quale accediamo tramite *Access Point* (AP) e *Point Coordination Function* (PCF). La cella si chiama *Basic Service Set* (BSS);
+ *reti Ad-Hoc*, senza AP con accesso tramite *Distributed Coordination Function* (DCF). La cella qua si chiama *Independent Basic Service Set* (IBSS).

L'ultima modalità è spesso usata in ambito veicolare.

Vediamo lo *stack* del protocollo.

#align(center)[
  #image("assets/06/wifi.png", width: 70%)
]

Il livello MAC permette sia *DCF* (contention service) che *PCF* (contention-free service), in base alla presenza o meno di un AP. Il *Logical Link Control* (LLC) permette alla rete di usare i canali logici.

=== Fisico

Vediamo le *specifiche fisiche* dei vari *emendamenti* di WiFi.

#align(center)[
  #image("assets/06/fisico.png", width: 70%)
]

Come vediamo, nel tempo i *canali* sono aumentati, si sono aggiunte *bande*, ma soprattutto i data transfer sono *cresciuti di bestia*. Notiamo anche una modulazione sempre più precisa, fino a $12$ bit per simbolo. Prima usavamo OFDM e DSSS, ora solo OFDM con anche OFDMA dalla versione $6$ in poi.

=== Link Layer Control

Il *LLC* offre dei *canali logici* con proprietà differenti:
+ *unacknowledged connectionless service*, che ha consegna non garantita, datagram indipendenti e nessun controllo di errori e di flusso;
+ *connection-mode service*, il suo opposto, con canali punto-punto, correzioni degli errori e controllo del flusso;
+ *acknowledged connectionless*, un mischione degli ultimi due, che manda datagram indipendenti ma con ACK.

Con il LLC noi possiamo parlare con reti che hanno un *livello fisico differente*.

#align(center)[
  #image("assets/06/LLC.png", width: 70%)
]

Questo si vede anche a livello di *pacchetti*: infatti, nel payload $802.11$ dobbiamo mettere un *sotto-frame LLC* con un codice che indica che tipi di canale stiamo usando.

=== Livello MAC

Il *livello MAC*, avendo un canale radio molto più inaffidabile di una connessione cablata, ha un payload dei frame molto più grande.

Questo livello offre due servizi:
+ *servizio dati asincrono*, best effort e con delay variabile;
+ *servizio time-bounded*, che offre garanzie sul delay, ed è possibile solo in presenza di un *coordinatore*.

==== DCF

Nelle *reti ad-hoc*, senza un AP, il livello MAX usa *CSMA/CA* per accedere al canale radio. L'accesso al canale radio deve essere regolato *aspettando del tempo*.

Abbiamo diversi tempi di attesa a seconda della tipologia di dati da trasmettere:
+ *slot time*, quantità base che tiene conto del ritardo di propagazione e del trasmettitore. Questo valore dipende dall'emendamento;
+ *Short Inter-Frame Spacing* (SIFS), intervallo breve di attesa usato per messaggi ad alta priorità, tipo quelli di controllo;
+ *DCF Inter-Frame Spacing* (DIFS), intervallo lungo di attesa usato per messaggi a bassa priorità best-effort, e vale $ DIFS = SIFS + 2 ST ; $
+ *PCF Inter-Frame Spacing* (PIFS), intervallo medio di attesa usato per i time-bounded, e vale $ PIFS = SIFS + ST. $

Vale quindi $ SIFS < PIFS < DIFS . $

// rivedi woo
Occhio che *SIFS* e *TimeSlot* sono valori indipendenti.

Vogliamo accedere al canale in *modo esclusivo*, cioè quando trasmettiamo noi tutti gli altri non lo stanno facendo. Inoltre, tutti i dispositivi nella stessa cella parlando sulla stessa banda di frequenza.

Quello che dobbiamo fare quindi è *Carrier Sense*: ascoltiamo il canale, e lo facciamo per un tempo pari a *DIFS*. Questo periodo è come un continuo *CCA*, quindi teniamo *sempre accesa la radio*.

Se nessuno sta parlando posso iniziare a parlare subito.

#align(center)[
  #image("assets/06/no_ACK.png")
]

In questo caso, vediamo una comunicazione *senza ACK*. Come possiamo bene immaginare, se il frame arriva corrotto non abbiamo modo di saperlo.

Se ci viene richiesto l'*ACK* il sender deve aspettare un tempo *SIFS* prima di poter ritrasmettere: infatti, quando TX ha smesso di trasmettere tutti gli altri dispositivi si sono sincronizzati e stanno vedendo anche loro vuoto. Usando un tempo SIFS noi andiamo ad anticipare tutti gli altri, mantenendo il *lock sul canale*.

#align(center)[
  #image("assets/06/ACK.png")
]

Nel caso di *corruzione*, a livello di frame o ACK, allora il TX aspetta SIFS prima di spedire di nuovo. Viene fissato un *massimo numero di tentativi* per la trasmissione.

#align(center)[
  #image("assets/06/ritrasmissione.png")
]

Quando viene ricevuto l'*ACK* si libera il canale.

// scrivi quanto è
Quando troviamo il canale occupato sappiamo che *non siamo da soli*. Quando uno finisce di parlare siamo poi tutti sincronizzati al drop del segnale: qua siamo in un *periodo di contesa*, quindi serve un *random backoff* dopo un DIFS per *de-sincronizzarci* e vedere se ci sono *ACK*. Durante tutto questo random backoff noi eseguiamo il *Carrier Sense*.

#align(center)[
  #image("assets/06/backoff.png")
]

Se durante il *periodo di contesa* vediamo il canale occupato, quindi un bro ha avuto un backoff minore, abbiamo due opzioni:
+ annulliamo tutto e ripartiamo al prossimo ciclo di contesa, ma non è la soluzione migliore perché non è equa;
+ blocchiamo il timer e ripartiamo al ciclo successivo, quindi dovrò aspettare con meno probabilità.

#align(center)[
  #image("assets/06/occupato.png")
]

#line(length: 100%, stroke: 5pt + black)

#align(center)[
  #image("assets/06/soluzione.png")
]

Possiamo quindi permetterci di tenere sempre la radio accesa.

==== Terminale nascosto

Vediamo un piccolo particolare: *CSMA/CA* funziona se *TUTTE le stazioni* sono all'interno dello stesso *raggio di copertura*.

Questo genera il *problema del terminale nascosto*.

#align(center)[
  #image("assets/06/terminale.png", width: 70%)
]

Questo problema avviene quando un nodo sente il *canale vuoto* ma in realtà ci sono altre stazioni che stanno trasmettendo.

Vediamo cosa succede con l'esempio precedente.

Abbiamo $A$ che vuole parlare con $B$ e $D$ che vuole parlare con $B$. Come vediamo, $A$ non vede $D$ e viceversa. Questo però è *pericoloso*: infatti, entrambi facendo Carrier Sense vedono il canale libero, e quando mandano il frame a $B$ lui ha una collisione.

#align(center)[
  #image("assets/06/collisione.png")
]

Risolviamo con un messaggio particolare, il *Request-To-Send* (RTS). Questo è un messaggio *Unicast* a livello MAC in cui si chiede l'*autorizzazione* per parlare con un certo dispositivo.

Vediamo quindi $A$ che manda una RTS, i nodi $C$ ed $E$ vedono questo messaggio, ma visto che non è per loro (Unicast) allocano un *Network Allocation Vector* (NAV) in cui spengono la radio e non ascoltano il canale per una certa *duration* contenuta nel frame, che indica la stima del tempo di comunicazione tra i nodi che vogliono parlare.

Ora $B$ riceve il frame, vede che è per lui, aspetta un tempo SIFS (breve, di controllo, per mantenere il *lock*) in cui fa Carrier Sense e manda un *Clear-To-Send* (CTS), che ricevuto *Unicast* da $A$ permetterà quindi la comunicazione. Come prima, i nodi che non devono comunicare allocano un NAV, stavolta più piccolo.

Questi messaggi non sono a *costo zero*: infatti, noi dopo DIFS potevamo trasmettere, invece usiamo RTS+CTS per evitare le collisioni. Questo si vede nell'*abbassamento del data rate*, visto che mandiamo solo bit di controllo, ma questo porta dei benefici enormi quindi ce lo accolliamo e bona.

In ambito veicolare RTS e CTS non sono usate perché non possiamo permetterci di aspettare del tempo, visto le richieste stringenti sull'immediatezza.

#align(center)[
  #image("assets/06/CTS.png")
]

Infine, una volta che $A$ ha ricevuto il CTS, aspetta SIFS per mantenere il *lock* del canale e poi inizia a trasmettere sul canale.

Nel caso $B$ abbia il canale occupato mentre riceve una RTS (ad esempio sta ricevendo altro) allora $B$ vede un *frame corrotto* ma si ritorna alla situazione di prima in cui l'altro dispositivo manderà a $B$ di nuovo.

Io sfigato che volevo parlare con $B$ aspetto, è scritto nello standard, io non lo so e Quadri in quel momento nemmeno.

// Slide 35 04_wifi.pdf
