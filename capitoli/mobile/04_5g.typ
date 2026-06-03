// Setup

#import "../alias.typ": *

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

= 5G

Per *$5$G* abbiamo una rappresentazione, fatta prima della standardizzazione, che rappresenta tutti gli intenti e casi d'uso che si volevano implementare.

#align(center)[
  #figure(image("assets/04/standardizzazione.png", width: 60%))
]

Queste sono incastonate in *classi di servizio*:
+ *Enhanced Mobile Broadband* (eMBB), che è l'evoluzione del $4$G, e presenta servizi orientati alle persone, con elevata banda, HD streaming e AV/VR;
+ *Ultra-reliable and Low-latency Communications* (uRLLC), che fornisce servizi orientati alle industrie, con bassissima latenza e affidabilità, come ad esempio il controllo remoto e la guida autonoma;
+ *Massive Machine Type Communications* (mMTC), utilizzando quando si ha una alta densità di connessioni, come nelle smart cities o smart agricolture.

#align(center)[
  #figure(image("assets/04/piramide.png", width: 70%))
]

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

== SDN

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

== NFV

La *Network Function Virtualization* risolve un problema semplicissimo.

Quando compriamo l'attrezzatura paghiamo un occhio della testa le varie robe, ma magari ho una copia sola di tutto. Con questa configurazione la rete non decolla, oppure decolliamo, facciamo un successo gigante ma non possiamo *scalare* la configurazione.

L'idea delle NFV è quella di prendere il data plane, *separare* il software/firmware che implementa la funzionalità dei moduli dall'hardware e ne creiamo una versione VM o container. Ora abbiamo un HW standard sul quale io posso far girare quello che voglio in base alle esigenze.

Questo ci rende *flessibili e scalabili*, ma serve una descrizione della rete tramite *Service Function Chain* (SFC), che descrive dove e come sono implementati i servizi nella rete.

#align(center)[
  #figure(image("assets/04/orchestratore.png", width: 60%))
]

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

== Cloud

Infine, in $5$G abbiamo anche il *cloud*, che assieme a SDN e VNF formano quasi completamente tutta l'architettura di rete. Infatti, con le VNF noi mettiamo le varie parti dell'architettura dove vogliamo, e poi tramite SDN le colleghiamo.

/*
AGGIUNGI ALLA PARTE DI HANDOVER LOSSLESS

Io prendo e passo subito all'eNB destinazione, ha lui il buffer
*/

== NFV su RAN

Le *NFV* sono usate nella parte RAN, sull'eNodeB.

Per ora come architettura abbiamo due parti:
+ *Baseband Unit* (BBU), con operazioni di gestione dal *data link* in su;
+ *Remote Radio Head* (RRH), dove si ha l'antenna effettiva al *livello fisico*.

A noi serve *alimentazione*, *condizionamento* al calore per la BBU e un *alto carico computazionale*. Per fare ciò possiamo usare l'interfaccia X2 per ridurre le interferenze, ma questa ha una *limitata visione* dello stato degli altri eNodeB ed è *mono-standard*, ovvero lavoriamo solo 4G, mentre noi vorremmo avere un multi-RAT.

Un altro problema è la *densificazione*: con essa abbiamo una copertura più piccola ma localizzata, ma questo ci obbliga a replicare BBU e RRH ovunque.

L'uso delle NFV ci permette di avere una solo RRH (parte hardware) e un *pool di BBU remoto* (vBBU), collegato tramite cavo, che contiene tutta una parte software con i vari standard.

#align(center)[
  #figure(image("assets/04/vBBU.png", width: 60%))
]

Con questo *datacenter* è possibile una *BBU multi-tecnologia*: infatti possiamo configurare tante vBBU quante ce ne servono in quel momento. Abbiamo comunque un limite, che è il *cavo*, che ce lo dà in capacità e tempo di propagazione: dobbiamo quindi mettere vicine le RRH con le vBBU, di solito entro i $10$ chilometri.

Abbiamo una serie di *vantaggi*:
+ *riduzione del CAPEX* (investimento di capitale), con una riduzione del numero di apparati e dei costi per introdurre nuove tecnologie RAT;
+ *riduzione dell'OPEX* (costo per fare funzionare), con un minore consumo energetico, l'ottimizzazione delle risorse BBU remote e la gestione dinamica della potenza delle celle;
+ *migliori prestazioni* con una migliore gestione delle interferenze e una densificazione delle celle più sostenibile;
+ possibilità di avere il *multi-RAT*.

