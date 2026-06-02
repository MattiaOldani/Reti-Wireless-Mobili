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

= WiFi

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

Vediamo lo *stack* del protocollo.

#align(center)[
  #image("assets/01/wifi.png", width: 60%)
]

Il livello MAC permette sia *DCF* (contention service) che *PCF* (contention-free service), in base alla presenza o meno di un AP. Il *Logical Link Control* (LLC) permette alla rete di usare i canali logici.

== Livello fisico

Vediamo le *specifiche fisiche* dei vari *emendamenti* di WiFi.

#align(center)[
  #image("assets/01/fisico.png", width: 70%)
]

Come vediamo, nel tempo i *canali* sono aumentati, si sono aggiunte *bande*, ma soprattutto i data transfer sono *cresciuti di bestia*. Notiamo anche una modulazione sempre più precisa, fino a $12$ bit per simbolo. Prima usavamo OFDM e DSSS, ora solo OFDM con anche OFDMA dalla versione $6$ in poi.

Il *LLC* offre dei *canali logici* con proprietà differenti:
+ *unacknowledged connectionless service*, che ha consegna non garantita, datagram indipendenti e nessun controllo di errori e di flusso;
+ *connection-mode service*, il suo opposto, con canali punto-punto, correzioni degli errori e controllo del flusso;
+ *acknowledged connectionless*, un mischione degli ultimi due, che manda datagram indipendenti ma con ACK.

Con il LLC noi possiamo parlare con reti che hanno un *livello fisico differente*.

#align(center)[
  #image("assets/01/LLC.png", width: 70%)
]

Questo si vede anche a livello di *pacchetti*: infatti, nel payload $802.11$ dobbiamo mettere un *sotto-frame LLC* con un codice che indica che tipi di canale stiamo usando.

== Livello MAC

Il *livello MAC*, avendo un canale radio molto più inaffidabile di una connessione cablata, ha un payload dei frame molto più grande.

Questo livello offre due servizi:
+ *servizio dati asincrono*, best effort e con delay variabile;
+ *servizio time-bounded*, che offre garanzie sul delay, ed è possibile solo in presenza di un *coordinatore*.

== DCF

Nelle *reti ad-hoc*, senza un AP, il livello MAX usa *CSMA/CA* per accedere al canale radio. L'accesso al canale radio deve essere regolato *aspettando del tempo*.

Abbiamo diversi tempi di attesa a seconda della tipologia di dati da trasmettere:
+ *slot time*, quantità base che tiene conto del ritardo di propagazione e del trasmettitore. Questo valore dipende dall'emendamento;
+ *Short Inter-Frame Spacing* (SIFS), intervallo breve di attesa usato per messaggi ad alta priorità, tipo quelli di controllo;
+ *DCF Inter-Frame Spacing* (DIFS), intervallo lungo di attesa usato per messaggi a bassa priorità best-effort, e vale $ DIFS = SIFS + 2 ST ; $
+ *PCF Inter-Frame Spacing* (PIFS), intervallo medio di attesa usato per i time-bounded, e vale $ PIFS = SIFS + ST. $

Vale quindi $ SIFS < PIFS < DIFS . $

Occhio che *SIFS* e *TimeSlot* sono valori indipendenti.

Vogliamo accedere al canale in *modo esclusivo*, cioè quando trasmettiamo noi tutti gli altri non lo stanno facendo. Inoltre, tutti i dispositivi nella stessa cella parlando sulla stessa banda di frequenza.

Quello che dobbiamo fare quindi è *Carrier Sense*: ascoltiamo il canale, e lo facciamo per un tempo pari a *DIFS*. Questo periodo è come un continuo *CCA*, quindi teniamo *sempre accesa la radio*. Se nessuno sta parlando posso iniziare a parlare subito.

#align(center)[
  #image("assets/01/no_ACK.png")
]

In questo caso, vediamo una comunicazione *senza ACK*. Come possiamo bene immaginare, se il frame arriva corrotto non abbiamo modo di saperlo.

