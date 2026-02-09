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
// Slide 36 04_wifi.pdf

= Lezione 07 [09/02]

== WiFi

=== Frammentazione [DCF]

Il canale radio è molto più *sensibile* ad interferenze e rumori. Il livello MAC frammenta quindi i frame in frammenti più piccoli, visto che già è probabile che ogni frame abbia errori.

Inoltre, avendo preso il canale con fatica, dobbiamo mantenerlo per mandare tutti i frammenti.

#align(center)[
  #image("assets/07/frammentazione.png", width: 70%)
]

=== PCF [infrastruttura]

/*
Aggiungi lezione prima

Prima eravamo senza infrastruttura, siamo in DCF
*/

Passiamo ora alla rete che ha una *infrastruttura*. Ogni *AP* determina una *cella*, e un insieme di celle sono collegate tra loro tramite un *distributed system* (DS). Le singole celle hanno un *BSSID*, mentre il sistema distribuito si chiama *Extended Service Set* (ESS).

#align(center)[
  #image("assets/07/infrastruttura.png", width: 70%)
]

Come vediamo, abbiamo un minimo di *overlapping*, che è necessario per il *roaming*, ovvero per la *mobilità*. Ovviamente, in WiFi dobbiamo avere mobilità, ma non è un requisito diverso da quello dei dati mobili: infatti, WiFi è *nomade*, ovvero siamo fermi, ci spostiamo, e poi siamo ancora fermi.

La funzionalità di mobilità viene garantita dal modulo *LLC*.

In una rete con infrastruttura tutti i frame passando per l'*AP*, anche se essi vogliono comunicare due nodi solo tra di loro.

#align(center)[
  #image("assets/07/AP.png", width: 50%)
]

Il livello MAC, con la *Point Coordination Function* (PCF), offriva servizi *asincroni* oppure *time-bounded*, con questi ultimi che non erano presenti in *DCF*. Infatti, il random backoff distrugge le garanzie dei time-bounded.

Abbiamo quindi un *AP* che controlla l'accesso al canale radio:
+ tutto il traffico passa per l'AP;
+ le stazione associate ad un AP usano DCF con tempistiche SIFS e DIFS per accedere al canale quando AP non usa la PCF;
+ AP usa invece PIFS.

In questo modo l'AP riesce ad *impossessarsi* del canale radio prima delle stazioni in attesa. Usiamo PIFS così che non ci buttiamo in mezzo ad ACK, RTS e CTS, ma siamo comunque prima di DIFS.

==== Superframe

// controlla
L'AP manda dei *messaggi periodi*, ogni $10"-"100$ secondi, detti *beacon frame*, che sono *frame di gestione* per:
+ parametri operativi al *livello fisico*, come bit race e MCS;
+ *sincronizzazione*, usato con FHSS nelle prime versioni;
+ supporto a *PCF* con le relative informazioni;
+ invito per le nuove stazioni che non si sono ancora associate.

L'intervallo tra due beacon è detto *superframe*, ed è diviso in due parti:
+ periodo senza contesa (*PCF*), opzionale, dove abbiamo le time-bounded e siamo contention-free;
+ periodo con contesa (*DCF*), sempre presente, dove abbiamo il contention period.

#align(center)[
  #image("assets/07/superframe.png", width: 70%)
]

Come vediamo, il frame è molto simile a $802.15.4$, ma abbiamo i due periodi invertiti. Inoltre, come vediamo, possiamo *sforare* la fine del superframe e trasmettere nella zona del beacon successivo, a patto di ridurre un pelo la durata del successivo superframe.

Il periodo senza contesa inizia con l'AP che attende *PIFS*, prende il lock del canale e decide come trasferire le *DDU* (DownStream Data Unit), mentre gli altri attendono sempre un tempo *SIFS* prima di rispondere con le *UD* (Uplink Data).

#align(center)[
  #image("assets/07/contention_free.png", width: 70%)
]

A fine comunicazione, l'AP manda un *CF-end* per indicare la fine del periodo contention-free. I nodi che non avevano niente da comunicare hanno allocato un *NAV* per aspettare.

==== Frame

#align(center)[
  #image("assets/07/frame.png", width: 70%)
]

Il *frame* indica alle stazioni una serie di informazioni importanti:
+ *Frame Control* (FC), che indica la versione del protocollo, il *tipo*, il *sottotipo*, *toDS*, e *fromDS*;
+ *Duration ID* (DI), che indica quanto dura la comunicazione
+ una serie di *indirizzi*.

Come vediamo, leggendo i primo $10$ byte noi sappiamo già se i frame ricevuti sono per noi oppure no. I blocchi *rossi* sono sempre presenti, mentre i blu dipendono dal tipo di frame.

