// Setup

#set heading(numbering: none)

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


// Capitolo

= Introduzione

In questo corso tratteremo dei *dispositivi* che comunicano *wireless* (quindi senza *isolamento*) utilizzando almeno un *hop* ad un punto di accesso alla rete, detto *access point*.

Noi vedremo tre grandi tipologie di dispositivi:
+ *tecnologie a corto raggio*, come il *bluetooth*, che accettano un basso numero di dispositivi e sono indicati per l'uso estremamente locale;
+ *tecnologie wireless ma non mobili*, come il *Wi-fi*, che cerca di dare un alto data rate ma ha una bassa proprietà di *mobilità*;
+ *tecnologie wireless e mobili*, come la *rete cellulare*, che permette il roaming tra access point e la presenza di un alto numero di utenti senza che il servizio e la qualità del servizio cadano, a discapito però di un data rate più basso.

Grazie agli access point siamo in grado di collegarci ai *servizi cloud* ed *edge*, che nient'altro sono che servizi cloud spostati vicino all'utente.

#align(center)[
  #image("assets/00/evoluzione.png", width: 70%)
]

Nella foto precedente vediamo l'evoluzione della rete cellulare di decennio in decennio. In particolare possiamo dire che:
+ in *1G* sono state introdotte le chiamate analogiche in mobilità;
+ in *2G* nasce uno standard globale e si implementa la voce digitale;
+ in *3G* nasce effettivamente il mondo internet;
+ in *4G* viene usata una banda larga in mobilità;
+ in *5G* si ha la virtualizzazione della rete;
+ in *6G* vedremo un uso massiccio di AI e ML.

Nel tempo sono cambiati anche i *servizi*. Più andiamo avanti e più la rete si *specializza*: non esiste una soluzione che va bene per tutto, ma ogni tecnologia ha un particolare nel quale spicca.

Le reti wireless e mobili hanno tantissime applicazioni:
+ *IoT e smart city*, che tramite un elevatissimo numero di sensori ed attuatori, gestiti dalla rete, permettono di controllare il traffico e altri aspetti delle città;
+ *guida assistita e autonoma*, che usa reti Wi-fi o mobili molto rapide per permettere una response action quasi istantanea, non potendo cablare le macchine lol;
+ *smart factories*, o Industry 4.0, che hanno un loop simile al precedente.
