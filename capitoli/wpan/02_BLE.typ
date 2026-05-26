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

= Bluetooth Low Energy

La versione *Low Energy* di Bluetooth nasce nella versione $4.0$ dello standard e ancora oggi viene sviluppata in parallelo al Bluetooth classico.

Le motivazioni di questo standard sono molteplici:
+ *ridurre il* -- già basso -- *consumo energetico* dei dispositivi;
+ essere utilizzato nel mondo degli smart sensor;
+ avere un sistema più snello per la *comunicazione*;
+ nuove funzionalità di *positioning*, *presence*, *distance*, *direction*, eccetera.

Si ha comunque *compatibilità* con tutti i dispositivi Bluetooth classici.

In questo standard si aggiungo altre due possibili *topologie* o *pattern di comunicazione*: *broadcast* e *mesh*.

Inoltre, cambia anche il numero di canali: questi vengono ridotti a $40$, causando quindi un *abbassamento* del data rate.

Tutti queste informazioni vengono spiegate meglio dopo.

// Tabella magari
BLE aggiunge anche una *classe di potenza*, la $1.5$, con massimo output pari a $10mW$.

==== Architettura

Nella prossima immagine vediamo l'*architettura* di BLE.

#align(center)[
  #image("assets/02/BLE.png", width: 60%)
]

Come vediamo, cambia leggermente la *parte fisica* mentre la *parte software* viene rivoluzionata abbastanza. Ovviamente, con la linea tratteggiata dividiamo *controller* e *software*.

==== BLE Bluetooth Radio

La radio usa sempre la *ISM* $2.4"G"hertz$, ma in questo caso la *BLE Bluetooth Radio* divide la banda in $40$ canali, in cui:
+ $37$ sono usati per inviare i *data packets*;
+ $3$ sono usati come *canali di advertising*.

Viene usato un *FHSS* molto semplificato, che calcola la frequenza successiva con la formula $ "channel" = ("current_channel" + "hop") mod 37 $ in cui "hop" è stato stabilito all'atto della connessione.

Infine, si usa *GFSK* (Gaussian FSK) per la modulazione, ottenendo un data rate du $1"M"bps$.

Come vediamo, il data rate è basso, ma nel mondo delle reti è così: le tecnologie non sono pensate per fare tutto bene, ma sono *specifiche* per i singoli casi d'uso.

I canali sono dividi nel seguente modo.

// Tabella
#align(center)[
  #image("assets/02/canali.png", width: 60%)
]

I canali di *advertising* sono inseriti all'inizio, fine e -- più o meno -- in mezzo per minimizzare le interferenze. Gli altri canali invece sono usati per i dati, e si usa la colonna *RF Channel* per indicare l'indice del canale da usare.

==== BLE Link Layer

Andiamo al livello data link e vediamo il *Link Layer*, che gestisce la *macchina a stati finiti* che determina il comportamento dei dispositivi.

#align(center)[
  #image("assets/02/FSM.png", width: 60%)
]

Si parte sempre dallo *standby*, ma ora abbiamo anche altre *funzionalità*, oltre alla creazione di piconet:
+ *isochronous broadcasting*, che fa *broadcasting periodico* a livello data link sui canali di advertising;
+ *scanning*, che permette di ascoltare gli slave che si stanno annunciando;
+ *synchronization*, non ne ha parlato.

Per creare una piconet ora abbiamo meno robe da fare, anche perché è direttamente lo *slave* che si propone al master, e non è il master che chiede agli altri di unirsi:
+ in fase *advertising* lo slave di sta annunciando al master;
+ in fase *initiating* il master crea una nuova piconet.

Come in Bluetooth, vi è una completa distribuzione del sistema: non si ha niente di coordinato.

L'*advertising* funziona nel seguente modo.

#align(center)[
  #image("assets/02/advertising.png", width: 80%)
]

Il *tempo di advertising* è il tempo tra due *eventi di advertising*, ed è calcolato come somma di due quantità:
+ *advertising interval*, scritto nel dispositivo, ed è un multiplo intero di $0.625micros$ in un certo range tra $20micros$ e $10.24$ secondi;
+ *advertising delay*, che è un numero random tra $0micros$ e $10micros$ generato per evitare sovrapposizioni temporali.

La scelta dell'advertising interval indica anche il *dispendio energetico*.

==== Generic Attribute Profile

Il *Generic Attribute Profile* (GATT) gestisce tutti i *profili del dispositivo*, spesso molto *specifici*, che dicono cosa è in grado di fare quel dispositivo.

==== General Access Protocol

Il *General Access Protocol* gestisce invece lo *stato del dispositivo* ad un livello più alto. La macchina a stati che abbiamo visto prima è del livello Link Layer, qua invece abbiamo una soluzione più vicina a quella che uno sviluppatore si aspetta.

Gli *stati* in cui ci possiamo trovare sono:
+ *broadcaster*, in cui spediamo pacchetti di advertising in modalità connectionless;
+ *observer*, in cui riceviamo i pacchetti di advertising sempre in modalità connectionless;
+ *peripheral*, che indica uno slave advertiser del livello Link Layer;
+ *central*, che indica il master initiator del livello Link Layer.

==== Connessioni

In tutti questi esempi di *connessioni* abbiamo a destra lo *slave*.

===== Unicast peer-to-peer

Nella connessione *unicast* lo slave è un *advertiser*, che manda dei messaggi di advertising sui tre canali dedicati a questo traffico.

#align(center)[
  #image("assets/02/unicast_01.png", width: 70%)
]

Il master, in fase di *scanner*, ascolta i pacchetti, che contengono le informazioni base del dispositivo che si vuole unire alla piconet.

Quando il master è riuscito ad identificare uno dei tre pacchetti passa in fase *initiator*, e risponde sullo stesso canale dove ha ottenuto la richiesta.

#align(center)[
  #image("assets/02/unicast_02.png", width: 70%)
]

Master e slave si sono connessi:
+ il *master* ha stato central [GAP] e client [GATT];
+ lo *slave* ha stato peripheral [GAP] e server [GATT].

===== Broadcast

Nelle "connessioni" *broadcast* abbiamo un host che vuole fare broadcasting, quindi si deve diventare *broadcaster* [GAP], mentre chi vuole ascoltare deve diventare *observer*.

#align(center)[
  #image("assets/02/broadcast.png", width: 70%)
]

Ovviamente, tutto questo avviene nel raggio di potenza del segnale.

===== Scanning

Infine, abbiamo due tipi di *scanning*.

#align(center)[
  #image("assets/02/passive.png", width: 70%)
]

Nello *scanning passivo* abbiamo un *advertiser* e una serie di *scanner* che però ascoltano e basta.

#align(center)[
  #image("assets/02/active.png", width: 70%)
]

Nello *scanning attivo* abbiamo sempre un advertiser, ma gli scanner possono fare delle *richieste* sui canali di broadcasting dove chiedono qualcosa.

// Fine 02_bluetooth.pdf
