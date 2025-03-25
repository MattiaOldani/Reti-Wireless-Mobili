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

= Lezione 09 [25/03]

== WLAN

Siamo nell'802, livello fisico e MAC

In questo caso, siamo 802.11 per le WLAN

Obiettivi:
- throughput, uso efficiente del canale radio per elevato data rate
- elevato numero di nodi, non su singolo AP ma su più celle, centinaia di nodi gestiti da più celle
- connessione verso la dorsale (backbone) cablata
- raggio $100\-300$ metri
- uso efficiente della batteria (meno estremo di ZigBee e BT), ma da wifi6
- più WLAN possono coesistere
- operare nelle bande unlicensed
- configurazione dinamica

La più comune rete wifi (Wireless Fidelity) è [IMMAGINE], rete con uno o più access point e la rete viene coordinata con Point Coordination Function (punto di coordinamento, access point). In più, basic service set identifica la cella (tipo eduroam)

Un'altra versione sono reti ad-hoc e sono distributed coordination function, non si ha un vero punto di coordinamento, con un independent basic service set (ambito veicolare questo)

Livello fisico [metti IMMAGINE]

Cosa offre il servizio Logical Link Control (LLC):
- unacknowledged connectionless service
  - trasmetto ma consegna non garantita
  - datagram indipendenti
  - no controllo errori
  - no controllo di flusso
- connection-mode service (link affidabile, perché canale wireless è inaffidabile per definizione)
  - canale punto-punto
  - correzione degli errori
  - controllo di flusso
- acknowledged connectionless
  - datagram indipendenti
  - acknowledge datagram

Vediamo il sottolivello MAC

Il canale radio è sensibilmente più inaffidabile di un canale cablato, quindi la frame di MAC 802.11 è più complessa dell'Ethernet 802.3:
- in 802.3 il payload è di 1500-1518B
- in 802.11 al massimo è 2304B

Il livello MAC offre due servizi:
- servizio dati asincrono: best effort e con delay variabile
- servizio time-bounded: offre garanzie sul delay

Il time-bounded è disponibile solo in presenza di un coordinatore (AP)

Distributed coordination function: opera con CSMA/CA

L'accesso al canale radio deve essere regolato aspettando del tempo per poter trasmettere. 802.11 prevede diversi tempi di attesa a seconda della tipologia di dati da trasmettere

Ci sono standard sul numero di slot, ma ognuno parte quando vuole ad aspettare un certo tempo

Abbiamo 4 definizioni:
- slot time: tiene conto di ritardo di propagazione e del trasmettitore (un quanto di tempo che il dispositivo sa che deve attendere)
- short inter-frame spacing [SIFS]: intervallo più breve di attesa usato per messaggi ad alta priorità
- DCF inter-frame spacing [DIFS]: intervallo di tempo più lungo usato per messaggi a bassa priorità best-effort SIFS + 2*slot-time
- PCF inter-frame spacing [PIFS]: intervallo di tempo intermedio per time-bounded SIFS + slot-time

Usati per gestione, che ogni dispositivo in modo arbitrario e privato, del proprio tempo

Come avviene accesso al canale? È sempre in contesa

CANALE LIBERO NO ACK

No tempo random, iniziamo ad ascoltare subito. Ascoltiamo un tempo uguale a DIFS (più lungo), e durante la durata radio accesa per ascolto del canale (tutto il tempo, non spengo come ZigBee)

No ACK se il frame è corrotto, non ho modo di saperlo

CANALE LIBERO CON ACK

Non faccio carrier sense per l'ack. Dopo che finiamo di trasmettere, uso un tempo SIFS dopo aver mandato in modo atomico il mio frame, perché il frame è di controllo (ack). Aspettando tempo minore, sono sicuro che chi sta aspettando di trasmettere non decide di farlo e non fa interferenza

CANALE LIBERO CON ACK MA NON RICEVUTO

Se il frame è corrotto, il trasmettitore sta aspettando il SIFS. Se non riceve automaticamente assume che trasmissione non è andata a buon fine, a prescindere dall'errore. Cosa fa? Rimanda subito, ho preso il canale in maniera esclusiva. Viene fissato un numero massimo di tentativi. Ack viene mandato subito, tempo di switchare l'antenna

CANALE OCCUPATO

Sento un altro segnale, il CCA mi dà rosso perché uno sta trasmettendo. Cosa faccio? Tengo radio accesa (ecco perché dispendio alto di batteria) fino a quando non sentiamo la fine della trasmissione. Non possiamo trasmettere immediatamente, potrebbe manca un ack. Inoltre, noi non siamo da soli, non siamo gli unici ad aver trasmesso. Facciamo un periodo di contesa con un random backoff:
- si attende il SIFS/PIFS/DIFS dopo il CCS (fine trasmissione dell'altro bro, è un evento che bene o male sincronizza tutti i dispositivi di rete) in base alla priorità del messaggio che si deve mandare

Numero di slot time da attendere, durante il periodo noi facciamo CS

Se ci va ancora male? Sincronizzazione, aspetto DIFS (non ho manco ack), random backoff ma uno va prima di me. Opzioni:
- riparto dalla contesa, come se non fosse mai avvenuto, ma questo è un problema di attesa infinita --> interrompo il conteggio, e nel turno successivo riparto da quello

Problema del terminale nascosto

[IMMAGINE]

Se A fa CS, non sente nessuno che parla, quindi inizia a spedire. In modo analogo, D fs CS, non sente nessuno che parla, quindi inizia a spedire. Entrambi hanno ok dal livello fisico e iniziano a parlare

Cosa riceve B? Collisione non evitata, viola il CSMA/CD

Ho terminali nascosti, ovvero il raggio non mi permette la percezione delle trasmissioni degli altri.