Nel *campo type* abbiamo la tipologia del frame:
+ $00$ se abbiamo un *management frame* (gestione);
+ $01$ se abbiamo un *frame di controllo*;
+ $10$ se abbiamo un *data frame*.

Nel *campo subtype* indichiamo il contenuto specifico del frame in base al suo tipo. Ad esempio, il beacon ha come codici $00$ e $1000$.

Nei frame di controllo abbiamo i frame:
+ RTS e CTS;
+ ACK;
+ CF-end e CF-end + ACK, che è usato per mandare contemporaneamente un ACK all'ultimo nodo prima della fine della fase contention-free.

==== Indirizzamento

Un frame può contenere fino a $4$ *indirizzi*. Il loro utilizzo dipende dai campi *toDS* e *fromDS*. Ogni indirizzo è formato da $6$ byte perché sono degli *indirizzi MAC*.

Abbiamo vari casi.

Se abbiamo *toDS* e *fromDS* pari a $0$ siamo nel caso più semplice perché siamo nella stessa cella. Il primo indirizzo è il *destination address* (MAC), il secondo indirizzo è il *source address* (MAC) e il terzo indirizzo è il *BSSID* della cella. Qua il *DS non interviene*, visto che siamo in reti ad-hoc oppure in una cella singola.

Se invece siamo negli altri casi abbiamo il passaggio nel *sistema distribuito* e dobbiamo fare del *routing* per spostarci da una cella all'altra.

Se abbiamo *toDS* $0$ e *fromDS* $1$, il primo indirizzo è il *destination address* all'interno della cella, il secondo indirizzo è il *BSSID* della cella in cui si trova la destinazione e il terzo indirizzo è il *source address* (MAC). Usiamo questa configurazione quando un AP riceve un messaggio dal DS e lo deve inoltrare nella propria cella.

Se abbiamo *toDS* $1$ e *fromDS* $0$, il primo indirizzo è il *BSSID* della cella di destinazione, il secondo indirizzo è il *source address* (MAC) e il terzo indirizzo è *destination address* (MAC). È il contrario della configurazione precedente, quindi un AP che riceve questo frame e lo deve mandare nel DS.

Se abbiamo *toDS* e *fromDS* pari a $1$ siamo proprio nel DS. Il primo indirizzo è l'indirizzo dell'*AP destinazione* nel DS, il secondo indirizzo è l'indirizzo dell'*AP sorgente* nel DS, il terzo indirizzo è il *destination address* (MAC) e il quarto indirizzo è il *source address* (MAC).

Le singole stazione *non* sanno dell'esistenza di altre celle: infatti, sono gli AP che creano e gestiscono gli ultimi tre frame per il DS.

=== OFDMA

Da Wifi $6$ in poi si è passati dal semplice *OFDM*, usato per creare più canali ortogonali in frequenza, a *OFDMA*, che dice anche come assegnare queste sotto-portanti a più utenti.

Infatti, OFDM prima divideva la banda in *canali* con frequenze differenti, ma erano assegnate tutte ad un solo utente. Ora vogliamo assegnare *gruppi di canali* ad utenti differenti.

#align(center)[
  #image("assets/07/OFDMA.png", width: 70%)
]

Come vediamo, nella prima tabella con *OFDM* non usiamo molto bene i time slot a nostra disposizione, visto che non tutti gli utenti hanno le stesse esigenze, mentre nella seconda tabella con *OFDMA* sfruttiamo al massimo la banda.

In WiFi $6$ si usano sotto-portanti separate da $78.125"k"hertz$, che hanno dei simboli di lunghezza maggiore rispetto a quelle di WiFi $4$. Vengono inoltre definite le *Resource Unit* (RU), ovvero gruppi di frequenze -- solitamente adiacenti -- allocabili ad un utente.

La dimensione delle RU è *variabile* e dipende dalla banda disponibile e da come l'AP vuole allocale le risorse agli utenti.

#align(center)[
  #image("assets/07/RU.png", width: 70%)
]

In questo esempio, con una banda da $20"M"hertz$ abbiamo $256$ sotto-portanti. Alcune di queste sono adibite ai *pilot*, che guidano la *sincronizzazione* con il ricevitore. Le altre sono invece frammentate scegliendo un blocco a sinistra e uno a destra, così da non sovrapporre le sotto-portanti.

L'*AP* usa dei frame di controllo per comunicare la divisione della banda, l'associazione delle RU e la gestione del traffico *DownLink* (DL) e *UpLink* (UL). Questi frame di controllo sono nuovi, definiti apposta per queste funzionalità, oppure sono già presenti nello standard e sono stati riutilizzati.

#align(center)[
  #image("assets/07/tabella.png")
]

