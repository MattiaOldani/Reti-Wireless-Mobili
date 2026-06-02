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
// Slide 130 07_LTE.pdf

= Lezione 13 [02/03]

// Inizio 08_5G.pdf

=== Edge Computing e Network Softwarization

// IMMAGINE SLIDE 4

Per *$5$G* abbiamo una rappresentazione, fatta prima della standardizzazione, che rappresenta tutti gli intenti e casi d'uso che si volevano implementare. Queste sono incastonate in *classi di servizio*:
+ *Enhanced Mobile Broadband* (eMBB), che è l'evoluzione del $4$G, e presenta servizi orientati alle persone, con elevata banda, HD streaming e AV/VR;
+ *Ultra-reliable and Low-latency Communications* (uRLLC), che fornisce servizi orientati alle industrie, con bassissima latenza e affidabilità, come ad esempio il controllo remoto e la guida autonoma;
+ *Massive Machine Type Communications* (mMTC), utilizzando quando si ha una alta densità di connessioni, come nelle smart cities o smart agricolture.

// IMMAGINE SLIDE 5

In questa piramide abbiamo, nei vertici, questi tre tipi di servizi appena elencati, e nel mezzo abbiamo una combinazione di questi, a formare dei *servizi ibridi*.

Abbiamo quattro direzioni principali che rappresentano gli obiettivi del $5$G:
+ *maggiore efficienza spettrale*;
+ *maggiore spettro*;
+ *riuso spaziale*;
+ *softwarizzazione della rete*, permettendo una convergenza tra ICT e IT.

Le tecnologie principali introdotte in questa generazione sono:
+ *Software Defined Network* (SDN);
+ *Network Function Virtualization* (NFV);
+ *Centralized-RAN* (C-RAN) e *Virtual-RAN* (V-RAN);
+ *Mobile Edge Computing* e *Multi-access Edge Computing*;
+ *Network Slices*.

==== SDN

Nelle *SDN* abbiamo un *controller* che permette di configurare il traffico di controllo e dati: infatti, prima le regole di forwarding e gli algoritmi di controllo erano tutte nei dispositivi, mentre ora vengono mantenute solo le regole di forwarding mentre gli algoritmi di controllo sono all'interno del controller. Ora il controller, che conosce la rete, può avere una *visione globale* e scegliere al meglio il controllo da fare.

Le SDN si sono evolute nel tempo: prima veniva configurato solo il *control plane*, lasciando il data plane fisso, mentre ora possiamo fare anche il *data plane*, arrivando fino al *livello data link*.

L'utilizzo delle SDN porta numerosi vantaggi:
+ *flessibilità* nella gestione della rete;
+ permette una *visione centralizzata* della rete, ottimizzando il *routing* visto che avviene in un solo posto;
+ semplificazione della gestione a livello applicativo;
+ il testing e la configurazione di nuovi protocolli è più semplice e veloce.

Ovviamente abbiamo alcune sfide da superare:
+ il *controller* è il punto debole dell'architettura;
+ serve una *reazione realtime* ai cambiamenti;
+ *ottimizzazione* del numero di regole;
+ la sicurezza del controller è cruciale, visto che il controllo di quello permette il controllo della rete.

==== NFV

La *Network Function Virtualization* risolve un problema semplicissimo.

Quando compriamo l'attrezzatura paghiamo un occhio della testa le varie robe, ma magari ho una copia sola di tutto. Con questa configurazione la rete non decolla, oppure decolliamo, facciamo un successo gigante ma non possiamo *scalare* la configurazione.

L'idea delle NFV è quella di prendere il data plane, *separare* il software/firmware che implementa la funzionalità dei moduli dall'hardware e ne creiamo una versione VM o container. Ora abbiamo un HW standard sul quale io posso far girare quello che voglio in base alle esigenze.

Questo ci rende *flessibili e scalabili*, ma serve una descrizione della rete tramite *Service Function Chain* (SFC), che descrive dove e come sono implementati i servizi nella rete.

// SLIDE 37

Per fare questo ci aiuta il *NFV Orchestrator*: data una richiesta di deployment di un servizio, l'orchestratore riconosce quali sono i template necessari e si tirano su le istanze di quello richiesto nel luogo migliore.

Nel basso abbiamo l'*hardware*, sul quale si ha uno *strato di virtualizzazione*, che si chiama *NFV Infrastructure*. Sopra abbiamo le effettive *network functions*, con i vari *moduli EMS di controllo*.

Ancora più sopra abbiamo BSS e OSS, che si usano per gestire i servizi, assieme all'*NFV Management and Orchestrator* (MANO), che contiene:
+ *Virtual Infrastructure Manager* (VIM), che gestisce l'infrastruttura virtuale come risorse, CPU, link, eccetera;
+ *VNF Management* (VNFM), che controlla lo stato delle singole VNF, sa quando commissionare e de-commissionare istanze, eccetera;
+ l'*orchestratore*, che è quello che fa tutto, controlla VIM e VNFM, prende decisioni sul servizio richiesto e sullo stato dell'infrastruttura.

Con le NFV abbiamo a disposizione:
+ *flessibilità massima*, *scalabilità*, agilità della rete e dei servizi, anche nella gestione;
+ *indipendenza* tra hardware e software;
+ rapida prototipizzazione e introduzione di nuovi servizi, per operatore e utenti finali;
+ uso delle risorse ottimizzato e condiviso.

Come prima, sono presenti anche numerose sfide:
+ le *prestazioni* devono essere comparabili a quelle con hardware dedicato, visto che nelle NFV non abbiamo la stessa velocità dato l'overhead di virtualizzazione;
+ serve una *gestione efficiente delle risorse*, tramite orchestratore e VNF manager;
+ *sicurezza*;
+ gestione della fase di transizione in cui hardware e software coesistono;
+ *gestione multi-tenant*, ovvero si hanno più operatori di servizio che condividono le stesse risorse hardware e software.

==== Cloud

Infine, in $5$G abbiamo anche il *cloud*, che assieme a SDN e VNF formano quasi completamente tutta l'architettura di rete. Infatti, con le VNF noi mettiamo le varie parti dell'architettura dove vogliamo, e poi tramite SDN le colleghiamo.

// Slide 44 08_5G.pdf
