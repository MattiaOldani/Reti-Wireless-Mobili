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
// Slide 45 08_5G.pdf

= Lezione14 [06/03]

/*
AGGIUNGI ALLA PARTE DI HANDOVER LOSSLESS

Io prendo e passo subito all'eNB destinazione, ha lui il buffer
*/

== 5G

=== NFV su RAN

Le *NFV* sono usate nella parte RAN, sull'eNodeB.

Per ora come architettura abbiamo due parti:
+ *Baseband Unit* (BBU), con operazioni di gestione dal *data link* in su;
+ *Remote Radio Head* (RRH), dove si ha l'antenna effettiva al *livello fisico*.

A noi serve *alimentazione*, *condizionamento* al calore per la BBU e un *alto carico computazionale*. Per fare ciò possiamo usare l'interfaccia X2 per ridurre le interferenze, ma questa ha una *limitata visione* dello stato degli altri eNodeB ed è *mono-standard*, ovvero lavoriamo solo 4G, mentre noi vorremmo avere un multi-RAT.

Un altro problema è la *densificazione*: con essa abbiamo una copertura più piccola ma localizzata, ma questo ci obbliga a replicare BBU e RRH ovunque.

L'uso delle NFV ci permette di avere una solo RRH (parte hardware) e un *pool di BBU remoto* (vBBU), collegato tramite cavo, che contiene tutta una parte software con i vari standard.

// SLIDE 48 FOTO

Con questo *datacenter* è possibile una *BBU multi-tecnologia*: infatti possiamo configurare tante vBBU quante ce ne servono in quel momento. Abbiamo comunque un limite, che è il *cavo*, che ce lo dà in capacità e tempo di propagazione: dobbiamo quindi mettere vicine le RRH con le vBBU, di solito entro i $10$ chilometri.

Abbiamo una serie di *vantaggi*:
+ *riduzione del CAPEX* (investimento di capitale), con una riduzione del numero di apparati e dei costi per introdurre nuove tecnologie RAT;
+ *riduzione dell'OPEX* (costo per fare funzionare), con un minore consumo energetico, l'ottimizzazione delle risorse BBU remote e la gestione dinamica della potenza delle celle;
+ *migliori prestazioni* con una migliore gestione delle interferenze e una densificazione delle celle più sostenibile;
+ possibilità di avere il *multi-RAT*.

=== Cloud/Edge computing

Il *Cloud Computing*:
+ offre una serie di servizi PaaS, IaaS, Saas, *QualsiasiCosaAAS*;
+ offre *scalabilità orizzontale* e dinamica;
+ riduce CAPEX e OPEX;
+ offre alta affidabilità e disponibilità;
+ permette ridondanza e repliche;
+ ha alti livelli di *virtualizzazione* e utilizzo hardware.

Nel cloud abbiamo infatti un *hardware standard* sul quale abbiamo *VM* e *container* ai quali accedono i vari utenti che usano la *rete internet*. Tra il cloud e gli utenti abbiamo gli ISP ma anche la *rete mobile edge* e la *rete mobile core*.

// SLIDE 57

Come scenario questo va bene, ma ha una elevata latenza, jitter e questo non ci permette di avere un controllo e una gestione ottima per le *near-real app*.

Infatti, due dispositivi che stanno comunicando sullo stesso livello devono passare necessariamente dal servizio cloud, e questo porta ai problemi appena presentati.

Arriva quindi l'idea del *Multi-access Edge Computing* (MEC ETSI), che vuole *avvicinare la computazione* che avviene nel cloud all'utente.

// SLIDE 62

In ciascun livello dell'architettura abbiamo una *rete geograficamente distribuita* che permette di avere della potenza di calcolo vicina all'utente. Ovviamente più andiamo verso il cloud e più abbiamo latenza e potenza di calcolo.

Per questo dobbiamo capire *dove* installare i vari moduli e anche capire come gestire la mobilità: questo dipende dai requisiti del modulo e dai link di comunicazione tra i moduli.

Abbiamo numerosi *vantaggi*:
+ l'architettura è decentralizzata e localizzata;
+ la latenza e il jitter end-to-end si riducono;
+ si riduce il traffico verso la rete core;
+ si ha un migliore supporto a servizi di location e context-aware.

Sono presenti anche numerose *sfide*:
+ integrazione nella rete per far coesistere MEC e lo standard 3GPP, e trasparenza di questo agli UE;
+ portabilità delle applicazioni MEC, con allocazione e de-allocazione trasparenti e architetture hardware e software standard e open;
+ sicurezza, che deve garantire isolamento tra le VM nei MEC server e deve controllare l'uso corretto delle risorse;
+ performance, che deve capire come dimensionare le VM e come allocarle in maniera ottimizzata all'interno della rete.