Ogni RU ha un codice univoco, il *RU allocation bits*. Quando una stazione riceve un certo ID sa già quali sotto-portanti dovrà utilizzare. Ovviamente, se allochiamo un certo quadrato di questa tabella, quelli direttamente sopra non possono essere utilizzati.

=== Downlink

Vediamo il traffico *DL* dagli AP ai dispositivi.

#align(center)[
  #image("assets/07/DL.png", width: 70%)
]

Il nostro AP conosce le stazioni a cui vuole mandare i messaggi. Dopo un periodo *AIFS* (Arbitrary Inter-Frame Spacing, più di SIFS e meno di DIFS) l'*AP* prende il lock del canale e manda un *MultiUser RTS* (MU-RTS), che fa da *trigger* alle stazioni. In questo messaggio sono indicate le *RU* delle singole stazioni, e su questi canali le stazioni rispondono con dei CTS *in contemporanea* dopo un periodo SIFS, visto che conoscono le loro RU.

Ora, l'AP attende SIFS e manda un *MultiUser-DownLink-PPDU*, in parallelo sui vari canali, alle varie stazioni con le quali l'AP deve comunicare.

Dopo un altro SIFS si manda una *Block ACK Request* (BAR) per sincronizzare l'invio di ACK da parte delle stazioni, che arrivano dopo un SIFS dopo il BAR.

=== Uplink

Vediamo ora il traffico *UL* dai dispositivi all'AP. Questa comunicazione è leggermente più complessa della trasmissione DL.

#align(center)[
  #image("assets/07/UL.png", width: 70%)
]

Nel traffico *UL* abbiamo *tre trigger*:
+ dopo un tempo AIFS l'*AP* manda un *Buffer Status Report Poll* (BSRP), che chiede alle stazioni se hanno dei dati da trasmettere. Le stazioni rispondono *in contemporanea* dopo un SIFS, visto che nel BSRP erano presenti anche le RU sulle quali rispondere;
+ l'*AP* ora ha tutte le informazioni sulle stazioni, cosa devono mandare e quanto. Dopo un tempo SIFS l'*AP* manda un *MultiUser-RTS*, con dentro una *nuova allocazione RU* basata sulle preferenze date. La risposta delle stazioni avviene dopo un SIFS ancora *in parallelo* con un CTS;
+ dopo un tempo SIFS l'*AP* manda un trigger per sincronizzare tutte le stazioni. In questo momento, dopo un altro SIFS, tutte le stazioni rispondono con il traffico *UpLink-PPDU* (UL-PPDU) *in parallelo*.

Come vediamo, la comunicazione parte sempre dall'*AP*, e finisce anche con lui mandando un *MultiStation Block ACK*.

=== Canali

Le sotto-portanti sono all'interno di *canali*. Ovviamente, i canali fanno *overlapping*, quindi se comunichiamo in canali che sovrappongono possiamo avere dei problemi.

#align(center)[
  #image("assets/07/banda_01.png")
]

L'idea è avere tanti canali e scegliere tra questi quelli che non si sovrappongono, formando spesso delle *triple ortogonali*. Il canale scelto per la comunicazione è indicato nel beacon.

In poche parole, scegliamo il canale, in base alla congestione, dividiamo in sotto-portanti e trasmettiamo.

Nell'immagine precedente abbiamo i canali della banda $2.4"G"hertz$, mentre nell'immagine successiva abbiamo i canali della banda $5"G"hertz$.

#align(center)[
  #image("assets/07/banda_02.png")
]

=== Security

Il canale radio è *esposto* per natura: tutti ascoltano e inviano, quindi il canale è naturalmente broadcast. Si ha la necessità di *cifrare il canale* a livello data link.

==== Storia

Una prima versione di sicurezza si aveva con *Wired Equivalenti Privacy* (WEP), anche se abbastanza fallimentare:
+ usava RC4 per cifrare ma era *opzionale*;
+ non aveva un sistema di gestione delle chiavi;
+ veniva usata un'*unica chiave* per cifrare tutti i dispositivi;
+ tutto il traffico veniva cifrato con la *stessa chiave*.

La password non era quella del WiFi, ma era derivata da quella.

Questo era un grande problema: una volta dentro la cella si poteva ascoltare tutto.

Per sopperire alle lacune di WEP si passa all'emendamento $802.11i$ che definisce la sicurezza per tutto il protocollo $802.11$.

Viene definita una *Robust Security Network* (RSN).

#align(center)[
  #image("assets/07/sicurezza.png", width: 70%)
]