Se ci viene richiesto l'*ACK* il sender deve aspettare un tempo *SIFS* prima di poter ritrasmettere: infatti, quando TX ha smesso di trasmettere tutti gli altri dispositivi si sono sincronizzati e stanno vedendo anche loro vuoto. Usando un tempo SIFS noi andiamo ad anticipare tutti gli altri, mantenendo il *lock sul canale*.

#align(center)[
  #image("assets/01/ACK.png")
]

Nel caso di *corruzione*, a livello di frame o ACK, allora il TX aspetta SIFS prima di spedire di nuovo. Viene fissato un *massimo numero di tentativi* per la trasmissione.

#align(center)[
  #image("assets/01/ritrasmissione.png")
]

Quando viene ricevuto l'*ACK* si libera il canale.

Quando troviamo il canale occupato sappiamo che *non siamo da soli*. Quando uno finisce di parlare siamo poi tutti sincronizzati al drop del segnale: qua siamo in un *periodo di contesa*, quindi serve un *random backoff* dopo un DIFS per *de-sincronizzarci* e vedere se ci sono *ACK*. Durante tutto questo random backoff noi eseguiamo il *Carrier Sense*.

#align(center)[
  #image("assets/01/backoff.png")
]

Se durante il *periodo di contesa* vediamo il canale occupato, quindi un bro ha avuto un backoff minore, abbiamo due opzioni:
+ annulliamo tutto e ripartiamo al prossimo ciclo di contesa, ma non è la soluzione migliore perché non è equa;
+ blocchiamo il timer e ripartiamo al ciclo successivo, quindi dovrò aspettare con meno probabilità.

#align(center)[
  #image("assets/01/occupato.png")
]

#line(length: 100%, stroke: 5pt + black)

#align(center)[
  #image("assets/01/soluzione.png")
]

Possiamo quindi permetterci di tenere sempre la radio accesa.

=== Terminale nascosto

Vediamo un piccolo particolare: *CSMA/CA* funziona se *TUTTE le stazioni* sono all'interno dello stesso *raggio di copertura*. Questo genera il *problema del terminale nascosto*.

#align(center)[
  #image("assets/01/terminale.png", width: 70%)
]

Questo problema avviene quando un nodo sente il *canale vuoto* ma in realtà ci sono altre stazioni che stanno trasmettendo.

Vediamo cosa succede con l'esempio precedente.

Abbiamo $A$ che vuole parlare con $B$ e $D$ che vuole parlare con $B$. Come vediamo, $A$ non vede $D$ e viceversa. Questo però è *pericoloso*: infatti, entrambi facendo Carrier Sense vedono il canale libero, e quando mandano il frame a $B$ lui ha una collisione.

#align(center)[
  #image("assets/01/collisione.png")
]

Risolviamo con un messaggio particolare, il *Request-To-Send* (RTS). Questo è un messaggio *Unicast* a livello MAC in cui si chiede l'*autorizzazione* per parlare con un certo dispositivo.

Vediamo quindi $A$ che manda una RTS, i nodi $C$ ed $E$ vedono questo messaggio, ma visto che non è per loro (Unicast) allocano un *Network Allocation Vector* (NAV) in cui spengono la radio e non ascoltano il canale per una certa *duration* contenuta nel frame, che indica la stima del tempo di comunicazione tra i nodi che vogliono parlare.

Ora $B$ riceve il frame, vede che è per lui, aspetta un tempo SIFS (breve, di controllo, per mantenere il *lock*) in cui fa Carrier Sense e manda un *Clear-To-Send* (CTS), che ricevuto *Unicast* da $A$ permetterà quindi la comunicazione. Come prima, i nodi che non devono comunicare allocano un NAV, stavolta più piccolo.

Questi messaggi non sono a *costo zero*: infatti, noi dopo DIFS potevamo trasmettere, invece usiamo RTS+CTS per evitare le collisioni. Questo si vede nell'*abbassamento del data rate*, visto che mandiamo solo bit di controllo, ma questo porta dei benefici enormi quindi ce lo accolliamo e bona.

