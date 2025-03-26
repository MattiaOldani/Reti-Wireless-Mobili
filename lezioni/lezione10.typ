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

= Lezione 10 [26/03]

Perché aspetto DIFS dopo che mi sono sincronizzato? Devo vedere se arriva l'ack [IMMAGINE1]

== Problema del terminale nascosto

Come funziona terminale nascosto

CSMA/CA funziona solo se tutti quelli che vogliono comunicare sono nel raggio

Soluzioni?

A chiede a B il permesso. Nel messaggio RTS (request to send) si mette il MAC del bro a cui voglio mandare e anche il mio. Network Allocation Vector (NAV) tempo trasmissione + "ack" viene messo dentro. Uno che riceve un frame non suo sa che deve aspettare tutto quel tempo, inutile che cerchiamo di accedere al canale.

Ora D e F non sanno quello. L'unico che fa la concessione è B: hanno richiesto me, se nessun altro ha richiesto di comunicare con me, mando il CTS (clear to send) con sorgente B destinazione A e ancora un tempo NAV (poco meno).

Il CTS viene sentito da A D F, cosi A inizia a trasmettere mentre D e F sanno che un altro nodo al di fuori del loro raggio di copertura vuole dialogare con B

Aspetto sempre SIFS per il CTS e per il primo frame da A a B

== Frammentazione

Permettiamo di frammentare in pezzi più piccoli, canale radio molto più sensibile all'interferenza e al rumore

Considerando la dimensione bla bla bla

== Infrastruttura

Vediamo la rete con infrastruttura: abbiamo qualcosa di più

Abbiamo:
- basic service set (BSS) insieme di stazioni controllate da un singolo coordinatore (AP) [una sola cella]
- extended service set (ESS) insieme di più BSS interconnessi tramite un sistema distribuito a livello LLC [eduroam]

Il portale è un router/bridge che collega il sistema distribuito alla LAN

ESS viene visto come un unico BSS a livello LLC per funzionalità di roaming tra AP diversi (overlapping per almeno $10%$ continuità)

In presenza di un AP tutti i frame passano per l'AP, non si fa ponte

Questa si chiama point coordination function, con servizi time-bounded possibili perché prima avevamo un backoff che non mi dava garanzie sul delay

Nella modalità PCF [AP] l'accesso point controlla l'accesso al canale radio:
- tutto il traffico passa da AP
- le stazioni associate ad AP usano DCF con tempistiche SIFS e DIFS per accedere al canale
- AP usa PIFS

Quindi AP si impossessa del canale prima delle stazioni in attesa

L'AP manda messaggi periodi (10-100s) detti beacon frame che sono frame di gestione:
- parametri operativi a livello fisico (bit rate e modulation coding scheme)
- sincronizzazione (usato nelle prime 802.11 che usavano FHSS)
- supporto a PCF con le relative informazioni
- invito per le nuove stazioni che non sono ancora associate

L'intervallo tra due beacon è detto superframe ed è diviso in 2:
- senza contesa (opzionale) ma necessario se vogliamo time-bounded, la gestisce tutta l'AP
- accesso a contesa (sempre presente), si usa CSMA/CA

Se canale radio è occupato oltre il limite del superframe questo tempo non verrà recuperato, si mangia tempo del pezzo dopo, molto più flessibili

Come funziona PCF

AP colleziona chi deve trasmettere cosa e a chi devono essere trasmettere cosa

Li raccolgo tutti e organizzo la trasmissione:
- devo allocare senza contesa
- inizio con canale occupato, smette, tutti iniziano con il CS, tutti aspettano DIFS mentre AP aspetta PIFS e prende il lock
- manda DDx con un NAV agli altri che non servono
- aspetto UDx se serve
- mando un CF end per dire fine del periodo contention-free

È un time division multiple access, con un tempo continuo
