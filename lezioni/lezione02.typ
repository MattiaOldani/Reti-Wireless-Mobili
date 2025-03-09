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

= Lezione 02 [26/02]

== Ancora basi di teoria della trasmissione

Rumore termico: agitazione delle molecole. Intermodulation noise problemi tra le diverse modulazioni, ci si accavalla per trasmettere. Cross talk è più nel parlato. Impulse noise, impulso elettromagnetico specifico, distrugge il segnale che è attraversato.

Il decibel (dB) è una misura che rapporto tra due potenze (scala logaritmica), ovvero $ (P_1 / P_2)_(d B) = 10 log_10(P_1 / P_2) . $ Fare un +-3 fa doppio/metà.

Il decibel-milliWatt (dBm) è l'unità di misura del rapporto tra una potenza arbitraria e una potenza di 1mW (milliWatt), ovvero $ P_(d B m) = P / (1 m W) . $

Il rumore c'è sempre: il rapporto segnale rumore (signal to noise ratio SNR) è il rapporto tra la potenza del segnale trasmesso e la potenza del rumore, ovvero $ (S N R)_(d B) = 10 log_10 (frac("signal power", "noise power")) . $

Più è alto più il segnale è forte rispetto al rumore

La Shannon Capacity Formula rappresenta la massima capacità teorica di un canale in bit al secondo in funzione del SNR, ovvero $ C = B log_2(1 + S N R) $ dove $B$ è la banda. Risultato puramente teorico e considera solo il thermal noise, tuttavia fornisce un limite superiore alla quantità di informazione (data rate) che può essere trasmessa senza errori.

In una determinata condizione di rumore (SNR) possiamo aumentare il data rate:
- aumentando la banda B ma il rumore termico è rumore bianco e maggiore è la banda e maggiore sarà il rumore che entrerà nel sistema
- aumentando la potenza del segnale, allora SNR++ ma sarà maggiore l'intermodulation e il cross talk noise

#example()[
  Supponiamo di avere uno spettro tra $3 M H z$ e $4 M H z$ e SNR = 24dB. La banda vale quindi 1MHz e SNR è 251

  La capacità di Shannon è C = 8Mbps

  Ora facciamo inverso di Nyquist

  Se $C = 2 B log_2(M)$ andiamo a ricavare $M = 16$
]

#example()[
  Altro esempio
]

== Multiplexing

In quasi tutti i casi la cpaacità del mezzo di trasmissione è superiore alla capacità richiesta da una trasmissione. Vogliamo combinare sullo stesso link più trasmissioni. Abbiamo un maggior data rate con un minore costo kbps. Le singole comunicazioni richiedono un data rate inferiore rispetto alla capacità del link.

FDM frequency division multiplexing, sfrutta il fatto che la banda disponibile sul mezzo di trasmissione eccede la banda richiesta da un singolo segnale. Divido la banda totale in sotto-bande, ognuna delle quali è canale parallelo.

TDM time division multiplexing sfrutta il fatto che il data rate del mezzo di trasmissione eccede il data rate richiesto da un singolo segnale. Sono robe pseudo-parallele

== Comunicazione wireless

Trasmissione in banda base (baseband), ovvero ho dato digitale, che diventa analogico, canale, riconvertito, eccetera.

Per gestire sto segnale ho la banda $B$, dove parte? Dove arriva? Usiamo per semplicità $0$ a $B$. Problemi:
- se tutti i dispositivi usano questo le comunicazioni interferiscono
- più è bassa la frequenza e più l'antenna deve essere grande
- ogni range di radio frequenze (RF) possiede diverse proprietà di propagazione e attenuazione

Soluzione è la banda traslata (o passa banda), ovvero ho sempre $B$ ma ho una frequenza portante (frequency carrier) e il mio range di trasmissione è $ f_c - B/2 arrow.long.squiggly f_c + B/2 $

Ora il trasmettitore, che prende il dato, lo codifica, lo modula con la portante $f_c$, fa il power control (amplificatore) e poi lo manda. Il bro invece fa de-modulazione e il decoding.

Ci chiediamo:
- quale spettro utilizzare $(f_c)$?
- come codifico i dati?
- come modulo il mio segnale in banda base sulla portante?

L'encoding symbol e symbol rate

Un simbolo è una forma d'onda, uno stato o una condizione significativa del canale di comunicazione che persiste per un intervallo di tempo fissato

Il symbol rate è il numero di simboli trasmetti al secondo, misurato in baud

In generale un simbolo può contenere più bit (codifica e modulazione), quindi symbol rate diverso da bit rate

Una data banda può supportare diversi data rate, a seconda dell'abilità del ricevente di distinguere 0 e 1 in presenza di rumore. Un simbolo può codificare più bit alla stessa frequenza.

La trasmissione che faremo noi è la radio Line of sight (LOS), ovvero sono in linea. Soffre di:
- free space loss & path loss (attenuazione del segnale dovuta alla distanza e all'ambiente in cui il segnale si propaga)
- rumore (disturbo che distorce il segnale)
- multipath (il segnale tra TX e RX può subire riflessioni, diffrazioni e scattering, causando la ricezione di più onde elettromagnetiche dello stesso segnale in tempi diversi)
- effetto Doppler (il segnale cambia a causa del movimento di TX, RX e ostacoli)

Il path loss è l'attenuazione del segnale radio in funzione della distanza tra TX e RX, ovvero $ frac(P_t, P_r) = (frac(4 pi, lambda))^2 d^n = (frac(4 pi f, c))^2 d^n $ misurato in decibel. Questo è direttamente proporzionale alla frequenza (al quadrato), ad una potenza della distanza e $n$ dipende dall'ambiente. Se free space ho praticamente una sfera, più sono lontano e meno ho segnale. Perdiamo sempre potenza, anche se non abbiamo rumore, e dipende tutto da quella formula.