In ambito veicolare RTS e CTS non sono usate perché non possiamo permetterci di aspettare del tempo, visto le richieste stringenti sull'immediatezza.

#align(center)[
  #image("assets/01/CTS.png")
]

Infine, una volta che $A$ ha ricevuto il CTS, aspetta SIFS per mantenere il *lock* del canale e poi inizia a trasmettere sul canale.

Nel caso $B$ abbia il canale occupato mentre riceve una RTS (ad esempio sta ricevendo altro) allora $B$ vede un *frame corrotto* ma si ritorna alla situazione di prima in cui l'altro dispositivo manderà a $B$ di nuovo.

Io sfigato che volevo parlare con $B$ aspetto, è scritto nello standard, io non lo so e Quadri in quel momento nemmeno.

Il canale radio è molto più *sensibile* ad interferenze e rumori. Il livello MAC frammenta quindi i frame in frammenti più piccoli, visto che già è probabile che ogni frame abbia errori.

Inoltre, avendo preso il canale con fatica, dobbiamo mantenerlo per mandare tutti i frammenti.

#align(center)[
  #image("assets/01/frammentazione.png", width: 70%)
]

== PCF

Passiamo ora alla rete che ha una *infrastruttura*. Ogni *AP* determina una *cella*, e un insieme di celle sono collegate tra loro tramite un *distributed system* (DS). Le singole celle hanno un *BSSID*, mentre il sistema distribuito si chiama *Extended Service Set* (ESS).

// sistema
AP può operare in PCF e DCF, perché AP ha anche la parte PCF dello stack, altrimenti ha solo la parte DCF

#align(center)[
  #image("assets/01/infrastruttura.png", width: 60%)
]

Come vediamo, abbiamo un minimo di *overlapping*, che è necessario per il *roaming*, ovvero per la *mobilità*. Ovviamente, in WiFi dobbiamo avere mobilità, ma non è un requisito diverso da quello dei dati mobili: infatti, WiFi è *nomade*, ovvero siamo fermi, ci spostiamo, e poi siamo ancora fermi.

La funzionalità di mobilità viene garantita dal modulo *LLC*.

In una rete con infrastruttura tutti i frame passando per l'*AP*, anche se essi vogliono comunicare due nodi solo tra di loro.

#align(center)[
  #image("assets/01/AP.png", width: 50%)
]

Il livello MAC, con la *Point Coordination Function* (PCF), offriva servizi *asincroni* oppure *time-bounded*, con questi ultimi che non erano presenti in *DCF*. Infatti, il random backoff distrugge le garanzie dei time-bounded.

Abbiamo quindi un *AP* che controlla l'accesso al canale radio:
+ tutto il traffico passa per l'AP;
+ le stazione associate ad un AP usano DCF con tempistiche SIFS e DIFS per accedere al canale quando AP non usa la PCF;
+ AP usa invece PIFS.

In questo modo l'AP riesce ad *impossessarsi* del canale radio prima delle stazioni in attesa. Usiamo PIFS così che non ci buttiamo in mezzo ad ACK, RTS e CTS, ma siamo comunque prima di DIFS.

=== Superframe

L'AP manda dei *messaggi periodi*, ogni $10"-"100$ secondi, detti *beacon frame*, che sono *frame di gestione* per:
+ parametri operativi al *livello fisico*, come bit race e MCS;
+ *sincronizzazione*, usato con FHSS nelle prime versioni;
+ supporto a *PCF* con le relative informazioni;
+ invito per le nuove stazioni che non si sono ancora associate.

L'intervallo tra due beacon è detto *superframe*, ed è diviso in due parti:
+ periodo senza contesa (*PCF*), opzionale, dove abbiamo le time-bounded e siamo contention-free;
+ periodo con contesa (*DCF*), sempre presente, dove abbiamo il contention period.

