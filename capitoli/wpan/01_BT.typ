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

= Bluetooth

Siamo in ambito *WPAN*, con lo standard $802.15$: questo comprende un insieme di tecnologie per la *comunicazione a corto raggio*. Di questo standard noi vedremo il *Bluetooth* ($802.15.1$) e lo *ZigBee* ($802.15.4$).

La struttura del Bluetooth è *fortemente gerarchica*: la struttura base è la *piconet*, nella quale abbiamo:
+ un *master node*, che coordina l'intera attività della piconet, ovvero decide chi può parlare, chi è attivo e chi no, chi può entrare, chi deve uscire, eccetera;
+ una serie di *slave nodes*, che seguono quello che viene detto dal master node, usando la sua frequenza e il suo tempo.

La *comunicazione* è *short-range* tra i $10$ e i $50$ metri, e questa dipende dai casi d'uso e dalla *classe di potenza* del dispositivo. In Bluetooth abbiamo tre *classi*:
+ *power class $1$* ha una potenza di $100mW$ e comunica fino a $100$ metri senza ostacoli;
+ *power class $2$* ha una potenza di $2.5mW$ e comunica fino a $10$ metri, ed è il caso più tipico dei dispositivi Bluetooth;
+ *power class $3$* ha una potenza di $1mW$ e comunica fino a $2$ metri.

Viene usata la *banda ISM* $2.4"G"hertz$, uguale a quella del Wi-fi, e ha un *data rate* compreso tar $2.1"M"bps$ e $24"M"bps$.

Il Bluetooth viene usato per:
+ creare *punti di accesso* per dati e voce;
+ sostituire i *cavi* usando delle periferiche wireless, tipo le cuffie o il mouse;
+ comunicare *ad hoc* con altri dispositivi BT, tipo le reti Mesh.

=== Architettura Bluetooth

Vediamo come è stato costruito lo *stack Bluetooth*.

#align(center)[
  #image("assets/01/architettura.png")
]

Come vediamo, lo stack non c'entra niente con lo standard *ISO/OSI*: questo perché il Bluetooth è nato in *ambito industriale*, che quindi creava lo stack in base alle sue necessità.

Tutti i blocchi blu sono il *core del protocollo*, ovvero sono sempre presenti in qualsiasi dispositivo Bluetooth. Tutti gli altri blocchi possono essere presenti o meno, a seconda della tipologia del dispositivo.

Sotto la linea rossa tratteggiata abbiamo la parte di *controller*, formata da apparecchi *hardware* e/o *firmware*, mentre la parte sopra la linea è la parte *software*.

Andando sopra la linea tratteggiata rossa andiamo anche dal dispositivo alla "*rete*" -- abbiamo un solo hop, chiamarla "rete" è un gran complimento -- che viene convogliata in un unico apparato, chiamato *L2CAP*, ma ne parliamo meglio dopo.

==== Bluetooth Radio

Il livello *Bluetooth Radio* è al *livello fisico*, e si occupa di:
+ gestire le frequenze radio;
+ gestire il Frequency Hopping:
+ scegliere lo schema di modulazione e il FEC;
+ utilizzare la potenza di trasmissione indicata.

==== Baseband

Il livello *Baseband* è al *livello data link*, e si occupa di:
+ stabilire la connessione con la piconet;
+ gestire l'indirizzamento dei dispositivi, hardware e interno alla piconet;
+ formattare i pacchetti frame;
+ sincronizzare i dispositivi per permettere la comunicazione usando TDD (Time Division Duplex) e TDMA (Time Division Multiple Access);
+ gestire la potenza di trasmissione, passando poi i valori al livello inferiore.

Il TDD, o *Time Division Duplex*, spiega come viene realizzata la comunicazione nelle *due direzioni*. In wireless non possiamo avere il Full Duplex come su cavo, quindi dividiamo la comunicazione in intervalli di tempo (Time Division).

Il *TDMA*, o Time Division Multiple Access, spiega invece come l'unità di tempo viene divisa tra i vari utenti.

==== Link Manager Protocol

Il livello *Link Manager Protocol* (LMP) si occupa di:
+ configurare i nuovi collegamenti tra i dispositivi tramite l'operazione di inquiry;
+ gestire i collegamenti attivi;
+ fornire funzionalità di sicurezza e cifratura.

==== Logical Link Control and Adaptation Protocol

