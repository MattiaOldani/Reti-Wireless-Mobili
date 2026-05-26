// Setup

#import "alias.typ": *

#import "@preview/tablex:0.0.9": colspanx, rowspanx, tablex

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
// Slide 17 06_cellulare.pdf

= Lezione 10 [20/02]

=== 2G e 3G

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