#align(center)[
  #image("assets/01/superframe.png", width: 70%)
]

Come vediamo, il frame è molto simile a $802.15.4$, ma abbiamo i due periodi invertiti. Inoltre, come vediamo, possiamo *sforare* la fine del superframe e trasmettere nella zona del beacon successivo, a patto di ridurre un pelo la durata del successivo superframe.

Il periodo senza contesa inizia con l'AP che attende *PIFS*, prende il lock del canale e decide come trasferire le *DDU* (DownStream Data Unit), mentre gli altri attendono sempre un tempo *SIFS* prima di rispondere con le *UD* (Uplink Data).

#align(center)[
  #image("assets/01/contention_free.png", width: 70%)
]

A fine comunicazione, l'AP manda un *CF-end* per indicare la fine del periodo contention-free. I nodi che non avevano niente da comunicare hanno allocato un *NAV* per aspettare.

=== Frame

#align(center)[
  #image("assets/01/frame.png", width: 70%)
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

=== Indirizzamento

Un frame può contenere fino a $4$ *indirizzi*. Il loro utilizzo dipende dai campi *toDS* e *fromDS*. Ogni indirizzo è formato da $6$ byte perché sono degli *indirizzi MAC*.

Abbiamo vari casi.

Se abbiamo *toDS* e *fromDS* pari a $0$ siamo nel caso più semplice perché siamo nella stessa cella. Il primo indirizzo è il *destination address* (MAC), il secondo indirizzo è il *source address* (MAC) e il terzo indirizzo è il *BSSID* della cella. Qua il *DS non interviene*, visto che siamo in reti ad-hoc oppure in una cella singola.

Se invece siamo negli altri casi abbiamo il passaggio nel *sistema distribuito* e dobbiamo fare del *routing* per spostarci da una cella all'altra.

Se abbiamo *toDS* $0$ e *fromDS* $1$, il primo indirizzo è il *destination address* all'interno della cella, il secondo indirizzo è il *BSSID* della cella in cui si trova la destinazione e il terzo indirizzo è il *source address* (MAC). Usiamo questa configurazione quando un AP riceve un messaggio dal DS e lo deve inoltrare nella propria cella.

Se abbiamo *toDS* $1$ e *fromDS* $0$, il primo indirizzo è il *BSSID* della cella di destinazione, il secondo indirizzo è il *source address* (MAC) e il terzo indirizzo è *destination address* (MAC). È il contrario della configurazione precedente, quindi un AP che riceve questo frame e lo deve mandare nel DS.

Se abbiamo *toDS* e *fromDS* pari a $1$ siamo proprio nel DS. Il primo indirizzo è l'indirizzo dell'*AP destinazione* nel DS, il secondo indirizzo è l'indirizzo dell'*AP sorgente* nel DS, il terzo indirizzo è il *destination address* (MAC) e il quarto indirizzo è il *source address* (MAC).

Le singole stazione *non* sanno dell'esistenza di altre celle: infatti, sono gli AP che creano e gestiscono gli ultimi tre frame per il DS.

== OFDMA

Da Wifi $6$ in poi si è passati dal semplice *OFDM*, usato per creare più canali ortogonali in frequenza, a *OFDMA*, che dice anche come assegnare queste sotto-portanti a più utenti.

Infatti, OFDM prima divideva la banda in *canali* con frequenze differenti, ma erano assegnate tutte ad un solo utente. Ora vogliamo assegnare *gruppi di canali* ad utenti differenti.

#align(center)[
  #image("assets/01/OFDMA.png", width: 70%)
]

Come vediamo, nella prima tabella con *OFDM* non usiamo molto bene i time slot a nostra disposizione, visto che non tutti gli utenti hanno le stesse esigenze, mentre nella seconda tabella con *OFDMA* sfruttiamo al massimo la banda.