Il livello *Logical Link Control and Adaptation Protocol* (L2CAP) si trova *lato software* ed è un protocollo che permette di far *convergere* tutti i blocchi sopra di esso nell'architettura in un blocco unico (sé stesso). In poche parole, tutte le tecnologie che sono opzionali ed esterne a Bluetooth possono essere adattate ad esso passando per questo protocollo.

Vengono forniti due servizi ai livelli superiori: *connectionless* e *connection-oriented*, ma li vedremo nel dettaglio successivamente.

==== Service Discovery Protocol

Il *Service Discovery Protocol* (SDP) è usato per gestire le informazioni del dispositivo, come *caratteristiche tecniche* e *servizi disponibili*. Questo servizio viene interrogato per stabilire le connessioni tra dispositivi.

==== Radio Frequency Communication

Il *Radio Frequency Communication* (RFCOMM) è un protocollo usato per *rimpiazzare* il cavo, ma non è fondamentale nello stack.

==== Protocolli opzionali

Sopra il protocollo L2CAP (escluso SDP) abbiamo tutti i protocolli che sono *già esistenti*, come ad esempio TCP/IP, che però possono utilizzare la tecnologia Bluetooth per funzionare passando per L2CAP.

Facciamo questo perché vogliamo riutilizzare la maggior parte dei protocolli, quindi definiamo una serie di *profili* che indicano un particolare modello di utilizzo dell'architettura.

Notiamo comunque che l'*audio* non passa per il protocollo L2CAP ma lavora direttamente con il Baseband, e il *control* parla direttamente con il protocollo LMP.

=== Specifiche radio

Nella prossima tabella sono indicate le *specifiche radio* di Bluetooth.

#align(center)[
  #image("assets/01/radio.png", width: 70%)
]

Bluetooth usa le tecniche di Spread Spectrum, in particolare la *Frequency Hopping*: vengono infatti usate dalle $23$ alle $79$ *sotto-portanti* per la comunicazione, e ne vengono cambiate $1600$ ogni secondo.

L'accesso alla *piconet* avviene tramite *FH-TDD-TDMA* mentre l'accesso alla scatternet avviene tramite *FH-CDMA*.

=== Piconet e scatternet

La *piconet* è la più piccola rete Bluetooth che si può creare.

Essa è formata da *un solo master* e *diversi slave*, che possono essere in tre *stati*:
+ *active slave* (AS), membro attivo della piconet, che riceve i messaggi dal master e può anche parlare. Possiede un indirizzo detto *Active Member Address* (AMA) di $3$ bit, che mi permette di individuare al massimo $7$ slave;
+ *parked slave* (PS), membro della piconet che non ha accesso diretto alla comunicazione, ovvero può solo ascoltare ma non può comunicare. Per entrare ancora nella piconet deve aspettare che un AS liberi il posto. Possiede un indirizzo detto *Parked Member Address* (PMA) di $8$ bit, che mi permette di individuare al massimo $255$ slave;
+ *standby slave* (SS), dispositivi che non hanno indirizzo, non sono attivi e non sono parked, ma sono in ascolto (e nemmeno sempre). Non avendo indirizzo abbiamo un numero *illimitato* di SS.

Per gli indirizzi AMA e PMA, il *master* ha sempre indirizzo $0$.

Lo standard Bluetooth permette ad uno slave di poter stare in *più piconet* (tipo una stampante condivisa tra più nodi di un ufficio). Questo slave può essere in una tra tutte le possibili combinazioni dei tre stati.

Una *scatternet* è una rete che contiene più piconet. Ciascuna piconet è comunque *indipendente*, ovvero ogni master la propria piconet e basta. Gli slave che appartengono a più piconet li dobbiamo però gestire in maniera specifica.

#align(center)[
  #image("assets/01/scatternet.png", width: 70%)
]

==== Comunicazione nella piconet

Vediamo ora come viene gestita la *comunicazione nella piconet*. Questa avviene tramite FH-TDD-TDMA: vediamo nel dettaglio ogni singolo blocco.

#align(center)[
  #image("assets/01/comunicazione.png", width: 70%)
]

Con il *FH* noi scegliamo su quali frequenze comunichiamo e ascoltiamo. La sequenza è *decisa dal master* e comunicata a tutti gli slave.

Con il *TDD* dividiamo la comunicazione in due *fasi*:
+ una fase in cui *parla il master* e gli *slave ascoltano*, che chiameremo *MS*;
+ una fase in cui *parla lo slave* e il *master ascolta*, che chiameremo *SM*.

Questa divisione ha *basso dispendio energetico* e soprattutto è facile da implementare: prima si ha la fase MS, poi SM, e poi si ricomincia da capo.

