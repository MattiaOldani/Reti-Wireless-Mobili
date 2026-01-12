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

= Lezione 24 [14/05]

== Comunicazione satellitare

Piano orbitale è il cerchio sul quale si muove il satellite, ed è dato rispetto ad un angolo che dista dall'equatore

Geometrie di un link satellitare:
- angolo di azimuth $alpha$ orientamento rispetto al nord geografico, in senso orario mi dice dove devo orientare la stazione di terra per poter ricevere il segnale (dove mi devo girare)
- angolo di elevazione $phi$ angolo rispetto all'orizzonte

Da questo deriviamo l'angolo di copertura, un angolo tridimensionale

Soprattutto nelle orbite Leo, il satellite va molto più veloce della terra. Se siamo sulla zenitale il satellite è sopra, distanza tra noi e il satellite minima, mentre massima quando abbiamo angolo di elevazione zero e il bro sta sparendo all'orizzonte

Questo implica che il mio delay di propagazione può variare moltissimo

Abbiamo elevato Jitter, ok predicibile, però varia molto durante la durata di connessione

Dobbiamo tenere conto anche di quanto perdiamo
- se sono praticamente raso ho effetto di assorbimento atmosferico, perché devo passarlo storto
- nebbia e pioggia assorbono, più lo attraversiamo più assorbiamo

Orbita GEO ha periodo 24h, visibilità permanente, angolo di elevazione fisso, elevata copertura, ma abbiamo qualità del segnale bassa per la distanza, ed elevato delay

Orbita LEO ha ridotto delay per orbita bassa, meno potenza di trasmissione e migliore utilizzo dello spettro, comunicazione ha handoff, garantisce la copertura 24/24h ma con tanti satelliti

Orbita MEO, ha minori handoff, ha tutti e due i pro e i contro

Non ci basta un solo satellite, le orbite LEO e MEO richiedono più satelliti per copertura continua e globale (o regionale)

Space segment ci sono i satelliti (e la costellazione), avendo anche comunicazione diretta tra satelliti (ottico anche, con laser)

Ground segment è la parte di controllo, con stazioni di terra e il gateway verso la rete

User segment sono sia fixed (parabole) oppure mobile, questi sono gli utilizzatori dei servizi

Come avviene la comunicazione satellitare: punto-punto passando dal satellite, copertura maggiore rispetto alla rete wireless terrestre, elevata banda, elevata potenza richiesta, delay elevato (i bro punto-punto non si vedono)

Molto comodo invece in broadcast[ing], perché copriamo area enorme e quindi possiamo mandare uno stesso messaggio a tantissimi ricevitori

Mesh tutti comunicano con tutti, ma ogni link passa tra satellite, non serve il gateway, non dobbiamo uscire dalla rete satellitare

Star non possiamo vedere il gateway quindi passiamo dal satellite

Mesh richiede un satellite che sappia fare routing

== NTN

Perché usare la rete satellitare con 5G e 6G?

Favorire il lancio di 5G e 6G in zone non densamente popolate, come aree rurali, aerei, navi; continuità di servizio; migliorare l'affidabilità della rete contro catastrofi naturali; aumentare la scalabilità della rete.