In WiFi $6$ si usano sotto-portanti separate da $78.125"k"hertz$, che hanno dei simboli di lunghezza maggiore rispetto a quelle di WiFi $4$. Vengono inoltre definite le *Resource Unit* (RU), ovvero gruppi di frequenze -- solitamente adiacenti -- allocabili ad un utente.

La dimensione delle RU è *variabile* e dipende dalla banda disponibile e da come l'AP vuole allocale le risorse agli utenti.

#align(center)[
  #image("assets/01/RU.png", width: 60%)
]

In questo esempio, con una banda da $20"M"hertz$ abbiamo $256$ sotto-portanti. Alcune di queste sono adibite ai *pilot*, che guidano la *sincronizzazione* con il ricevitore. Le altre sono invece frammentate scegliendo un blocco a sinistra e uno a destra, così da non sovrapporre le sotto-portanti.

L'*AP* usa dei frame di controllo per comunicare la divisione della banda, l'associazione delle RU e la gestione del traffico *DownLink* (DL) e *UpLink* (UL). Questi frame di controllo sono nuovi, definiti apposta per queste funzionalità, oppure sono già presenti nello standard e sono stati riutilizzati.

#align(center)[
  #image("assets/01/tabella.png")
]

Ogni RU ha un codice univoco, il *RU allocation bits*. Quando una stazione riceve un certo ID sa già quali sotto-portanti dovrà utilizzare. Ovviamente, se allochiamo un certo quadrato di questa tabella, quelli direttamente sopra non possono essere utilizzati.

== Comunicazione

=== Downlink

Vediamo il traffico *DL* dagli AP ai dispositivi.

#align(center)[
  #image("assets/01/DL.png", width: 70%)
]

Il nostro AP conosce le stazioni a cui vuole mandare i messaggi. Dopo un periodo *AIFS* (Arbitrary Inter-Frame Spacing, più di SIFS e meno di DIFS) l'*AP* prende il lock del canale e manda un *MultiUser RTS* (MU-RTS), che fa da *trigger* alle stazioni. In questo messaggio sono indicate le *RU* delle singole stazioni, e su questi canali le stazioni rispondono con dei CTS *in contemporanea* dopo un periodo SIFS, visto che conoscono le loro RU.

Ora, l'AP attende SIFS e manda un *MultiUser-DownLink-PPDU*, in parallelo sui vari canali, alle varie stazioni con le quali l'AP deve comunicare.

Dopo un altro SIFS si manda una *Block ACK Request* (BAR) per sincronizzare l'invio di ACK da parte delle stazioni, che arrivano dopo un SIFS dopo il BAR.

=== Uplink

Vediamo ora il traffico *UL* dai dispositivi all'AP. Questa comunicazione è leggermente più complessa della trasmissione DL.

#align(center)[
  #image("assets/01/UL.png", width: 70%)
]

Nel traffico *UL* abbiamo *tre trigger*:
+ dopo un tempo AIFS l'*AP* manda un *Buffer Status Report Poll* (BSRP), che chiede alle stazioni se hanno dei dati da trasmettere. Le stazioni rispondono *in contemporanea* dopo un SIFS, visto che nel BSRP erano presenti anche le RU sulle quali rispondere;
+ l'*AP* ora ha tutte le informazioni sulle stazioni, cosa devono mandare e quanto. Dopo un tempo SIFS l'*AP* manda un *MultiUser-RTS*, con dentro una *nuova allocazione RU* basata sulle preferenze date. La risposta delle stazioni avviene dopo un SIFS ancora *in parallelo* con un CTS;
+ dopo un tempo SIFS l'*AP* manda un trigger per sincronizzare tutte le stazioni. In questo momento, dopo un altro SIFS, tutte le stazioni rispondono con il traffico *UpLink-PPDU* (UL-PPDU) *in parallelo*.

Come vediamo, la comunicazione parte sempre dall'*AP*, e finisce anche con lui mandando un *MultiStation Block ACK*.

=== Canali

Le sotto-portanti sono all'interno di *canali*. Ovviamente, i canali fanno *overlapping*, quindi se comunichiamo in canali che sovrappongono possiamo avere dei problemi.

