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
// Slide 97 08_5G.pdf

= Lezione 15 [10/03]

== 5G

=== Network Slice

// Riascolta l'inizio dell'audio

Con le *Network Slices* estendiamo il concetto di *Bearer*, rendendoci quindi estremamente versatili e flessibili. Le slice sono identificate da un *ID* di $8$ bit, che specifica il tipo di slice/service. Questi primi $8$ bit sono la *tipologia*, poi un operatore può definire singole classi di slice usando altri $24$ bit.

Il dialogo tra UE, AMF, NSSF e UDM permette di determinare quello che è consentito ad un UE durante una richiesta di Slice.

=== Integrazione con Edge Computing

L'integrazione del *MEC* in 5G avviene tramite VNF e *Physical Network Function* (PNF).

Vediamo come funziona con un esempio.

// SLIDE

Un UE ha un bearer che lo collega ad un UPF per una data DN. Viene ora richiesto un nuovo servizio edge: l'*orchestratore* trova l'edge host, la *MEC application* configura il servizio richiesto e attraverso il *SMF* viene creato un nuovo UPF con anche l'uplink classifier.

I vari MEC host possono essere messi in diverse *topologie*:
+ il MEC host è sul *sito radiomobile*, con una bassissima latenza per fare processing locale dei dati, ma non va benissimo perché ha copertura e risorse limitate;
+ il MEC host è nel *ring di accesso alla rete*, con gli eNodeB collegati ad anello, che permette bassa latenza e processing locale ma siamo comunque ancora limitati;
+ il MEC host è nella *rete backhaul* ma non nella rete core, quindi copriamo un'area metropolitana;
+ il MEC host è nella *rete core*, si ha latenza (meglio del cloud btw) ma abbiamo a disposizione tantissime risorse.

=== Latenza

Uno degli obiettivi del 5G era avere una *latenza inferiore al millisecondo*. Purtroppo, non possiamo usare la rete 4G perché i *resource block* (RB) di 4G erano esattamente di durata $1millis$.

Viene scelto quindi di cambiare la parte radio, creando la *$5$G New Radio* ($5$G NR), in cui trasmettiamo lo stesso data rate di prima ($14$ simboli in OFDMA) in meno tempo.

Ricordiamo che una durata del simbolo dipende dal sub-carrier spacing, quindi più un simbolo dura e più dobbiamo distanziare i simboli. Come soluzione riduciamo quindi la durata dei simboli, per avere più spazio e più banda.

Lo *standard 5G NR* definisce $5$ durate, indicate come *numerology* e numerate da $0$ a $4$. Abbiamo anche due *intervalli di frequenze* FR$1$ e FR$2$, uno classico e uno usato quando ci serve tanta banda.

// SLIDE TABELLA

Abbiamo quindi una tabella che indica, per ogni numerology, quanto sono distanti le sotto-portanti. Ci viene poi detto in che bande FR possiamo usare quelle numerology, visto che nelle FR1 non abbiamo tanto spazio libero.

Per ogni numerology, viene indicato poi spacing, durata del simbolo, durata del prefisso ciclico e quanto dura tutto il simbolo in totale.

Infine, grazie a queste informazioni, viene indicato quanto deve essere ampio un RB per contenere le sub-carrier.

// SLIDE 115

Avendo quindi diverse dimensioni da scegliere abbiamo uno *scheduling* molto più complicato ma che ci permette di incastrare tanti blocchi in maniera ottimale.

=== Architettura Standalone e Non-Standalone

Nel caso *Standalone* abbiamo l'eNodeB 4G e la rete core 4G, oppure lo stesso ma full 5G, oppure una situazione ibrida che mischia le due.

// SLIDE

Come vediamo, abbiamo tantissime configurazioni possibili.

Inoltre, ora l'eNodeB può essere decomposto in *Central Unit* e *Distributed Units* per poter scalare il numero di eNodeB. Questo è quello che avviene nello standard *OPEN-RAN*.

// Fine 08_5G.pdf
// Inizio 09_satellitare.pdf

== Rete satellitare

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
