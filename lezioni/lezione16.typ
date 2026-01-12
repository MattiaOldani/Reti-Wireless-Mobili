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

= Lezione 16 [16/04]

Come aumentare la capacità per migliorare la scalabilità:
- aggiungere più canali e spettro
- prestito di frequenze dalle celle vicine, garantendo la gestione dinamica dell'assegnazione delle frequenze
- suddivisione in più celle densificando in aree con elevato traffico; un maggior traffico di controllo è richiesto per gestire gli utenti, con frequenti handoff (cambi di cella)

Il cell sectoring aumenta le antenne, passando da omnidirezionale a direzionale

Struttura è divisa in due:
- rete RAN
- rete core

Tutte le operazioni della rete cellulare sono automatiche e non richiedono interventi da parte dell'utente

Abbiamo due tipi di canali che trasportando due tipologie di traffico:
- canali di controllo, informazione per gestione delle operazioni, control plane
- canali di traffico, voce e dati, traffico dei servizio offerti all'utente, data plane

La divisione tra control e data plane è *esplicita*, divisione anche logica a livello della rete

== Operazioni

Fase di inizializzazione e monitoraggio segnale

Il dispositivo utente monitora i segnali delle celle per identificare quella migliore. Periodicamente ogni BS invia dei pilot che permettono al dispositivo di determinare la qualità del segnale di quella cella

Un dispositivo utente può iniziare una comunicazione:
+ disponibilità di canali radio con la BS
+ traffico di controllo per iniziare la comunicazione con MTSO
+ creazione dei "collegamenti" su data plane

MTSO non conosce sempre la posizione del dispositivo, ovvero la cella a cui è associato, perché potrebbe essere in idle (risparmio batteria e rilascio delle risorse per altri utenti): MTSO quindi contatta le BS delle celle per trovare il dispositivo. Questo è detto *paging*

Il dispositivo destinatario accetta la chiamata e MTSO crea un circuito (fino a 3G, da 4G c'è VoIP). Le BS impostano i canali radio data plane. Durante una chiamata i due dispositivi si scambiano informazioni attraverso le BS a cui sono collegate e MTSO

I dispositivi però possono muoversi al di fuori del raggio della cella nella quale hanno iniziato la comunicazione. Qua avviene handoff:
- decisione di nuova associazione
- gestione della nuova associazione
- riconfigurazione dei percorsi di comunicazione

Questo è *automatico* e senza interruzione della comunicazione (stando nei limiti della tecnologia)

Abbiamo anche altre operazioni:
- blocco della chiamata in caso di BS sovraccarica
- terminazione della chiamata
- interruzione della chiamata a causa di qualità segnale bassa
- gestione di chiamate tra rete fissa e mobile
- chiamate di emergenza

La rete cellulare vive in un contesto molto più dinamico e imprevedibile degli altri scenari wireless

Dobbiamo avere potenza del segnale:
- sufficiente per offrire un buon segnale
- non troppo per non creare interferenza
- variabile per via degli ostacoli (fissi e mobili)

Abbiamo anche fading (attenuazione del segnale):
- frequenza
- tipo di ambiente

Abbiamo la trasmissione radio line of sight (LOS). Il path loss è l'attenuazione del segnale radio in funzione della distanza tra trasmettitore e ricevitore, ed è $ P_t / P_r = (frac(4 pi, lambda))^2 d^n = (frac(4 pi f, c))^2 d^n $

Vediamo che è direttamente proporzionale alla frequenza (quadrato), direttamente proporzionale ad una potenza della distanza e $n$ dipende dall'ambiente

Gli operatori di rete mobile pianificano l'installazione delle BS per ottimizzare la rete. Operazione chiamata network planning

Bla bla bla

La procedura di handoff/handover consente di cambiare la BS a cui è associato. La procedura può essere decisa
- solo dalla rete (misurazione del segnale ricevuto dal dispositivo uplink)
- anche dal dispositivo (dispositivo da un feedback del downlink che riceve)

Ci sono diverse metriche per prendere una decisione:
- call blocking probability
- call dropping probability
- ...

[IMMAGINE]

Come decidiamo a quale BS mi devo collegare? Parametro principale è la potenza del segnale ricevuta a livello di BS

Mi associo alla BS che ha ul migliore segnale

Se sono in $L_1$ devo decidere, posso avere effetti ping-pong

Allora cambio se sono sotto soglia (il segnale non mi va più bene, ma se mi va bene perché cambiarlo lol) e ho un segnale migliore di prima, ma le soglie vanno definite con cura e dipendono da diverse condizioni di contesto

Ho comunque limiti: usiamo potenza relativi + isteresi. Ci basiamo sulla curva del segnale con un margine $H$: se sono maggiore cambio e risolvo il ping pong (RIVEDI BENE)

Ma ho ancora problema: il segnale di A può essere ancora buono

Uso isteresi e soglie, quindi mi baso sulla curva $H$ e con una soglia, quindi:
- A sotto soglia
- B > A con H

Abbiamo:
- hard handoff: solo una BS alla volta, cambio immediato, handoff veloci
- soft: entrambe le BS, rilascio quando un segnale è dominante, richiede più risorse

La gestione del duplex, con canali uplink e downlink, ha due modalità:
- FDD frequency division duplex che usa frequenze diverse per UL e DL, minore delay ma maggiori risorse per lo spettro
- TDD time division duplex, uso una sola frequenza per UL e DL, meno costi ma maggiore ritardo perché devo aspettare