Con $f_i$ indichiamo la *frequenza* scelta per la comunicazione nell'istante di tempo con indice $i$. Avremo quindi sugli *indici pari* la comunicazione MS, mentre sugli *indici dispari* la comunicazione SM.

Come vediamo, la comunicazione MS o SM avviene in blocchi di $625micros$, in cui si ha la comunicazione in uno dei due versi e un periodo di *guardia* di $220micros$ per permettere il cambio di antenna.

Con il *TDMA* invece dividiamo la comunicazione in blocchi di lunghezza pari SM/MS, in cui si ha l'alternanza di comunicazione tra master e slave.

Vediamo meglio l'*alternanza* con il *TDMA* nella prossima immagine.

#align(center)[
  #image("assets/01/TDMA.png", width: 70%)
]

/*
In realtà TDD divide in tempo, TDMA divide in MS e SM
*/
Come vediamo, nel blocco formato dalle frequenze $(f_0, f_1)$ abbiamo:
+ *FH* perché siamo su due frequenze diverse;
+ *TDD* perché abbiamo MS e poi SM;
+ *TDMA* perché abbiamo unito una comunicazione MS con una SM.

Lo stesso discorso vale per i blocchi di frequenze $(f_2, f_5)$.

Notiamo una cosa importante: master e slave possono usare *più slot temporali* per comunicare. Ad esempio, il master vuole parlare con lo slave $2$, e questo usa tre slot temporali. Altro caso è lo slave $3$ che usa addirittura cinque slot temporali.

Questo è ovviamente possibile: uno slave potrebbe dover mandare molti dati, quindi occupa più slot temporali. È *importantissimo* che:
+ la comunicazione sia sempre alla *stessa frequenza*;
+ l'indice della sequenza delle frequenze deve spostarsi avanti un numero pari al numero di slot usati per la trasmissione;
+ il numero di slot deve essere *dispari*.

Senza questa ultima clausola si andrebbe ad incasinare l'alternanza rigida MS e SM che è alla base della comunicazione.

==== Comunicazione nella scatternet

Se un nodo slave è in più piconet possiamo avere dei problemi.

Lo slave deve tenere il *FH* delle varie piconet nelle quali è un AS. Ogni piconet trasmette su una frequenza diversa, ma su $79$ canali è possibile avere una sovrapposizione.

Una prima soluzione a questo è *ridurre* il numero di frequenze, ma non funziona benissimo. Una soluzione nettamente migliore è usare *CDMA* per evitare delle interferenze: infatti, ogni master sceglie un codice ortogonale per la propria piconet, così che ogni slave possa decifrare il segnale ricevuto usando i codici a sua disposizione e possa capire da che master il messaggio è stato mandato.

=== Canali al livello Baseband

Il livello *Baseband* mette a disposizione due *canali* per la comunicazione:
+ *Synchronous Connection-Oriented Link* (SCO), comunicazione point-to-point sincrona che richiede una connessione. Viene utilizzata per i servizi che necessitano di un *bit rate costante*, come l'audio, la voce o il *traffico real time*. Per questi canali vengono riservati slot adiacenti ad intervalli regolare per permettere la comunicazione bidirezionale. Possono essere attivi al massimo $3$ canali SCO contemporaneamente per ogni dispositivo;
+ *Asynchronous Connectionless Link* (ACL), comunicazione point-to-multipoint *best effort* che utilizza gli slot rimanenti e rappresenta il traffico dati che si ha tra il master e lo slave. Visto che in ogni blocco di slot temporali parla un solo slave, è attivo un solo ACL contemporaneamente.

#align(center)[
  #image("assets/01/canali.png", width: 70%)
]

Come vediamo in questo schema, lo SCO$1$ è schedulato ad intervalli regolari, come lo SCO$2$, mentre gli ACL sono inseriti negli spazi liberi che sono rimasti inutilizzati.

Gli ACL possono essere di diverso *tipo*, in base ad alcuni aspetti quali encoding utilizzato, data rate, simmetrico/asimmetrico, eccetera. Vediamo un riassunti dei tipi nella seguente tabella.

#align(center)[
  #image("assets/01/ACL.png", width: 70%)
]

=== Frame livello Baseband

Per comunicare i dati usiamo una serie di *frame* costruiti dal livello *Baseband*. Il frame, costruito quindi al *livello data link*, è costituito da *tre parti*: *access code*, *header* e *payload*.

==== Access code

