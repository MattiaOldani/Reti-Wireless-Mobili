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

= 2G e 3G

Vediamo la breve storia di questi due protocolli.

==== 2G

*2$G$*, o GSM, viene creata negli anni $'90$ e permette di trasmettere la *voce digitale* riusando gran parte della tecnologia usata per la telefonia fissa. Le modifiche sono avvenute principalmente *lato software*.

Oggi questo protocollo è addirittura *virtualizzato* su IP, così da essere trasparente al dispositivo e non impattante nelle operazioni della rete.

*Global* di GSM indica che sono stati creati molti *standard*, che però non scrivo.

La *radio* usa *FDD* usando due bande attorno ai $900"M"hertz$, grandi $25"M"hertz$ l'una e divise in $125$ canali da $200"k"hertz$.

Questo è perfetto per la *voce in mobilità*.

Viene utilizzato il *cell sectoring*, con una copertura teorica di $35$ chilometri, che diventano $15$ nella realtà se siamo fuori città. Questo valore diminuisce di molto se densifichiamo la zona.

Il *Multiple Access* avviene con:
+ *FDMA* andiamo a dividere la frequenza in canali, ma non tutti possono essere usati perché si potrebbero avere interferenze;
+ *TDMA* andiamo a dividere in tempo per gestire al massimo $8$ dispositivi.

/*
[59] Internet prende sopravvento, dovevamo inserirlo, servizi di dati volevano entrare in mobilità, si crea GPRS e ED for GSM evolution (GPRS ed EDGE, la E del dispositivo, prima top ora schifo)

Motivazioni: abbiamo investito tanto sulle BS, vogliamo introdurre dati su quello schema senza dover buttare via quello fatto, al massimo cambiamo parte CORE (software) e cambiamo i moduli
*/

// Slide 57 06_cellulare.pdf

/*
AGGIUNGI VECCHIA

[57] Questo è 2G, servizio traffico voce bidirezionale constant bit rate, veniva dato un canale e uno degli slot, sapevamo benissimo cosa trasmettere. Si trasmetteva compresso ma andava tutto benissimo.
*/

== Rete cellulare

=== GPRS ed EDGE

La rete GSM è perfetta per il *traffico voce*:
+ constant bit rate;
+ risorse pre-allocate e riservate;
+ delay costante;
+ nessun overhead per la segnalazione (no header, la posizione nello scheduling indicava se il canale era di dati o controllo);
+ tariffazione a durata.

Inoltre, la rete è idonea anche per gli *SMS*:
+ il servizio è delay tolerant come le mail, ovvero non ha sincronizzazione;
+ il contenuto è testuale semplice;
+ la tariffazione è per SMS.

Purtroppo, non siamo idonei per la *rete internet*, che ha un data rate variabile, è intermittente (facciamo cose ma sconnesse nel tempo) e a burst. Infatti, il circuit switch non è ottimale perché:
+ risorse pre-allocate sono inutilizzate per molto tempo;
+ allocazione fissa non compatibile con il traffico dati internet;
+ risorse non utilizzate sono sprecate e non utilizzabili da altri utenti.

In pratica *riserviamo* un percorso ma poi non lo usiamo.

La tariffazione inoltre non ha più senso, dobbiamo avere una *tariffazione a quantità*.

La rete *GPRS* è un *ibrido*, che permette di usare la *rete $2$G* ma aggiunge un *overlay* che riserva nell'accesso alcuni slot per il traffico dati. Sono stati però aggiunti dei *moduli core*.

Con questo abbiamo:
+ data rate per utente di $20"k"bps$ (sciocchezza) che sale a $270$ in *EDGE*;
+ tariffazione a volume di traffico, usando dei quanti di dati;
+ rilascio degli slot in IDLE;
+ ridotto il tempo della connessione internet da $20$ a $5$ secondi;
+ connessione logica non viene rilasciata, ma vengono rilasciati gli slot radio;
+ connessione logica indipendente da quella fisica, così che la mobilità o la perdita di copertura non interrompano la connessione.

==== Tunnelling

