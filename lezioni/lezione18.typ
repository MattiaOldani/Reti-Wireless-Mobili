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

= Lezione 18 [23/04]

La parte più complicata è la rete radio

In LTE abbiamo anche connessione diretta tra le BS, oltre a BS-MME, compiti locali tra le BS

Le BS vengono raggruppare in tracking area (location area), cluster, a ciascuno associamo gruppi di moduli di controllo

Interfaccia $X 2$ aggiunta perché:
- gestisce localmente l'handover
- funzionalità di load balancing e gestione delle interferenze
- mantenimento dello storico delle ultime celle visitare per gestire l'effetto ping pong

== Control plane

Tre moduli coinvolti (anche i due sopra a destra ma poco, non ci interessa)

BS è dual-stack:
- parla radio con UE
- parla TCP/IP con MME

Parte sinistra dello stack:
- RRC gestisce paging, mobilità (deciso handover) e garantisce QoS e raccoglie le misurazioni UE
- PDCP è convergenza tra IP e wireless e comprime gli header
- RLC gestisce i link radio (livello 2) che fa correzione errori, gestione ritrasmissione (rende livello 2 affidabile), segmentazione e riassemblaggio dei pacchetti dei livelli superiori
- infine MAC, gestione dello scheduler e dell'accesso al canale radio

Perché SCTP:
- TCP ha solo trasporto affidabile e in ordine (consegna solo affidabile?, ordine parziale?)
- head of line blocking problem
- TCP è stream oriented, marker messo dalle applicazioni per delimitare i messaggi
- supporto multi-homing mancante (percorsi alternativi)

HOL block problem

In TCP tra A e B tutto deve essere in ordine: non posso passare ai livelli applicazione se mi arrivano cose non in ordine

Il problema è questo: tutto il traffico da una BS verso MME viaggia su un solo flusso TCP (ci sono blocchi separati ma TCP lo vede come flusso unico)

[IMMAGINE]

Se perdo 3 problema, perché TCP blocca lo stream di quelli dopo, anche se non c'entrano nulla con il primo dispositivo

Soluzione: SCTP. Si cambia protocollo, si usa uno stream ID di 16bit. Abbiamo ordine parziale perché posso mischiare i vari stream, però dentro lo stream ho ordine totale.

Abbiamo una quadrupla più complessa

== User plane

GTP-U è GPRS Tunnelling Protocol in User Plane

EPS Bearer

Registrazione alla rete mi viene dato un default bearer
