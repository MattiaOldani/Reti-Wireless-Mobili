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

= Lezione 04 [05/03]

== Esercizi

Abbiamo SNR = 8 dB e un obiettivo che il canale deve garantire di BER = 10^-2 (sbagliare un bit ogni 100)

#set math.mat(delim: "[")

Abbiamo anche una tabella dei coding rate (k/n vedi Shannon) $ mat("SNR","BPSK","QPSK","16-QAM"; <6 d B, 0.6, 0.4, 0.2; 6-10 d B, 0.8, 0.6, 0.5; >10 d B, 0.9, 0.8, 0.7; augment: #(vline: 1, hline: 1)) $

Poi abbiamo un grafico con SNR sulle $x$ e BER sulle $y$, di solito in scala

I simboli al secondo sono 1000 syb/s

Noi siamo a 8 dB quindi siamo sulla linea centrale. Noi vorremmo un BER uguale a 10^-2, quindi scegliamo BPSK. La QPSK invece non va bene, faccio troppi errori. Guardando la tabella, selezioniamo 0.8 vista la zona e la codifica.

Facciamo quindi syb/s \* bit/syb \* CR [ad], ovvero $ 1000 dot 1 dot 0.8 = 800 "bit" slash s $

Se avessi chiesto 10^-1 prendevo anche QPSK, facevo conti e prendevo il migliore. Basta prendere tutto quello che è meglio di quello richiesto.

== OFDM [Orthogonal Frequency Division Multiplexing]

Abbiamo già visto TDM e FDM con divisione in frequenza e tempo in base al segnale.

La tecnica OFDM permette di inviare uno stream di bit usando frequenze differenti per inviare porzioni dello stream. Offriamo canali differenti usando una divisione in frequenza. Vogliamo garantire stesso data rate in TDD. Qua manteniamo fissa la banda ma garantendo lo stesso data rate Qui ho N stream paralleli, uno per ogni frequenza, e ho R/N bps di durata N/R. Stesso data rate in entrambi, ma qui abbiamo tanti sotto stream su tutte le frequenze disponibili

Come lo si implementa:
- dobbiamo fare una conversione seriale -> parallelo
- mandiamo R/N bit ad ogni frequenza diversa detta subcarrier (sotto-portanti)
- ogni stream viene modulato indipendentemente usando lo stesso schema di modulazione codifica MCS
- l'onda trasmessa è la combinazione di tutti i subcarrier modulati

Partiamo da una frequenza base e poi la spostiamo

Come troviamo la $f_b$? Nel caso di FDM classico viene lasciato uno spazio di guardia per evitare interferenze. In questo caso, i subcarrier sono ortogonali tra di loro e non interferiscono. La distanza tra i subcarrier è studiata in modo da evitare interferenze

Ortogonali non ho interferenze.

Come garantiamo l'ortogonalità?

La scelta dipende dalla durata del simbolo T, ovvero $ f_b = 1/T $ ovvero più il simbolo è breve e più devo distanziare, più il simbolo è lungo meno devo distanziare.

Considerazioni:
- più robusto riguardo ad interferenze che riguardano solo alcuni subcarrier; nel caso di sx rompe le palle a tutto, nel caso di dx solo un bit (o R/N) sarebbe interessato
- più robusto rispetto ai problemi di multipath perché la distanza tra un simbolo e l'altro è maggiore (inter-symbol interference (ISI) ridotto)

Multiple access: condividere il canale di comunicazione tra più utenti. In generale MA diverso da multiplexing. Ora abbiamo:
- TDMA slot temporali diversi
- FDMA frequenze diverse per gli utenti
- CDMA codificare l'informazione [3g e satellite]
- CSMA controllare il canale
- FHSS frequenze diverse saltando random
- OFDMA subcarrier [4g e 5g]

== Spread Spectrum

Spread Spectrum (spettro espanso) consiste nel trasmettere il segnale di informazione su uno spettro di frequenze più ampio di quella del segnale

Ho input, poi encoder, il modulator prende uno pseudonoise generator oppure uno spreading code (deciso), canale, de-modulatore e poi fine

Motivazioni:
- immunità a diversi tipi di rumore e distorsioni multipath
- utilizzato per nascondere e cifrare il segnale. Solo TX e RX sono a conoscenza del codice di spreading
- molti utenti possono usare indipendentemente la stessa banda più ampia con pochissima interferenza, usata da CDMA

=== Frequency Hopping Spread Spectrum

In FHSS il codice di spreading determina quale frequenza usare per trasmettere il segnale. Ad ogni intervallo di tempo prestabilito, la frequenza viene cambiata (Frequency Hopping). Sequenza nota a TX e RX

Ci si mette d'accordo su due parametri: ogni quanto fare hopping (anche pubblico) e pseudonoise bit source, il seed della sequenza da generare

Cosa possiamo dire:
- più resistente al rumore e al jamming
  - jamming su una frequenza compromette solo quella
  - jamming su tutta la banda spread ha meno efficacia
- un altro ricevitore che si sincronizza con il trasmettitore può solo leggere alcuni pezzi di messaggi perché non conosce la sequenza di frequency hopping

=== Direct Sequence Spread Spectrum

Data una sequenza di bit D, ogni bit della sequenza viene rappresentato da un insieme di bit usando un codice di spread

1 bit di informazione diventa da N ottenuti da una sequenza casuale

I bit della sequenza di spread sono più piccoli (durano 1/N dei bit di informazione) e sono denominati chip

Vogliamo mantenere lo stesso data rate, quindi abbiamo bisogno di N volte la banda utilizzata per l'informazione

#example()[
  Devo trasmettere D = 101 e ho un fattore $N = 3$. Per ogni bit di D uso 3 bit casuali. Faccio XOR (bit per ogni bit della sequenza) e poi mando.
]

Un bit di informazione va in xor con i bit del chip