#align(center)[
  #image("assets/01/banda_01.png")
]

L'idea è avere tanti canali e scegliere tra questi quelli che non si sovrappongono, formando spesso delle *triple ortogonali*. Il canale scelto per la comunicazione è indicato nel beacon.

In poche parole, scegliamo il canale, in base alla congestione, dividiamo in sotto-portanti e trasmettiamo.

Nell'immagine precedente abbiamo i canali della banda $2.4"G"hertz$, mentre nell'immagine successiva abbiamo i canali della banda $5"G"hertz$.

#align(center)[
  #image("assets/01/banda_02.png")
]

== Security

Il canale radio è *esposto* per natura: tutti ascoltano e inviano, quindi il canale è naturalmente broadcast. Si ha la necessità di *cifrare il canale* a livello data link.

=== Storia

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
  #image("assets/01/sicurezza.png", width: 70%)
]

Abbiamo tre parti importanti:
+ *access control*, che si basa sul protocollo $802.1$ per il *controllo degli accessi* e l'assistenza allo scambio delle chiavi;
+ *autenticazione e generazione delle chiavi*, che si basa sul protocollo *Extensible Authentication Protocol* (EAP) per definire lo scambio tra utente e *Authentication Server* (AS) e generare le chiavi temporanee per la comunicazione sul canale radio;
+ *privacy e integrità dei messaggi*, che cifra il payload MAC e aggiunge un controllo di integrità; vedremo i protocolli dopo.

Vediamo come funzionano le varie fasi delle operazioni.

#align(center)[
  #image("assets/01/fasi_sicurezza.png", width: 70%)
]

=== Discovery

Nella fase di *discovery* non siamo ancora nella parte di sicurezza, ma tramite beacon un AP annuncia la sua presenza in *broadcast* per definire il BSSID della rete e i suoi servizi RSN disponibili.

Le stazioni ascoltano i beacon e capiscono quali sono i servizi RSN che possono utilizzare, creando un *match* tra servizio.

L'*associazione* avviene con un accordo sulla sicurezza da usare, che può anche non avvenire.

=== Autenticazione

Nella fase di *autenticazione* la stazione richiede -- appunto -- l'*autenticazione* direttamente all'AP della rete -- che fa anche da *AS* -- oppure ad un *AS* remoto, come fa ad esempio *Eduroam* che manda mail e password ad enti esterni per controllare.

Se il server è *remoto* si utilizza il protocollo *Extensible Authentication Protocol*.

La consegna delle chiavi avviene in modo sicuro, e si ha la generazione di una *master key*. Lo standard non descrive come avviene lo scambio, di quello si occupa il protocollo EAP.

=== Creazione e distribuzione delle chiavi

Nella fase di *creazione e distribuzione delle chiavi* vogliamo costruire una *chiave simmetrica* che parta dalla *master key*, condivisa tra AP e stazione. Questa master key è generata in qualche modo dalla password del WiFi oppure è fornita da un ente esterno.

Vediamo come avviene la generazione di una chiave.

#align(center)[
  #image("assets/01/chiave.png", width: 70%)
]

L'*AP* genera un *Nonce* -- *n*-umber used *once* -- che spedisce al client. Il *client* ora conosce:
+ MAC address proprio e dell'AP;
+ Nonce proprio (che genera ora) e Nonce dell'AP;
+ la master key.

Con questa quintupla genera una *chiave di sessione* $K_S$.

Il *client* manda il suo Nonce con un MIC -- *messaggio di integrità* -- all'AP, che ora può calcolare anche lui $K_S$.

La chiave di sessione è pronta, manca solo la *chiave di gruppo* $K_G$ per tutte le stazioni nella cella. Questa viene mandata cifrata con $K_S$ dall'*AP* al client, che la decodifica con $K_S$.

Infine, il *client* manda un *ACK cifrato* con $K_S$.

=== Integrità dei messaggi

