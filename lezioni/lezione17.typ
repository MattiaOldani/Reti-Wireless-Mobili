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

= Lezione 17 [22/04]

== 4G [LTE]

Release 8, 4G LTE Long Term Evolution

In 4G un solo nodeB per volta perché collassano controllore e BS

La carte core viene divisa anche a livello architetturale

[DIFFERENZE]

Separazione anche di architettura di control e data plane

=== Moduli

Core network MME

Nodo di controllo responsabile del traffico di segnalazione tra CN e UE attraverso i protocolli NAS (no dati utente, solo controllo)

Core network HSS

Contiene le informazioni dell'utente (profili QoS ammessi, restrizioni roaming, ...)

Core network PGW

Fa da border routing, nodo a bordo della rete dell'operatore mobile

Core network SGW

Unico vero modulo che fa solo user plane no data plane, gestisce traffico user-plane

Core network PCRF

Controlla autorizzazioni per singolo flusso

E-UTRAN E-NodeB

Nodo che fornisce connettività radio ad UE e lo collega alla rete core

=== E-UTRAN

Modulazione e codifica di trasmissione con QPSK

Prima facciamo QPSK, poi moduliamo con una frequenza intermedia, che permette di variare la portante

BPSK anche se canale pessimo, segnali a basso livello

4 bit per la quantizzazione (0 a 15), riguarda solo data plane, il control ha la sua codifica fissa

La durata di un simbolo è $ T_s = frac(1, 2048 dot 15000) s = 32.6 "ns" $ dove 2048 sono i punti della FFT e 15000 è la distanza tra le sottobande

Questa è la minima unità temporale usata dal processore del livello fisico

I simboli sono organizzati in slot da 0.5 ms

Abbiamo un mini prefisso, in uno slot ho 7 simboli o 6 (se extended). Se raggio limitato si usa 7, se raggio alto potrei avere multipath allora uso un prefisso maggiore

Il duplex ha due modi scelti durante la configurazione e detti dalla BS:
- FDD frequenze diverse
- TDD stessa frequenza

Nel caso di FDD si usano frame di 10ms. Ogni 10ms ricalcola l'allocazione delle risorse. Ad ogni utente si danno sub-frame di 1ms. Quindi ho 20 slot

140 o 120 simboli per frame in base al prefisso

Se invece TDD abbiamo 7 configurazioni standard, comunicate in fase di annuncio della BS. Dicono come sono organizzati i frame

Un frame particolare è il special sub-frame, tra fase di DL e UP, perché abbiamo concetto di uplink time advance: riservata una parte per permettere di anticipare uplink

UE inizia a trasmettere in anticipo rispetto al tempo del frame della BS. Dobbiamo avere slot precisi perché la BS deve leggere tutto assieme

Partono tutti assieme, ma alla ricezione quello vicino si sfasa di un pelino e mangia parte del prefisso, mentre quello lontano va ben oltre

Ai dispositivi più lontani diamo un tempo di Uplink Timing Advance: quando BS autorizza a parlare dice anche di quanto anticipare il clock per non sforare il ritardo

Le sottobande sono organizzate in resource block, minima quantità di risorse allocabili ad un singolo dispositivo

Unità minima è 180kHz perché ho 12 sottobande da 15kHz
