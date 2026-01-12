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

= Lezione 22 [07/05]

Due release prima della 16 siamo ancora in LTE ma abbiamo già una separazione tra controllo e user

/* complotto UE e (R)AN */

Varie interfacce rimangono da user verso core e tra user. Quello che cambia è la comunicazione nella core network. Non abbiamo la punto-punto, ma abbiamo la service-based architecture: abbiamo delle API che vengono esposte, ognuna presente in tanti microservizi

Ogni modulo fa una cosa dando delle API, con un bus comune dove abbiamo produttori e consumatori di API

Ogni componente è una VNF che implementa un micro-servizio che espone delle API REST.

NRF (network repository function) permette di registrare servizi e renderli individuabili dalle altre network function

MME spezzato in tre;
- AMF (Access & Mobility Management Function) gestisce traffico di segnalazione per autenticazione, registrazione e mobilità (no controllo user plane, quindi no sessioni, no nuovi canali)
- SMF (Session Management Function) gestisce il traffico di controllo per la creazione di sessioni dati, dialoga con AMF per ricevere e inoltrare i messaggi di controllo. Comunica con UPF che è unico nodo core dello user-plane
- AUSF (Authentication Server Function) gestisce l'autenticazione e la generazione delle chiavi di cifratura

UDM (Unified Data Management Function) è il frontend dei database dei dati utenti

PCF (Policy Control Function) gestione e controllo delle politiche di accesso/mobilità in rete e di utilizzo dello user-plane

NSSF (Network Slice Selection Function) ci dice la slice migliore e consentita per un certo servizio richiesto, gestione della selezione della slice tra UE e quelle ammesse (UDM)

NEF (Network Exposure Function) e AF (Application Function) prima nella rete era ben visibile l'utente, in 5G per permettere di usare informazioni più fini possiamo esporre delle funzionalità e permette all'applicazione di rendersi visibile nella rete core