L'ultimo pezzo dello *stack RSN* riguardava la *confidenzialità* e l'*integrità* dei dati. Ci possiamo basare su due protocolli:
+ *TKIP*, implementato in *WPA*, che:
  + aggiunge un codice di integrità a $64$ bit calcolando usando il MAC sorgente e destinazione;
  + permette confidenzialità con l'uso di RC4;
  + cambia solo il software rispetto a WEP;
+ *CCMP*, implementato in WPA-2, che:
  + aggiunge un codice di integrità usando la cifratura Cipher-Block-Chaining (CBC);
  + permette confidenzialità ed integrità con AES a $128$ bit;
  + richiede una nuova implementazione hardware.

== Eduroam

*Eduroam* (schifo):
+ ha come *SSID* "eduroam";
+ usa una Network Privacy basata su *WPA-2 Enterprise*;
+ ha due fasi di autenticazione tramite *Protected Extensible Authentication Protected* (PEAP) e *Microsoft Challenge-Handshake Authentication Protocol* (MSCHAPv2);
+ le credenziali sono la mail di ateneo e la propria password;
+ richiede il *certificato CA*.

== WiFi Protected Setup

Finiamo con *WiFi Protected Setup* (WPS), che serve spesso nelle reti domestiche per fare l'associazione tra AP e dispositivi.

Abbiamo tre tipi di dispositivi:
+ *registrar*, che sono entità che autorizzano e revocano una stazione;
+ *AP*, Access Point;
+ *enrollee*, che è la stazione che vuole accedere alla rete.

Abbiamo due *modalità di attivazione* in-band (sul dispositivo):
+ *PIN*, dove l'enrollee deve inserire il PIN dell'AP o viceversa;
+ *push button*, dove si preme un bottone sull'*AP* e sull'*enrollee* per fare un'associazione FIFO.

== Emendamento 802.11e

Con l'*emendamento* $802.11$e, detto anche *Enhanced Distributed Channel Access* (EDCA), possiamo differenziare la *QoS* al livello data link. Infatti, questo emendamento propone *cinque* diverse qualità di servizio, che possiamo vedere nella prossima tabella.

#align(center)[
  #image("assets/01/qos.png", width: 70%)
]

Abbiamo quattro parametri configurabili, che sono la *minima/massima dimensione della contention windows*, un *numero arbitrario* di time slot da attendere -- da aggiungere a SIFS -- prima di poter trasmettere e il massimo *tempo di lock* che una stazione può mantenere sul canale.

Vediamo queste cinque *qualità di servizio*:
+ *background*, usato per traffico *best effort* senza priorità, e questo lo vediamo nella bassa probabilità di accedere al canale;
+ *best effort*, molto simile al traffico background ma con più priorità;
+ *video* e *audio*, usato con *priorità molto alta*, con la voce che ha più priorità del video. In questo caso abbiamo un classico tempo DIFS per accedere al canale, ma una volta che prendiamo il *lock* del canale possiamo tenerlo per un tempo massimo di circa $3$ *ordini di grandezza* superiore al time slot classico;
+ *legacy DCF*, che è un banale porting del QoS che abbiamo sui dispositivi vecchi.

== Emendamento 802.11p e WiFi veicolare

=== Protocollo

Con l'*emendamento* $802.11$p e *WAVE* (Wireless Access for Vehicular Environment) creiamo una *soluzione ad-hoc* per il *WiFi veicolare* su banda unlicensed.

Abbiamo una struttura *V2V*, ovvero *Vehicle to Vehicle*, che si differenzia dall'uso classico del WiFi, che invece non è dotato di chissà quale mobilità. In questo caso, invece, la mobilità è *padrona* della rete.

Questo emendamento è un'ottima *soluzione* per:
+ *reti altamente dinamiche* che sono *senza AP*;
+ supporto alla *guida autonoma*;
+ associazione veloce;
+ supporto per *servizi critici* come collisioni e pedaggi;
+ supporto infotainment.