Abbiamo tre parti importanti:
+ *access control*, che si basa sul protocollo $802.1$ per il *controllo degli accessi* e l'assistenza allo scambio delle chiavi;
+ *autenticazione e generazione delle chiavi*, che si basa sul protocollo *Extensible Authentication Protocol* (EAP) per definire lo scambio tra utente e *Authentication Server* (AS) e generare le chiavi temporanee per la comunicazione sul canale radio;
+ *privacy e integrità dei messaggi*, che cifra il payload MAC e aggiunge un controllo di integrità; vedremo i protocolli dopo.

Vediamo come funzionano le varie fasi delle operazioni.

#align(center)[
  #image("assets/07/fasi_sicurezza.png", width: 70%)
]

==== Discovery

Nella fase di *discovery* non siamo ancora nella parte di sicurezza, ma tramite beacon un AP annuncia la sua presenza in *broadcast* per definire il BSSID della rete e i suoi servizi RSN disponibili.

Le stazioni ascoltano i beacon e capiscono quali sono i servizi RSN che possono utilizzare, creando un *match* tra servizio.

L'*associazione* avviene con un accordo sulla sicurezza da usare, che può anche non avvenire.

==== Autenticazione

Nella fase di *autenticazione* la stazione richiede -- appunto -- l'*autenticazione* direttamente all'AP della rete -- che fa anche da *AS* -- oppure ad un *AS* remoto, come fa ad esempio *Eduroam* che manda mail e password ad enti esterni per controllare.

Se il server è *remoto* si utilizza il protocollo *Extensible Authentication Protocol*.

La consegna delle chiavi avviene in modo sicuro, e si ha la generazione di una *master key*. Lo standard non descrive come avviene lo scambio, di quello si occupa il protocollo EAP.

==== Creazione e distribuzione delle chiavi

Nella fase di *creazione e distribuzione delle chiavi* vogliamo costruire una *chiave simmetrica* che parta dalla *master key*, condivisa tra AP e stazione. Questa master key è generata in qualche modo dalla password del WiFi oppure è fornita da un ente esterno.

Vediamo come avviene la generazione di una chiave.

#align(center)[
  #image("assets/07/chiave.png", width: 70%)
]

L'*AP* genera un *Nonce* -- *n*-umber used *once* -- che spedisce al client. Il *client* ora conosce:
+ MAC address proprio e dell'AP;
+ Nonce proprio (che genera ora) e Nonce dell'AP;
+ la master key.

Con questa quintupla genera una *chiave di sessione* $K_S$.

Il *client* manda il suo Nonce con un MIC -- *messaggio di integrità* -- all'AP, che ora può calcolare anche lui $K_S$.

La chiave di sessione è pronta, manca solo la *chiave di gruppo* $K_G$ per tutte le stazioni nella cella. Questa viene mandata cifrata con $K_S$ dall'*AP* al client, che la decodifica con $K_S$.

Infine, il *client* manda un *ACK cifrato* con $K_S$.

==== Integrità dei messaggi

L'ultimo pezzo dello *stack RSN* riguardava la *confidenzialità* e l'*integrità* dei dati. Ci possiamo basare su due protocolli:
+ *TKIP*, implementato in *WPA*, che:
  + aggiunge un codice di integrità a $64$ bit calcolando usando il MAC sorgente e destinazione;
  + permette confidenzialità con l'uso di RC4;
  + cambia solo il software rispetto a WEP;
+ *CCMP*, implementato in WPA-2, che:
  + aggiunge un codice di integrità usando la cifratura Cipher-Block-Chaining (CBC);
  + permette confidenzialità ed integrità con AES a $128$ bit;
  + richiede una nuova implementazione hardware.

=== Eduroam

*Eduroam* (schifo):
+ ha come *SSID* "eduroam";
+ usa una Network Privacy basata su *WPA-2 Enterprise*;
+ ha due fasi di autenticazione tramite *Protected Extensible Authentication Protected* (PEAP) e *Microsoft Challenge-Handshake Authentication Protocol* (MSCHAPv2);
+ le credenziali sono la mail di ateneo e la propria password;
+ richiede il *certificato CA*.

=== WiFi Protected Setup

Finiamo con *WiFi Protected Setup* (WPS), che serve spesso nelle reti domestiche per fare l'associazione tra AP e dispositivi.

Abbiamo tre tipi di dispositivi:
+ *registrar*, che sono entità che autorizzano e revocano una stazione;
+ *AP*, Access Point;
+ *enrollee*, che è la stazione che vuole accedere alla rete.

Abbiamo due *modalità di attivazione* in-band (sul dispositivo):
+ *PIN*, dove l'enrollee deve inserire il PIN dell'AP o viceversa;
+ *push button*, dove si preme un bottone sull'*AP* e sull'*enrollee* per fare un'associazione FIFO.

// Slide 82 04_wifi.pdf
