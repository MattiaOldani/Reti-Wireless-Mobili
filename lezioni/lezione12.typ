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

= Lezione 12 [02/04]

La banda del WiFi viene divisa in canali (quelli che scegliamo sull'AP), e ogni canale viene diviso in sotto-portanti con quello che definisce lo standard

Possiamo scegliere 3 canali che non sono sovrapposti: ad esempio, 1 6 11, oppure 3 8 13. Identificato il canale troviamo la nostra banda e lo spettro che copriamo

== Sicurezza in WiFi

Il canale radio è molto più esposto. Tutti ascoltano e inviano, quindi il canale è naturalmente broadcast. Inoltre, abbiamo la necessità di cifrare il canale a livello data-link

Prime versioni usavano WEP (Wired Equivalent Privacy):
- opzionale quindi lol
- algoritmo RC4 di cifratura
- assenza di un sistema di gestione delle chiavi
- unica chiave usata per cifrare tutto il traffico di tutti i dispositivi (chiave non password WiFi, ma ricavata da quello)
- tutto il traffico cifrato con la stessa chiave

Per sopperire alle lacune è stato introdotto un emendamento allo standard 802.11 detto 802.11i, che definisce la sicurezza del protocollo 802.11

[IMMAGINE]

Servizi offerti:
- access control: impone l'utilizzo dei protocolli di sicurezza e assiste lo scambio di chiavi
- authentication: definisce lo scambio tra utente e authentication server e genera le chiavi temporanee per la comunicazione
- privacy with message integrity: il payload MAC cifrati con aggiunta di un messaggio per il controllo dell'integrità

[IMMAGINE]

Abbiamo fasi:
- discovery: no cifratura, tramite beacon AP annuncia la sua presenza, STA ascolta e capisce quali servizi può usare leggendo dal beacon, associazione con accordo su che sicurezza utilizzare (anche negata se non si rispettano certi livelli);
- authentication e gestione chiavi: AS può essere anche nell'AP (ora sono collassate assieme, Eduroam no, gay), STA richiede ad AP l'autenticazione, che passa tramite un AS (esterno o meno), generazione delle chiavi in modo sicuro (master key, usata per generare tutte le altre che sono richieste in seguito). Come facciamo:
  - abbiamo la chiave di sessione e la chiave broadcast (usata per comunicare con tutti, non sto a cifrare ogni volta diverso, uso una chiave di gruppo)
  - generiamo nonce (number once, una sola volta)
  - cinque componenti (due numeri, mac address, master key che è psw wifi o generata da quella), generata dal client, che poi passa nonce all'AP
  - mando chiave di gruppo cifrando con quella di sessione, mando ack
- protezione dati: ho due alternative:
  - TKIP (WPA): integrità aggiunge un codice a 64 bit usando MAC dst e src, la confidenzialità si ha con RC4 e i cambiamenti sono solo software rispetto a WEP
  - CCMP (WPA-2): integrità fatta con cifratura cipher-block-chaining, confidenzialità con AES 128-bit per integrità e confidenzialità, nuova implementazione hardware

Il MIC è message integrity check

== Eduroam

SSID eduroam, ha privacy con WPA2 enterprise, fase1 di autenticazione è PEAP mentre fase2 è MSCHAPv2, le credenziali sono pazze e si ha un certificato CA con la sua chiave pubblica

WPS al posto di mettere la password andiamo a usare un PIN (vedi slide nuove)

== Ultimi WiFi

Con 802.11e si ha EDCA (Enhances Distributed Channel Access) parte con contesa, viene migliorata perché avevamo SIFS DIFS PIFS (e simili), ora per decidere le qualità di servizio si hanno dei parametri di accesso al canale:
- CWmin: congestion window minima, minima dimensione
- CWmax: congestion windows massima, massima dimensione
- AIFSN: numero di SIFS + N slot time (tempo di attesa, ma mai sotto il tempo di un AP)
- Max TXOP: massimo tempo nel quale una stazione può trasmettere più frame senza rilasciare il canale, per quanto tempo tengo il comando