#align(center)[
  #image("assets/01/access_code.png", width: 70%)
]

L'*access code* è utilizzato per sincronizzare ed identificare i dispositivi della rete. Abbiamo tre diversi codici:
+ *Channel Access Code* (CAC), che identifica la piconet usando i $48$ bit dell'indirizzo MAC del master;
+ *Device Address Code* (DAC), che è usato dal master per chiamare (fare paging) un dispositivo, ed è derivato dall'indirizzo MAC dello slave;
+ *Inquiry Address Code* (IAC), che è usato dal master per trovare l'indirizzo di un dispositivo vicino.

==== Header

#align(center)[
  #image("assets/01/header.png", width: 70%)
]

L'*header* contiene una serie di informazioni importanti:
+ *type*, che indica se abbiamo un canale SCO o ACL, e se ACL anche di che tipo, che ricaviamo dalla tabella degli SCO mostrata in precedenza;
+ *flow*, che ha valori $1$ (se stop) o $0$ (se resume) per le ACL;
+ *ARQN*, che indica se il pacchetto è un *ACK* ($1$) oppure un *NACK* ($0$);
+ *SEQN*, che indica il sequence number modulo $2$.

==== Payload

Il *payload* si differenzia tra SCO e ACL:
+ nei canali *SCO* il payload è di $30$ byte ed è *fisso*;
+ nei canali *ACL* il payload è *variabile* tra $0$ e $343$ byte.

==== Controllo degli errori

Grazie ai campi ARQN e SEQN possiamo implementare il *controllo degli errori*.

#align(center)[
  #image("assets/01/errori.png", width: 70%)
]

Vediamo questo esempio, che ha $5$ fasi:
+ nella *prima fase* il master comunica con lo slave un messaggio con SEQN $0$, al quale lo slave risponde con un ACK in cui dice di aver ricevuto il messaggio con quel SEQN;
+ nella *seconda fase* il master comunica con SEQN $1$ ma il messaggio viene perso, quindi lo slave, che sa che deve parlare perché siamo in TDD ed è stato avvisato, manda un NACK con il SEQN che si aspettava;
+ nella *terza fase* il master rimanda con SEQN $1$ ma stavolta è l'ACK dello slave che si perde; il master, aspettandosi un ACK dallo slave perché siamo sempre in TDD e avevo indicato lo slave che doveva parlare, capisce che deve rispedire di nuovo;
+ nella *quarta fase* va tutto a buon fine, sia il messaggio dal master con SEQN $1$ sia l'ACK con lo stesso valore;
+ dalla *quinta fase* torna tutto alla normalità facendo sempre i conti modulo $2$.

L'uso del modulo $2$ è molto comodo perché nel singolo time slot mandiamo un solo messaggio, quindi quando mandiamo $0$ dopo ci aspettiamo e viceversa.

=== Come avviene la inquiry

Il modulo *LMP* è quello che gestisce la fase di *inquiry*, ovvero l'ingresso di nuovi dispositivi nella piconet. Più in generale gestisce tutte le *transizioni di stato* del dispositivo.

#align(center)[
  #image("assets/01/stati.png", width: 60%)
]

Quando il dispositivo viene acceso è in fase di *standby*, in cui non è membro di nessuna piconet e si ha un *consumo energetico minimo*.

Poi entriamo nella fase di *inquiry*: in questa noi andiamo a creare una piconet e controlliamo se sono stati mandati dei messaggi *IAC* per permettere la connessione di dispositivi. Questa operazione *non è coordinata*, ovvero è totalmente *asincrona*.

In fase di *paging* si crea effettivamente la piconet, con master e slave che prendono i propri ruoli e si interrogano sui profili che possiedono.

Dopo questo siamo effettivamente *connessi*. In questo caso abbiamo il nostro indirizzo AMA, quindi siamo AS, ma possiamo essere in tre stati diversi:
+ *sniff*, in cui ascoltiamo ma non su tutti gi slot;
+ *hard*, in cui sospendiamo gli ACL e manteniamo solo gli SCO;
+ *park*, in cui perdiamo l'AMA e prendiamo un PMA, ascoltando i messaggi che il master invia in broadcast.

Tutto facile, ma questa connessione è molto macchinosa e complicata.

#align(center)[
  #image("assets/01/inquiry01.png")
]

Partiamo con master e slave in *standby*. Lo slave deve conoscere il *clock* del master, per potersi *sincronizzare* con lui.

#align(center)[
  #image("assets/01/inquiry02.png")
]

