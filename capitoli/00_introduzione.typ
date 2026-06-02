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

In questo corso tratteremo dei *dispositivi* che comunicano *wireless* (quindi senza *isolamento*) utilizzando almeno un *hop* ad un punto di accesso alla rete, detto *Access Point*.

Noi vedremo tre grandi tipologie di dispositivi:
+ *tecnologie a corto raggio*, come il *Bluetooth*, che accettano un basso numero di dispositivi e sono indicati per l'uso estremamente locale;
+ *tecnologie wireless ma non mobili*, come il *Wi-fi*, che cerca di dare un alto data rate ma ha una bassa proprietà di *mobilità*;
+ *tecnologie wireless e mobili*, come la *rete cellulare*, che permette il roaming tra access point e la presenza di un alto numero di utenti senza che il servizio e la qualità del servizio cadano, a discapito però di un data rate più basso.

Nel tempo sono cambiati i *servizi*. Più andiamo avanti e più la rete si *specializza*: non esiste una soluzione che va bene per tutto, ma ogni tecnologia ha un particolare nel quale spicca.