In poche parole è una *Dedicated Short-Range Communication* (DSRC).

*WAVE* si basa sul livello fisico e MAC di $802.11$, mentre la sua vera implementazione avviene ai livelli più alti con il *WAVE Short Message Service Protocol* (WSMP).

Usiamo la *banda unlicensed* $5.9"G"hertz$, quindi fuori dalle bande domestiche, e usiamo canali da $10"M"hertz$, piccoli, ma tanto non dobbiamo mandare tanto. Abbiamo dei *canali di servizio* e *di controllo*. La *modulazione* è semplice, con *ridondanza maggiore*, vista la qualità molto bassa del canale.

WAVE inoltre prende in prestito il *miglioramento del livello MAC* introdotto nell'emendamento $802.11e$.

#align(center)[
  #image("assets/01/EDCA.png", width: 70%)
]

Qui vediamo lo *schema di contesa* del dispositivo. In base all'applicazione si scelgono i canali da utilizzare (controllo o dati), e ognuno di questi canali ha delle *code di priorità*, ognuna che gestisce uno dei quattro traffici definiti nella EDCA.

=== Platooning

*Platooning* è un sistema di *riduzione dei consumi di carburante* sfruttando l'*effetto scia*, permettendo un miglioramento del flusso di veicoli e della capacità stradale. In particolare, questo sistema va sotto la distanza di sicurezza per permettere di sfruttare la scia.

Per fare questa cosa bellissima ci serve del *coordinamento* tra i veicoli del *platoon*, quindi serve una legge di controllo -- per la segnalazione -- e una tecnologia wireless efficiente ed efficace.

Il progetto vuole costruire un *Cooperative Adaptive Cruise Control* (CACC).

Per ora abbiamo due *versioni*:
+ *PATH*, che vuole implementare la *Constant Distance Policy*, ovvero si cerca di mantenere costante la distanza che abbiamo tra i veicoli del platoon modificando la velocità. Per fare ciò ci servono i dati del nostro veicolo, di quello di fronte e del leader (quello davanti). Questo è molto simile ad un *sistema a molle*, nel quale non dobbiamo avere tensione;
+ *PLOEG*, che vuole implementare la *Constant Time policy*, ovvero si cerca di mantenere QUALCOSA CHE NON SO modificando l'accelerazione. Per fare ciò ci servono i dati del nostro veicolo e di quello di fronte. Come soluzione è più safe ma spreca più carburante.

Lo *standard* che viene usato è $802.11$p ma anche quello $802.11$bd, e su questi si è costruito lo standard *Dedicated Short-Range Communication* (DSRC)/ETSI ITS-G$5$.

La comunicazione avviene *broadcast* tramite *Cooperative Awareness Message* (CAM) contenenti le informazioni di stato del veicoli, quindi la sua *cinematica*.

#align(center)[
  #image("assets/01/messaggi.png", width: 70%)
]

Questi messaggi sono inviati ogni $100$ millisecondi.

Anche in questo caso abbiamo il *problema del terminale nascosto*, che però non viene gestito: infatti, abbiamo bassa latenza con *possibilità di collisione*, che cerchiamo di combattere con della *ridondanza*. L'accesso al canale è in DCF con tempo AIFS.

Abbiamo un piccolo problema però: l'*ultimo veicolo*, essendo troppo distante, *non riceve i dati del leader*, quindi la legge di calcolo non funziona più, viaggia a velocità costante e rimane lontano.

#align(center)[
  #image("assets/01/allontanamento.png", width: 70%)
]

Risolviamo questo problema obbligando i veicoli che ricevono i dati del leader a *ritrasmetterli*. Questo implica che il pacchetto dati sarà più grosso e ci sarà più delay, ma ce lo possiamo permettere.

#align(center)[
  #image("assets/01/grande_ritrasmissione.png", width: 70%)
]

Ovviamente, le leggi di controllo e simili sono calcolati quando il veicolo vuole, non abbiamo *sincronismo* tra i vari veicoli del platoon.