Periodicamente il *master* invia $32$ messaggi consecutivi su $32$ canali detti *wake-up channel*. Questi messaggi hanno il codice IAC, e se uno slave riesce ad intercettarlo è tanta roba.

Non siamo comunque *coordinati*: il master manda i messaggi ma lo slave non sa su quale delle $32$ frequenze e soprattutto quando.

#align(center)[
  #image("assets/01/inquiry03.png")
]

Visto che i pacchetti durano $625micros$ lo slave rimane in ascolto per un tempo quasi $20$ volte più grande, per essere "quasi" sicuro di beccarlo. Questo tempo di *inquiry scan* è di $11.25millis$.

Visto che la fase di scansione è molto dispendiosa, non si è sempre accesi per ascoltare sulle frequenze, ma si fa appunti una inquiry scan e poi si aspetta per un tempo totale di almeno $1.28$ secondi. Questo periodo è detto *scan interval*.

#align(center)[
  #image("assets/01/inquiry04.png")
]

Quando riusciamo ad intercettare un messaggio IAC ci siamo sincronizzati con il master, ma lui ancora non ci conosce: dobbiamo quindi *rispondere* dando tutte le nostre informazioni, ma non lo facciamo subito. Questo perché se rispondessimo tutti subito ci sarebbero un sacco di interferenze. Per rispondere generiamo un *random backoff*, dopo il quale comunichiamo con il master.

#align(center)[
  #image("assets/01/inquiry05.png")
]

Ora che il master sa della nostra esistenza ci vengono mandate tutte le informazioni per stare nella piconet, quindi il FH e un AMA, che però dobbiamo scansionare da $16$ canali dei $32$ di wake-up. Dobbiamo fare ciò perché ancora non conosciamo il FH della piconet.

#align(center)[
  #image("assets/01/inquiry06.png")
]

Una volta che abbiamo tutte le informazioni possiamo iniziare la comunicazione.

// Slide 41 02_bluetooth.pdf

/*
Da aggiungere alla parte delle ACL: nel campo type, se abbiamo ACL dobbiamo inserire il tipo. L'ultima cifra indica quanti slot voglio usare per la comunicazione
*/

== Bluetooth

=== L2CAP

Spostiamoci sul livello *software*: vediamo cosa offre il blocco L2CAP ai livelli superiori.

L2CAP lavora solo sulle *ACL* del baseband, i canali *SCO* sono solo per audio e altro.

Vengono forniti tre tipi di *canali logici*:
+ *connectionless*: unidirezionali, usati per il traffico broadcast;
+ *connection-oriented*: bidirezionali, con supporto *QoS*, e per questo è richiesta una connessione;
+ *signaling*: bidirezionali di segnalazione, usato dal *SDP* per operazioni di controllo master/slave.

Vediamo il formato dei *pacchetti* L2CAP.

#align(center)[
  #image("assets/01/L2CAP.png", width: 70%)
]

Notiamo subito che il pacchetto L2CAP è *molto più grande* di un pacchetto Baseband: questo vuol dire che il modulo L2CAP si occupa di fare *segmentazione/frammentazione* e *assemblaggio* di pacchetti, come fa ad esempio IP in ISO/OSI.

I tre canali descritti si distinguono in base al campo *CID*:
+ se è $2$ abbiamo un pacchetto *connectionless*, in cui dobbiamo indicare il protocollo nel campo *PSM*;
+ se è $gt.eq 64$ abbiamo un pacchetto *connection-oriented*, e il CID indica proprio il numero del canale, come se fosse una *porta*;
+ se è $1$ abbiamo un pacchetto *signaling*, e nel payload abbiamo i comandi da eseguire.

Nel campo *length* abbiamo la lunghezza del pacchetto complessivo.

=== SDP

Il *Service Discovery Protocol* (SDP) consente di usare il dispositivo: infatti, indica che profili ha, a che cosa serve, eccetera.

Utilizza un'architettura *client-server*:
+ il *server* (lo slave di solito) ha un *Service Discovery Database*, che contiene nei suoi record tutti i servizi presenti sul server;
+ il *client* (il master di solito) deve poter *ricercare* un servizio oppure fare *browsing* dei servizi.

Questo traffico si appoggia ai *canali ACL*, visto che non abbiamo bisogno di real-time. Questo non vuol dire che la ricerca sia a caso: nelle ACL possiamo mandare pacchetti *connection-oriented* per ricercare un dispositivo preciso oppure mandare dei pacchetti *connectionless* se vogliamo una ricerca broadcast.
