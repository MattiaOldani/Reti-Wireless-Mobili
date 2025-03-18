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

= Lezione 07 [18/03]

== Ancora BT

Digressione sul near far: stessa potenza perché devo essere in grado di decodificare, se troppo debole il segnale si perde via

Due blocchi da 16 frequenze sulle 32 disponibili (divise in modo equo su tutto lo spettro). Lo slave seleziona UNO dei 32 canali di wake-up, perché non sa dove la sta mandando ora ma sa che la può mandare in 32 canali. Poi dopo random mando la risposta, il master ascolta le 16 frequenze

Un dispositivo accesso in standby mode non è membro di alcuna piconet, ho minimo consumo

Entro in inquiry mode per:
- creare una piconet
- periodicamente per vedere se sono stati mandati dei messaggi con IAC

Questa operazione di inquiry non è coordinata, ovvero non c'è sincronia dei clock

In page mode il master crea la piconet interrogando gli slave sui profili che possiedono. Transmit consuma, connected uguale ma meno

Master promuove e degrada gli slave in stati di power saving:
- sniff (consuma molto) ascolta ma non tutti gli slot (mantiene AMA)
- hold (consuma medio) con ACL sospesi e solo SCO (mantiene AMA)
- park (consuma meno) rimane membro della piconet ma lascia l'AMA per un PMA; periodicamente ascolta i messaggi del master in broadcast (non sulle 32/16 di prima, sanno dove sono, siamo nella piconet) a tutti i membri parked

Abbiamo visto la parte fisica, ora andiamo nel software

Logical Link Control and Adaptation Protocol (L2CAP) come se fosse il livello IP, non più firmware e hardware. Sempre presente da standard, siamo ad un livello superiore, funzionalità di alto livello

Non viene utilizzato per l'audio, è tutto nel livello dopo

Supporta solo canali ACL e offre 3 canali logici:
- connectionless: unidirezionale (broadcast tra master e slave)
- connection-oriented: bidirezionale con supporto QoS (qualità di servizio, tipo TCP)
- signaling: bidirezionale usato per messaggi di controllo master/slave

Come sono fatti i pacchetti [METTI FOTO]

Notiamo come i payload siano molto più grandi: infatti, sono >> baseband, mentre qua sono in byte. Viene fatta una segmentazione in messaggi baseband. In ricezione poi assembliamo.

Abbiamo lunghezza per sapere la lunghezza del messaggio, CID (connectionless 2 connection-oriented >= 64 signaling 1)

Ultimo pezzo è SDP: protocollo client-server dove si ha un server con le info e un client che fa
- ricerca di un servizio
- browser di servizi (listare i servizi di un dispositivo)

Client è il master, che chiede ai server (slave) i servizi o altro

FINE BT 2.1

Bluetooth Low Energy (BLE) balzo in avanti dal 2.1, siamo almeno nel 4.0 (credo)

Motivazioni:
- ridurre il consumo energetico sui dispositivi
- utilizzo nel mondo degli smart sensor
- necessità di un sistema più snello per la comunicazione
- compatibilità con disponibili Bluetooth
- richiesta di nuove funzionalità come positioning o presence

[IMMAGINE] a sx < 4.0 ho solo master + slave, banda e basta, 1MHz per ogni canale, a dx siamo nel mondo 4.0 e abbiamo, oltre alla stella, anche una struttura broadcast (senza una piconet rigida, chi è nel raggio GG sennò suca) e mesh, con anche servizi di device positioning (misura di presenza di dispositivi, distanza tra dispositivi e direzione). Stesso spettro ma i canali sono di meno 40 (non più 79) e quindi sono un pelo più larghi e resistenti all'interferenza

Perdiamo data rate, le versioni dopo cercano di aumentarlo

[IMMAGINE]

Livello BLE radio (PHY) ho sempre radio a 2.4 GHz ISM

Banda divisa in 40 canali, i primi 37 usati come data packets e i canali 37 38 39 usati come canali di advertising

Facciamo FHSS con hops determinati dalla formula $ "channel" = ("current_channel" + "hop") mod 37 $ dove hop è stabilito all'atto della connessione

Usiamo la Gaussian Frequency Shift Keying (GFSK) bla bla bla

Advertising è lo slave che si annuncia al master per entrare nella piconet. Initiating lo fa il master, se si becca con advertising si crea la connection. Altri stati (iso e scanning) che sono messi li nello standard per i nuovi casi d'uso:
- iso è un broadcast periodico, che mette info in giro
- scanning fa ascolto di quello che c'è in giro

Advertising si fa su 3 canali, VEDI IMMAGINE

Si entra in stato advertising, si mandano sui 3 canali con un ADVInterval, multiplo di 0.625ms ma nel range 20ms-10.24s (determina anche uso batteria, subito --> molto lento). Per evitare allineamento che causi collisione (non siamo coordinati) ho un advDelay, pseudo-random in 0ms e 10ms

Generic Attribute Profile non ho capito cosa sia ma va bene

General Access Protocol (GAP) è un modulo software che trasforma gli stati del dispositivo:
- broadcaster (spedisce advertising packets, trasmissione i dati connectionless come eventi di adv)
- observer (riceve adv packets, riceve dati in connectionless)
- peripheral (periferico), device slave che opera in advertiser mode a LL
- central è un device master (Initiator) mode a LL

Vediamo una unicast peer-peer: opposto di quello che avveniva prima, master ascolta e gli slave fanno richiesta per collegarsi ad una piconet. Quando il master ha ascoltato passa in initiator e manda una connection request sullo stesso canale. Poi si passa all'effettiva comunicazione master-slave

Connessione broadcast: abbiamo un broadcaster che manda dati sui canali 37 38 39 agli observer (nel raggio di comunicazione, non mi frega chi c'è o chi no, io devo solo trasmettere)

Possiamo avere un passive scanning: uno sniffer, ascolto periodicamente su quei canali quello che arriva, sempre sui 37 38 39 (id)

Oppure un active scanning: è sempre e solo sul 37 38 39 ma facciamo richieste su questi canali con una request + response. Scanner fa richiesta, advertiser fa la response. Questo deve avvenire in un advertising scan interval. La richiesta sono tipo cosa sai fare, dammi le tue coordinate, dove sei. Possiamo vederlo come broadcast + unicast quando faccio le richieste, mi sincronizzo per parlare con quel bro