== Cloud/Edge computing

Il *Cloud Computing*:
+ offre una serie di servizi PaaS, IaaS, Saas, *QualsiasiCosaAAS*;
+ offre *scalabilità orizzontale* e dinamica;
+ riduce CAPEX e OPEX;
+ offre alta affidabilità e disponibilità;
+ permette ridondanza e repliche;
+ ha alti livelli di *virtualizzazione* e utilizzo hardware.

Nel cloud abbiamo infatti un *hardware standard* sul quale abbiamo *VM* e *container* ai quali accedono i vari utenti che usano la *rete internet*. Tra il cloud e gli utenti abbiamo gli ISP ma anche la *rete mobile edge* e la *rete mobile core*.

#align(center)[
  #figure(image("assets/04/cloud.png", width: 70%))
]

Come scenario questo va bene, ma ha una elevata latenza, jitter e questo non ci permette di avere un controllo e una gestione ottima per le *near-real app*.

Infatti, due dispositivi che stanno comunicando sullo stesso livello devono passare necessariamente dal servizio cloud, e questo porta ai problemi appena presentati.

Arriva quindi l'idea del *Multi-access Edge Computing* (MEC ETSI), che vuole *avvicinare la computazione* che avviene nel cloud all'utente.

#align(center)[
  #figure(image("assets/04/MEC.png", width: 70%))
]

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

#align(center)[
  #figure(image("assets/04/stack.png", width: 70%))
]

Abbiamo *tre livelli*:
+ *MEC system level*, che ha una visione globale su tutti i siti MEC, è centralizzato ed ha quindi una visione di sistema;
+ *MEC host level*, che è specifico per ogni singolo datacenter distribuito;
+ parte di rete, che è esterna allo standard.

Nel MEC host level abbiamo la *virtualization infrastructure*, che virtualizza l'hardware e le MEC applications, che sono VM o container.

== Network Slices

Nel 5G abbiamo anche le *network slices*: queste sono una estensione del concetto di *radio bearer*. Prima in 3G avevano delle QoS, che poi in 4G sono state estese.

Ora, in 5G, abbiamo la possibilità di trasformare la rete da un *paradigma statico* (one size fits all) ad un *paradigma dinamico* nel quale le reti logiche sono create *on demand* con risorse e topologie ottimizzate per servire uno scopo specifico.

Una *network slice instance* è un insieme di network function fisiche e virtuali con risorse di rete che sono organizzate e configurate per fornire una rete logica che soddisfa certe caratteristiche.

== Architettura

Ci ricordiamo l'architettura di 4G, passiamo a quella del 5G.

#align(center)[
  #figure(image("assets/04/architettura.png", width: 70%))
]

Volevamo una rete core che potesse funzionare anche con la *rete edge* e *cloud contemporaneamente*.

Vengono quindi creati dei PGW classici e dei PGW per edge, ma che sono chiamati nello stesso modo. Abbiamo infatti un solo modulo *User Plane Function* (UPF) che è connesso agli UE, e per fare la classificazione del traffico abbiamo un *Uplink Classifier* (ULCL), che appunto decide dove inviare il traffico dall'UE verso il cloud o la rete classica.

Gli UPF possono anche comunicare tra di loro tramite interfaccia N$9$.

Nella parte del *control plane* abbiamo una VNF per ogni componente, che comunicano tra loro tramite un *protocollo publish-subscribe* che si basa sulle API REST.

Abbiamo questo approccio perché non possiamo cambiare tutta l'architettura 4G e dobbiamo essere in grado di *riutilizzare*, non possiamo andare stand-alone.

=== Control plane

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

#align(center)[
  #figure(image("assets/04/evoluzione.png"))
]

Nella precedente immagine vediamo anche l'evoluzione che abbiamo avuto dal 3G al 5G, vedendo un continuo *snellimento* dei vari plane.

=== User plane

L'architettura viene definita a *livelli*, che sono più semplici, visto che abbiamo un singolo *modulo UPF* e diverse istanze che possono dialogare tra loro.

Possono essere attive più data network contemporaneamente tramite *bearer*.

