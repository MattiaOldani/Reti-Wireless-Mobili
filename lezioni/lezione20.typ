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

= Lezione 20 [30/04]

SDN software defined networking

Prima avevamo una struttura di una rete distribuita che contiene control+data layer assieme e poi l'applicazione a livello di rete nell'app layer

SDN toglie dai dispositivi di rete la parte di controllo e la accentra in un controller chiamato SDN controller. Siamo a livello software, non hardware

Si ha conoscenza topologica globale della rete, cosa che prima gli switch non avevano (solo quella locale, se non per propagazione)

Ora si va verso la SDN con programmable data plane

Vantaggi delle SDN:
- flessibilità nella gestione della rete
- visione centralizzata: ottimizzazione del routing
- semplificazione della gestione a livello applicativo (OSS/BSS)
- testing e configurazione di nuovi protocolli di rete più semplici e veloci

Ci sono anche delle sfide da affrontare:
- controller sono single point of failure, sono il punto debole dell'architettura
- sicurezza: controllo il controller, controllo la rete
- reazione ai cambiamenti real-time
- ottimizzazione del numero di regole e delle risorse disponibili su un dispositivo di regole
  - ho tante regole, che continuano a crescere
  - gestione ottimizzata delle tabelle di forwarding
  - gestione e garanzia dell'isolamento di reti overlay
  - gestione della complessità

Per altra flessibilità ci serve NFV network function virtualization

Prima tutto era HW dedicato: si comprava la BBU, idem firewall, MME, bla bla bla

Prima potevo scalare solo verticalmente, quindi mettendo HW in più. Se si contrae il traffico rimango con il ferro in mano, che faccio?

Qui separiamo componente radio e software. Radio diventa standard, ha le caratteristiche di un rack datacenter e su questi ci installiamo istanze di servizi che vogliamo. Come se avessi una VM o un container su una macchina comune

Abbiamo dei template (tipo immagini Docker) che poi istanziamo dove serve

Architettura:
- infrastruttura sulla quale istanziamo le nostre cose, detta NFV infrastructure
  - abbiamo risorse HW
  - strato di virtualizzazione che mette a disposizione le risorse
  - risorse virtualizzate
- sopra mettiamo nel nostre VNFs
- sopra ancora abbiamo element management systems (EMS) che fanno controlli di robe

Il virtual infrastructure manager conosce quante risorse abbiamo a disposizione. Poi c'è anche un gestore della rete, il VNF manager. Sopra tutto abbiamo l'orchestratore

Tutto questo ci permette:
- flessibilità e scalabilità, agilità della rete e dei servizi
- indipendenza tra HW e SW
- rapida prototipizzazione e introduzioni di nuovi servizi - operatore e utenti finali
- uso delle risorse ottimizzato e condiviso

Come prima, sfide:
- prestazioni devono essere comparabili con HW dedicato
  - accelerazioni HW
  - ingegnerizzazione delle VFN
  - tecniche di virtualizzazione con linux container
- gestione efficiente delle risorse
  - orchestratore
  - VNF manager
- sicurezza
- gestione della fase di transizione
  - HW network function a SW network function
  - coesistenza HW e SW network function
- gestione multi-tenant, ovvero più operatori di servizio usano e condividono risorse HW ma anche SW

[...]

Separiamo: dal livello MAC in su viene gestito da un virtual BBU POOL remoto (max 1km) che è staccato dall'eNodeB. Ma cosi abbiamo tutte le vBBU di tutte le tecnologie che vogliamo e lasciamo l'eNodeB staccato. Comodo perché possiamo duplicare se serve

/* siamo molto esperti di fog... */
