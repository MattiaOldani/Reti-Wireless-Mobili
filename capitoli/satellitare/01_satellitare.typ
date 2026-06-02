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

/*********************************************/
/***** DA CANCELLARE PRIMA DI COMMITTARE *****/
/*********************************************/
// #set heading(numbering: "1.")

// #show outline.entry.where(level: 1): it => {
//   v(12pt, weak: true)
//   strong(it)
// }

// #outline(indent: auto)
/*********************************************/
/***** DA CANCELLARE PRIMA DI COMMITTARE *****/
/*********************************************/

= Rete satellitare

Finiamo il nostro corso con la *rete satellitare*.

Il *piano orbitale* è un piano inclinato di un certo angolo rispetto alla linea dell'*equatore*. Su questo piano girano i satelliti. Le *costellazioni* sono un insieme di piani orbitali.

La *geometria* del link satellitare si articola in tre punti:
+ *angolo azimuth*, che è rispetto al nord geografico in senso orario, ed è quello che ci orienta verso il satellite;
+ *angolo di elevazione*, che è rispetto all'orizzonte e ha il *punto di Zenit* a $90$ gradi;
+ *angolo di copertura*, che indica quanto copriamo della superficie terrestre con il satellite.

Se prima eravamo noi in movimento, ora è il satellite che può variare di molto la distanza del nostro link (quando non siamo con satelliti geostazionari).

Un altro aspetto da considerare l'*attenuazione* del segnale in funzione dell'angolo di elevazione: infatti, avendo poca elevazione dobbiamo attraversare l'atmosfera storti, e quindi abbiamo più effetti di *assorbimento atmosferico*.

=== Orbite

Abbiamo tre tipi di orbite:
+ orbita *Geostationary Earth Orbit* (GEO), la più lontana, che ha durata di orbita di esattamente un giorno e ruota come la terra. Si trova oltre i $35$k chilometri e ha qualità del segnale bassa con elevato delay;
+ orbita *Low Earth Orbit* (LEO), la più vicina, tra i $500$ e $1500$ chilometri di altitudine. Presenta basso delay e uso migliore dello spettro, ma la copertura richiede di fare handover visto che il periodo di orbita è molto breve;
+ orbita *MEO* (Medium Earth Orbit), che ha una posizione che prende il meglio e il peggio delle due presentate prima.

// SLIDE 9

Come vediamo in questo grafico, nelle orbite basse abbiamo delay, periodi e coperture piccole, mentre nelle orbite più alte tutti questi fattori crescono.

Nelle GEO in realtà abbiamo anche le *Geosynchronous Earth Orbit* (GSO), che hanno una traiettoria che forma un $8$ nel cielo.

// SLIDE 13

Sulle orbite LEO e MEO ci serve una *costellazione* di satelliti per garantire una copertura continua globale -- o almeno regionale.

=== Architettura

L'*architettura* della rete satellitare è formata da tre segmenti:
+ *space segment*, che sono i satelliti e le costellazioni con l'*Inter-satellite link*;
+ *ground segment*, che ha due sotto-blocchi:
  - una parte gestisce lo space segment tramite telemetria, allineamento e tracking;
  - una parte fa da *gateway* per uscire dalla rete satellitare;
+ *user segment*, che sono gli *utenti fissi* (antenne/parabole) e *mobili* (UE che cammina) che usano i servizi della rete.

// SLIDE 17

La *comunicazione satellitare* avviene uplink dalla stazione al satellite, e poi in downlink con il percorso opposto. L'area di copertura è maggiore del wireless terrestre, a patto di avere del delay in più. Possibile fare anche la *comunicazione broadcaster*.

Il *livello MAC* funziona tramite periodi di *contention-free* con:
+ *TDMA*, che richiede grande sincronizzazione e potenza;
+ *FDMA*, che però ha grande effetto doppler;
+ *CDMA*, che ora è usato da quasi tutti, in cui ogni satellite ha un codice;
+ *OFDMA*, che anche lui ha il doppler ma con $5$G-NTN si riesce ad utilizzare, come fa ad esempio Starlink.

=== NTN

La *Integrated Satellite-Terrestrial Networks* si chiedono come includere la rete cellulare nel mondo satellitare, ovvero si chiedono se sia possibile avere un satellite che fa anche da eNodeB.

Le motivazioni sono molteplici:
+ dare connettività in aree remote dove la rete cellulare non arriva;
+ dare continuità di servizio;
+ migliorare l'affidabilità della rete in caso di catastrofi naturali;
+ aumentare la scalabilità della rete.

L'integrazione avviene tramite un *relay*, che fa da ripetitore del segnale aumentandone la qualità al livello fisico, così che gli UE possano ricevere il segnale.

Possibile anche usare il *link di backhaul*, ovvero il satellite connette gli eNodeB alla rete core.

Infine, è possibile anche il *direct access*, in cui il satellite offre connettività direttamente ai dispositivi.

Possiamo fare poi come in 5G, ovvero dividere la CU (a terra) e le varie DUs (sui satelliti).

// Fine 09_satellitare.pdf