La classificazione avviene sono *Uplink* perché nel Downlink noi andiamo sempre verso l'UE, mentre in Uplink dobbiamo capire l'UE dove vuole mandare il pacchetto.

=== Network Slices

Vediamo brevemente un esempio di *Network Slices*.

Ogni slice dice una tipologia di servizio che si vuole offrire, con le risorse che si possono mettere, e tramite VNF possiamo comporre il servizio di rete su quella risorsa.

Con le *Network Slices* estendiamo il concetto di *Bearer*, rendendoci quindi estremamente versatili e flessibili. Le slice sono identificate da un *ID* di $8$ bit, che specifica il tipo di slice/service. Questi primi $8$ bit sono la *tipologia*, poi un operatore può definire singole classi di slice usando altri $24$ bit.

Il dialogo tra UE, AMF, NSSF e UDM permette di determinare quello che è consentito ad un UE durante una richiesta di Slice.

== Integrazione con Edge Computing

L'integrazione del *MEC* in 5G avviene tramite VNF e *Physical Network Function* (PNF).

Un UE ha un bearer che lo collega ad un UPF per una data DN. Viene ora richiesto un nuovo servizio edge: l'*orchestratore* trova l'edge host, la *MEC application* configura il servizio richiesto e attraverso il *SMF* viene creato un nuovo UPF con anche l'uplink classifier.

I vari MEC host possono essere messi in diverse *topologie*:
+ il MEC host è sul *sito radiomobile*, con una bassissima latenza per fare processing locale dei dati, ma non va benissimo perché ha copertura e risorse limitate;
+ il MEC host è nel *ring di accesso alla rete*, con gli eNodeB collegati ad anello, che permette bassa latenza e processing locale ma siamo comunque ancora limitati;
+ il MEC host è nella *rete backhaul* ma non nella rete core, quindi copriamo un'area metropolitana;
+ il MEC host è nella *rete core*, si ha latenza (meglio del cloud btw) ma abbiamo a disposizione tantissime risorse.

== Latenza

Uno degli obiettivi del 5G era avere una *latenza inferiore al millisecondo*. Purtroppo, non possiamo usare la rete 4G perché i *resource block* (RB) di 4G erano esattamente di durata $1millis$.

Viene scelto quindi di cambiare la parte radio, creando la *$5$G New Radio* ($5$G NR), in cui trasmettiamo lo stesso data rate di prima ($14$ simboli in OFDMA) in meno tempo.

Ricordiamo che una durata del simbolo dipende dal sub-carrier spacing, quindi più un simbolo dura e più dobbiamo distanziare i simboli. Come soluzione riduciamo quindi la durata dei simboli, per avere più spazio e più banda.

Lo *standard 5G NR* definisce $5$ durate, indicate come *numerology* e numerate da $0$ a $4$. Abbiamo anche due *intervalli di frequenze* FR$1$ e FR$2$, uno classico e uno usato quando ci serve tanta banda.

#align(center)[
  #figure(image("assets/04/numerology.png"))
]

Abbiamo quindi una tabella che indica, per ogni numerology, quanto sono distanti le sotto-portanti. Ci viene poi detto in che bande FR possiamo usare quelle numerology, visto che nelle FR1 non abbiamo tanto spazio libero.

Per ogni numerology, viene indicato poi spacing, durata del simbolo, durata del prefisso ciclico e quanto dura tutto il simbolo in totale.

Infine, grazie a queste informazioni, viene indicato quanto deve essere ampio un RB per contenere le sub-carrier.

Avendo quindi diverse dimensioni da scegliere abbiamo uno *scheduling* molto più complicato ma che ci permette di incastrare tanti blocchi in maniera ottimale.

== Architettura Standalone e Non-Standalone

Nel caso *Standalone* abbiamo l'eNodeB 4G e la rete core 4G, oppure lo stesso ma full 5G, oppure una situazione ibrida che mischia le due.

#align(center)[
  #figure(image("assets/04/SA_NSA.png"))
]

Come vediamo, abbiamo tantissime configurazioni possibili.

Inoltre, ora l'eNodeB può essere decomposto in *Central Unit* e *Distributed Units* per poter scalare il numero di eNodeB. Questo è quello che avviene nello standard *OPEN-RAN*.