Vediamo come è questa parte dello *standard*.

// SLIDE 69

Abbiamo *tre livelli*:
+ *MEC system level*, che ha una visione globale su tutti i siti MEC, è centralizzato ed ha quindi una visione di sistema;
+ *MEC host level*, che è specifico per ogni singolo datacenter distribuito;
+ parte di rete, che è esterna allo standard.

Nel MEC host level abbiamo la *virtualization infrastructure*, che virtualizza l'hardware e le MEC applications, che sono VM o container.

=== Network Slices

Nel 5G abbiamo anche le *network slices*: queste sono una estensione del concetto di *radio bearer*. Prima in 3G avevano delle QoS, che poi in 4G sono state estese.

Ora, in 5G, abbiamo la possibilità di trasformare la rete da un *paradigma statico* (one size fits all) ad un *paradigma dinamico* nel quale le reti logiche sono create *on demand* con risorse e topologie ottimizzate per servire uno scopo specifico.

Una *network slice instance* è un insieme di network function fisiche e virtuali con risorse di rete che sono organizzate e configurate per fornire una rete logica che soddisfa certe caratteristiche.

// vedi se mettere slide

=== Architettura

Ci ricordiamo l'architettura di 4G, passiamo a quella del 5G.

// SLIDE 79

Volevamo una rete core che potesse funzionare anche con la *rete edge* e *cloud contemporaneamente*.

Vengono quindi creati dei PGW classici e dei PGW per edge, ma che sono chiamati nello stesso modo. Abbiamo infatti un solo modulo *User Plane Function* (UPF) che è connesso agli UE, e per fare la classificazione del traffico abbiamo un *Uplink Classifier* (ULCL), che appunto decide dove inviare il traffico dall'UE verso il cloud o la rete classica.

Gli UPF possono anche comunicare tra di loro tramite interfaccia N$9$.

Nella parte del *control plane* abbiamo una VNF per ogni componente, che comunicano tra loro tramite un *protocollo publish-subscribe* che si basa sulle API REST.

Abbiamo questo approccio perché non possiamo cambiare tutta l'architettura 4G e dobbiamo essere in grado di *riutilizzare*, non possiamo andare stand-alone.

==== Control plane

Vediamo qualche modulo nello specifico.

Il *Network Repository Function* (NRF) permette di registrarsi come entità nella rete, così che poi gli altri possono trovare e utilizzare il mio servizio tramite API.

L'*MME* viene diviso in:
+ *Access & Mobility Management Function* (AMF) che gestisce la maggior parte del traffico di segnalazione per autenticazione, registrazione e modalità. Inoltre, non gestisce la sessione dati;
+ *Session Management Function* (SMF) che gestisce appunto la sessione dati.

L'*Unified Data Management Function* (UDM) è un fronted unico per gestire i database.

Il *Policy Control Function* (PCF) è il vecchio PCRF e controlla le policy e chi può fare cosa.

L'*Authentication Server Function* (AUSF) gestisce tutto ciò che riguarda l'autenticazione e la generazione delle chiavi di cifratura.

Il *Network Slice Selection Function* (NSSF) gestisce la selezione delle slice tra UE e quelle ammesse, che sono contenute nell'UDM.

La *Network Exposure Function* (NEF) e la *Application Function* (AF) permettono alla rete e alle applicazioni/servizi esterni di dialogare tra loro esponendo le proprie funzionalità. In poche parole, permettiamo a servizi esterni di poter *entrare nella rete* dell'operatore tramite interfacce standard per fare alcuni funzioni come il controllo e la gestione degli accessi ai servizi.

// SLIDE 89

Nella prossima immagine vediamo anche l'evoluzione che abbiamo avuto dal 3G al 5G, vedendo un continuo *snellimento* dei vari plane.

==== User plane

L'architettura viene definita a *livelli*, che sono più semplici, visto che abbiamo un singolo *modulo UPF* e diverse istanze che possono dialogare tra loro.

Possono essere attive più data network contemporaneamente tramite *bearer*.

La classificazione avviene sono *Uplink* perché nel Downlink noi andiamo sempre verso l'UE, mentre in Uplink dobbiamo capire l'UE dove vuole mandare il pacchetto.

Vediamo brevemente un esempio di *Network Slices*.

// SLIDE 97

Come vediamo, sono molto eterogenee: ogni slice dice una tipologia di servizio che si vuole offrire, con le risorse che si possono mettere, e tramite VNF possiamo comporre il servizio di rete su quella risorsa.

// Slide 97 08_5G.pdf
