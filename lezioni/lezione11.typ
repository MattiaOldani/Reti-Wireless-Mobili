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

/*********************************************/
/***** DA CANCELLARE PRIMA DI COMMITTARE *****/
/*********************************************/
#set heading(numbering: "1.")

#show outline.entry.where(level: 1): it => {
  v(12pt, weak: true)
  strong(it)
}

#outline(indent: auto)
/*********************************************/
/***** DA CANCELLARE PRIMA DI COMMITTARE *****/
/*********************************************/

= Lezione 11 [01/04]

Beacon usati per scoprire una cella. Frequenza si configura sull'AP. Specificati i parametri di questa cella. Stazioni non presenti usano il periodo "contention period"

Formato del frame MAC: info principali sono messe come header, all'inizio
- in rosso tutto quello sempre
- in blu ci sono solo in certi tipi/sotto-tipi

Prim pezzo sono 2 byte FC di frame control:
- protocol version (versione usata del protocollo)
- tipo
- sotto-tipo
- toDS / fromDS verso il distributed system o da (celle del sistema distribuito), combinazione danno informazioni sugli indirizzi che ci sono
- MF more fragment (usato per riassemblare)
- RT rifare trasmissione
- PM attivo o no
- resto per sicurezza

Nei primi due byte abbiamo quindi protocollo e tipo del frame, quindi sappiamo poi cosa fare

Il secondo gruppo di due byte si ha la duration o la connection ID, qua ha lo durata del NAV

Poi abbiamo indirizzo destinazione (per chi è il frame, indirizzo MAC)

Quindi già in 10 byte sappiamo se questo è per noi o no

Vediamo frame control: ci sono tre tipi e sono per le tre macro funzionalità del sistema:
- $00$ management (gestione cella)
- $01$ controllo
- $10$ dati

Per una roba più specifica basta guardare il sottotipo

Il frame può tenere sino a 4 indirizzi, il loro utilizzo e significato dipende dai valori dei campi TO DS e FROM DS

Se non 00 devo fare routing tra celle

Se from DS il frame arriva dal DS verso un AP all'interno della cella che contiene un indirizzo segnato nel secondo indirizzo

Se 10 sto mandando al DS

Ultimo comunicazioni dentro il DS, unico caso in cui si hanno 4 indirizzi attivi

In wifi6 si usa OFDMA Orthogonal Frequency Division Multiple Access

OFDM suddivide la bandwidth in canali usando frequenze differenti opportunamente distanziate, che erano tutte per un singolo utente

Con OFDMA diamo gruppi di canali di OFDM a utenti differenti. Nello stesso momento posso servire più utenti.

Ci serve qualcosa in più nell'AP: prima davo tutte le frequenze a tutti, ora devo fare uno scheduling delle frequenze più complicato, tempo e frequenza da assegnare. Inoltre, serve definire quanto e in quale modo io posso raggruppare le sotto-frequenze

Ogni sotto-portante è separata da $78.125$ kHz

Abbiamo le resource unit (RU) gruppi di frequenze (solitamente adiacenti) che sono allocabili ad un utente

Dimensione RU variabile e dipende dalla banda disponibile e come AP vuole allocare le risorse agli utenti

Non tutta la banda viene usata: abbiamo intervalli di guardia. Inoltre, alcune sotto-portanti sono usate come pilot (bontà del canale). Segnale standard ben definito per correggere il canale e stimare quanto il canale è buono

Come comunico la suddivisione della banda?

AP utilizza frame di controllo, alcuni frame sono nuovi per supportare le nuove funzionalità, altri sono frame che erano già presente

Come associo le RU ai vari utenti?

Ad ogni trapezio si dà un indice di 7 bit, codice univoco

Assegnamento delle sotto-portanti di una RU sono esclusive per l'utente che le prende

Le informazioni di allocazione delle RU sono usate da PHY e MAC e vengono inviate

Come comunico quali sotto-portanti devono usare?

Come gestisco DL-OFDMA e UL-OFDMA (downlink da AP al disp e uplink viceversa)?

DL

Multi-user RTS che fa RTS e assegnazione delle RU per i dati che arriveranno. La RTS va alle stazioni che devono trasmettere, le altre allocano il NAV e non ascoltano. Ora che tutti hanno dei codici ortogonali, tutti rispondono con CTS paralleli, che essendo ortogonali non si sovrappongono mai

Dopo CTS possiamo trasmettere in parallelo, ogni stazione usa le frequenze dedicate e legge solo quello che interessa

Infine, si manca BAR (Block ACK request) con un block ACK da tutti in parallelo, sempre con un tempo SIFS per far finire l'AP di parlare (sta mandando in parallelo), non può ricevere se sta trasmettendo

UL

Un pelo più complicato, non è prevedibile se la rete è grande. Dobbiamo avere trasmissione sincronizzata e dire ad ogni utente quando trasmettere e dove

Più step:
- BSRP buffer status report poll, chiedo chi ha dati da trasmettere [primo trigger]
- BSR buffer status report, stazioni informano che hanno dei dati
- AP colleziona le richieste, assegna RU in base alle risposte e comunico con MU-RTS [secondo trigger]
- abbiamo il CTS da parte delle stazioni
- trigger per sincronizzare gli uplink e farli partire tutti assieme, così che AP riceva in blocco tutto (su risorse diverse) [terzo trigger]
- viene mandato UL-PPDU (con padding per arrivare alla durata massima)
- infine, se servono ACK si mandano Multi-STA Block ACK (multi-station)
