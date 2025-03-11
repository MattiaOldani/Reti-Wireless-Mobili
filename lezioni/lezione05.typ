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

= Lezione 05 [11/03]

Multiplexing a livello fisico: ho 1 canale e lo divido in $n$ sotto-canali. A livello 2 invece ho il multiple access: permetto a più utenti di accedere contemporaneamente, è il livello MAC che, in base ai canali, vede cosa fare. Se voglio livello MAC devo avere il livello fisico

Finiamo spread spectrum: ci manca CDMA (Code division multiple access)

Data una sequenza di bit $D$, ogni bit della sequenza viene convertito in un insieme di $k$ chip usando un pattern prefissato detto codice. Un chip è una sequenza di 1 e -1. Vogliamo lo stesso data rate, quindi ci serve $k$ volte la banda. Ogni utente ha un codice diverso e produrrà chip diversi.

Abbiamo:
- sequenze Walsh: creano un insieme di codici ortogonali (sono in numero limitato, non interferiscono l'uno con l'altro)
- sequenze PN, Gold, Kasami: creano codici non ortogonali ma in un numero molto maggiore (permettono leggera interferenza)

Se trasmettiamo $1$ il codice rimane identico, se voglio trasmettere uno $0$ cambio ogni segno del codice.

Posso mandare tutto assieme, modulando comunque sulle varie portanti, ma posso tutto assieme e recuperare, con i codici, le varie cose. Come?

Noi sappiamo il codice e quanto è lungo. Calcoliamo $ S_u (d) = sum_(i = 1)^k d_i times c_i $ dove $d_i$ è quello ricevuto e $c_i$ è il codice.

Perché funziona? Perché se ho mandato un $1$ ho delle moltiplicazioni che sommano solo cose positive, e la somma vale $k$. Se invece ho mandato uno $0$ ottengo una somma $-k$. Quindi il bro che riceve, quando calcola moltiplicazioni e somme, deve ottenere $k$ per $1$ e $-k$ per $0$. Questo in quelli ortogonali. Se usiamo il codice di un altro utente devo ottenere 0 in quelli ortogonali, quindi so che non mi ha mandato dati un certo utente.

Se non sono ortogonali i codici, ottengo una cosa diversa da 0 se altro utente ma non è abbastanza alto per essere considerato corretto.

Che succede se ho un segnale combinato? CDMA mi permette di mandare tutti assieme senza problemi. Ad esempio se mandiamo in 2 abbiamo 2 0 -2 come valori possibili. Prendiamo il codice del primo, moltiplicazione+somma. Il risultato, se è più alto (non ortogonali) allora il bro ha mandato un $1$.

Più utenti vogliamo gestire, più il codice deve essere ampio

CDMA soffre del Near-Far problem, ovvero tutti trasmettono con la stessa potenza, gli utenti più lontani sono più difficili da interpretare. Quindi chi è lontano deve mandare più forte, ma consuma molta più batteria

== WPAN

ISM band [industrial, scientific and medical] è una porzione di spettro riservato per usi industriali, scientifici e medici

Ad esempio, il forno a microonde lavora a 2.45GHz, l'ipertermia oncologica (con altre tecniche) su 434MHz e 915MHz

Spettro usato senza licenza, agire senza interferenze

Inoltre, abbiamo il Pulse Code Modulation (PCM) ed è una codifica del segnale audio con due aspetti:
- frequenza di campionamento (per unità di tempo)
- numero di livelli di quantizzazione (do i bit)

=== Personal Area Network [bluetooth]

Siamo nelle wireless personal area network

Lo standard IEEE 802.15 comprende un insieme di tecnologie per la comunicazione a corto raggio

Bluetooth è .1 come codice. Abbiamo delle reti piconet (molto piccole), e all'interno della rete non c'è uguaglianza. Ovvero, un dispositivo fa da master e una serie di slave che sono sotto il controllo del master, controlla la piconet

Il bluetooth è short range (10-50m nei casi d'uso tipici e a seconda della classe di potenza del dispositivo). Usa la banda ISM 2.4 GHz. Ha un data rate di 2.1-24 Mbps (non pensato per elevato data rate). Utilizzato per:
- punto di accesso per dati e voce (dati limitati)
- sostituzione di cavi (no tastiere mouse ecc, es. periferiche wireless)
- comunicazione ad hoc con altri dispositivi BT

BLU: core protocols, ci sono in tutti i dispositivi BT, la parte del core, se uno è BT complaint ci devono essere

ROSSI/BLU SCURO: ci sono solo se quel dispositivo offre quel servizio

Partiamo dal basso

Bluetooth radio: specifica l'interfaccia radio, ovvero radio frequenze, gestione del frequency hopping, schema di modulazione e utilizzo della potenza di trasmissione

Baseband: livello banda base, si occupa di stabilire la connessione con la piconet, gestire l'indirizzamento (no MAC, specifico dello stato), formattazione di pacchetti, sincronizzazione e tempistiche di comunicazione (TDD & TDMA) e gestisce la potenza di trasmissione (indicazioni passate poi al tempo radio)

Link Manager Protocol (LMP) configura dei collegamenti tra dispositivi, gestione di collegamenti attivi e funzionalità di sicurezza e cifratura. Svolte un compito di controllo

Punto di rottura: sotto ho dentro il chip bluetooth, sopra ho software o firmware

Logic link control and adaptation protocol (L2CAP) adatta i protocolli di livello superiore al livello baseband e offre ai livelli superiori servizi connectionless e connection-oriented. Fa da interfaccia

Service discovery protocol (SDP) gestisce le info del dispositivo, tipo servizi disponibili, caratteristiche disponibili. Possiamo interrogare per stabilire connessioni tra dispositivi.

Radio frequency communication (RFCOMM) è una porta seriale che mi astrae il bluetooth per permettere la comunicazione. Bla bla bla vedi slide

Sopra abbiamo un sacco di robe, intende riutilizzare il maggior numero di protocolli esistenti. Lo standard Bluetooth specifica dei profili che indicano un particolare modello di utilizzo dell'architettura

Piconet & scatternet

Una piconet ha un master, degli active slave (AS) (membri arrivi della piconet) che hanno un active member address [AMA] di 3 bit (il master è 0). Quindi ho $2^3$ dispositivi disponibili, tolto il master, quindi max 7 active slave

I parked slave (PS) sono membri che devono aspettare che uno degli AS cambi stato e hanno un parked member address [PMA] su 8 bit (0 master) e quindi ho $2^8 - 1$ possibili

Ci sono poi i standby slave (SS), sono stati riconosciuti ma sono nel chill, senza indirizzo quindi numero infinito

La piconet è molto master-centrica: appartengo e mi coordino con il master, ma un dispositivo può stare in più piconet. Se un AS sta in più piconet otteniamo una scatternet. I due master sono entità separate, le due piconet sono totalmente indipendenti, ognuno per sé, ma una delle AS sta in entrambe le reti.
