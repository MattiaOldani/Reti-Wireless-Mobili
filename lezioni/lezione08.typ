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

= Lezione 08 [19/03]

== ZigBee + Matter & Thread

Siamo sempre nell'802.15 ovvero nel corto raggio con un dispendio energetico ridotto

=== ZigBee

Standard 802.15.4 delle low-rate WPAN

Con BT e BLE volevamo una riduzione del consumo di batteria e una complessità che si abbassava. In ZigBee estremizziamo questi concetti con anche altri requisiti:
- affidabilità
- basso costo
- lunga durata della batteria (molto più del BT)
- bassa complessità (pensato per sensori)
- utilizzo delle bande ISM (sia 2.4GHz che 915MHz e 868MHz)
- scalabilità (alto numero di nodi ma con strutture anche particolari)
- interoperabilità tra vendors
- sicurezza

Utilizzi un botto, guardali da solo (automation, personal care, periferiche, sicurezza, smart, eccetera)

Le topologie di rete che abbiamo sono:
- stella (BT like)
- albero
- mesh

Possiamo anche inserire del routing con particolari nodi

Abbiamo due macro-classi:
- full function device [FFD] tutte le funzionalità
- reduced function device [RFD] una parte delle funzionalità

Tra i FFD ne abbiamo due particolari:
- un solo coordinatore, detto PAN coordinator, unico all'interno della rete, che la deve creare e mantenere le informazioni (tipo chiavi di sicurezza)
- router, nodi che hanno la capacità di inoltrare dati tra i vari dispositivi ZigBee

I RFD sono invece gli end device, hanno solo la capacità di parlare con un router/coordinatore, e hanno ridotta complessità ed elevato risparmio energetico. Sono proprio gli attuatori

Cerchiamo di mettere pochi FFD e tanti RFD per diminuire al minimo il dispendio energetico. Vogliamo cambiare le batterie il minimo possibile

I ZigBee li distinguiamo per tipologie di invio di dati:
- dati periodici (tipo sensori, intervallo di trasmissione fissato)
- dati intermittenti (asincroni, stimoli esterni o dell'applicazione, tipo interruttore, in base ad un evento)
- dati ripetitivi e a bassa latenza (tipo mouse, allocazione di time slot con un certo servizio, vogliamo in tempo reale)

IMMAGINE ARCHITETTURA azzurro solo quelli della ZigBee alliance (tolta da Thread & Matter), rossi sono dipendenti dai singoli sviluppatori

Partiamo dal lato fisico: lo standard specifica la tipologia di modulazione e di spread spectrum per le $3$ bande (FDM), cifratura per interferenze

Andiamo al livello MAC: esso deve
- gestisce l'invio dei beacon (se siamo PAN coordinator)
- sincronizzazione con i beacon del coordinatore (router & end)
- associazione/dissociazione alla PAN ascoltando i beacon
- accesso al canale tramite CSMA/CD
- MAC address (16 o 64 bit)
- gestione del duty-cycle del dispositivo
- gestisce la trasmissione diretta tra dispositivo e coordinatore ambo i lati
- gestisce la trasmissione indiretta da coordinatore a dispositivi

Abbiamo due modalità di trasferimento:
- unslotted CSMA-CA senza beacon
- slotted CSMA-CA con beacon

Slotted CSMA-CA beacon mode

Si basa sull'invio di beacon, messaggi con informazioni su come è organizzata la piconet, inviati dal coordinatore ed eventualmente inoltrata dai router

Il coordinatore invia periodicamente i beacon per:
- sincronizzare gli altri dispositivi
- organizzare i periodi di trasmissione per le diverse tipologia di trasmissione (periodiche, asincrone e bassa latenza), deve capire come dividere i bro
- gestione della trasmissione indiretta:
  - il coordinatore mantiene in una lista le frame non ancora mandate ai dispositivi
  - nei beacon frame trasmette anche i dispositivi che hanno frame pendenti (i bro sapranno se hanno qualcosa per me)
  - i dispositivi che ascoltano i beacon sanno se c'è qualcosa per loro

Definiamo i superframe: è l'intervallo tra un beacon e l'altro, momento di attività e altri di inattività

Il duty cycle è l'alternarsi tra periodi di attività (radio accesa) e inattività. Se devo prendere qualcosa dal beacon ok, sennò mi spendo e mi riaccendo al prossimo superframe

Abbiamo il beacon interval BI e superframe duration SD. L'unità base è aBaseSuperframeDuration di 960 simboli. Avremo multipli di questo parametro

Ci serve poi
- BO (beacon order) che determina il beacon interval tra 0 e 14
- SO (superframe order) che determina la durata del superframe 0-14
- duty cycle = $2^"SO" / 2^"BO"$

Mentre il nostri BI si calcola come $ "BI" = "aBaseSuperframeDuration" dot 2^"BO" "sym" $

$960$ simboli sono circa $15.3 m s$ con banda 2.4

Il beacon frame [IMMAGINE] GTS (guaranted ...), nel primo blocco, tiene tutte le informazioni

Il superframe, dentro il beacon, mi da info sui tempi di attività:
- contention access period (CAP) accetto con CSMA-CA
- contention free period (CFP) (da 0 fino a 7 slot)m comunicazione con banda riservata tramite guardanteed time slot (GTS)

Come funziona la trasmissione? *IMMAGINE*

All'inizio faccio CCS (verifico che sia libero) per brevi periodi (8 simboli, poca batteria)

Non posso andare oltre il CAP, deve essere atomico l'operazione, per forza dentro li

Unslotted invece più semplice, siamo in non-beacon mode, quindi accediamo al canale con CSMA/CA senza i vincoli degli slot, no sincronizzazione (cordinatore e router RX sempre attivi), il tempo è continuo e non discreto come in beacon e il controller è più semplice

Andiamo al livello di rete, facciamo indirizzamento, gestione della rete join and leave, sincronizzazione e routing (star, tree, mesh AODV)

Ogni dispositivo è programmato per una specifica funzione (potrei avere più robe)

ZigBee Device Object definisce il ruolo del dispositivo, scoperta di nuovi dispositivi e delle loro funzionalità, interfaccia con le applicazioni definite dai manufacturer

=== Matter & Thread

Nuovo standard, sempre 802.15.4 ma viene montato Thread da parte a ZigBee e sopra Matter

Fisico e MAC siamo uguali a ZigBee, ma Thread abbiamo delle funzionalità più conosciute:
- 6LoWPAN
- IP routing
- UDP

Con anche robe di sicurezza, ...

Cambia le rete Thread

Abbiamo i routing full thread device:
- router: effettua routing e fornisce servizi di accesso e sicurezza (NoSleep, degradabile a router-eligible end device REED)
- leader: router con funzionalità aggiuntive che può eleggere/destituire REED

E abbiamo anche i non-routing full thread device:
- REED (prima) non lo sono ma possono esserlo
- full end device (FED) non possono essere router

Infine abbiamo i non-routing minimal thread device, hanno HW minori e:
- minimal end device: comunicazione solo con il router genitore e radio sempre attiva
- sleepy end device: comunica solo con il router genitore con duty-cycle
- synchronized sleepy end device: comunica solo con il router genitore e duty-cycle con intervalli schedulati

Ci sono anche i border router che fanno routing verso l'esterno, in ZigBee non ce l'avevamo