La connessione logica tra *MS* e *SGSN* è identificata da una sessione del protocollo *Packet Data Protocol* (PDP). L'MS è libero di muoversi nella rete con un *IP unico* che mantiene in tutta la sessione, ma visto che possiamo cambiare SGSN dobbiamo essere in grado di spostare il traffico nelle varie reti. L'indirizzo *IP* purtroppo non è più in grado, da solo, di gestire la mobilità.

Infatti, continuando a cambiare la rete, la rete core fa troppo traffico di controllo tra *paging* e *messaggi di aggiornamento*.

Con il *GPRS Tunnelling Protocol* (GTP) sappiamo che la rete tra il gateway e la RAN è praticamente sempre quella, ha una topologia nota. Usando un *descrittore* riusciamo a mappare il nostro IP sulla rete che va dal gateway alla RAN, così che durante un cambio ci basta cambiare un valore nel descrittore e non fare un sacco di traffico di controllo.

Quello che viene creato è un ulteriore livello nella rete core, che usa *UDP*, dentro cui abbiamo la nostra *sessione* che è descritta -- appunto -- nel *descrittore*.

#align(center)[
  #image("assets/02/tunnel.png", width: 70%)
]

Come vediamo, quello che succede è letteralmente un *incapsulamento*, un *tunnel sopra il livello di trasporto*, tutto *trasparente* all'utente.

=== UMTS

Passiamo alla rete *$3$G*, che voleva tenere il passo con la rete fissa, che era arrivata oltre i $56"k"bps$.

In mobilità vogliamo offrire:
+ $384"-"512"k"bps$ se andiamo a $120$ chilometri orari;
+ $2"M"bps$ se siamo a piedi.

Inoltre, abbiamo gestione senza interruzione tra celle UMTS e GSM/GPRS e una retro-compatibilità, quindi una *coesistenza* tra le varie reti.

Infatti, abbiamo un riuso della rete vecchia ma anche una nuova rete di accesso radio *UMTS Terrestrial Radio Access Network* (UTRAN), che:
+ definisce un nuovo modello di architettura delle BS;
+ definisce un nuovo concetto di canale radio, chiamato *Radio Access Bearer* (RAB), che permette di dare priorità, definire le QoS, eccetera;
+ utilizza CDMA;
+ passa ad una banda di $5"M"hertz$ per ogni canale.

La *rete core* invece rimane quella.

Inoltre, si crea una *forte separazione* tra funzionalità di segnalazione tra core e RAN:
+ *Access Stratum* (AS) ha le funzionalità di creazione di canali radio;
+ *Non-Access Stratum* (NAS) ha le funzionalità di dispositivi e rete core.

#align(center)[
  #image("assets/02/UMTS.png", width: 70%)
]

A sinistra in alto abbiamo la *rete $3$G*, sotto invece abbiamo la *rete $2$G*.

Abbiamo un *riuso totale delle frequenze* grazie a CDMA, che permette quindi latenze ridotte, resistenza a multipath-fading, privacy e un *sistema scalabile*.

#align(center)[
  #image("assets/02/CDMA.png", width: 70%)
]

Infatti, definiamo uno *Spreading Factor* per CDMA, che permette di scegliere quanti codici dobbiamo usare nella rete, scalando il data rate sul numero di utenti. Una soluzione alternativa è *dividere*, scalando in base alle richieste fatte, quindi assegniamo dei codici corti se ci serve data rate molto alto e viceversa.

Ovviamente, scegliamo dei nodi solo se da quel nodo alla radice non abbiamo selezionato altro.

In queste reti il canale radio è definito da dei *parametri*, mentre prima i canali erano definiti in base alle funzionalità e alla loro posizione nello scheduling, che erano statiche.

Ora, i canali vengono comunicati su richiesta/istanziazione e vengono definiti da:
+ classe del servizio;
+ velocità massima e garantita;
+ ritardo;
+ probabilità di errore.

Infine, se vogliamo avere *CDMA con codifiche superiori* abbiamo la rete *High Speed Downlink Packet Access* (*HSDPA/HSUPA*) che è praticamente $"H"^+$.

// Fine 06_cellulare.pdf
