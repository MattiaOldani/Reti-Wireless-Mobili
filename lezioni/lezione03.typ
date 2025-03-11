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

= Lezione 03 [04/03]

Se $n=2$ nel free space loss allora $ L_(d B) = 10 log(P_t / P_r) = 20 log(frac(4 pi f, c)) $

A parità di distanza, maggiore è la frequenza e maggiore è il path loss. La potenza di trasmissione è regolamentata. A parità di potenza, maggiore è la frequenza e minore è il raggio di copertura (segnali sufficientemente forte da essere utilizzabile).

Antenne sono isotropiche (ideali), ovvero sono sfere. Un'altra ideale è quella direzionale, tipo ellisse. Il gain (guadagno) dell'antenna è definito come il rapporto tra l'intensità della radiazione elettromagnetica in una data direzione e l'intensità che si avrebbe se si usasse un'antenna isotropica. Il gain è misurato in dBi (isotropic)

Il path loss, con antenna gain, è $ P_t / P_r = (frac(4 pi f, c))^2 d^n = frac((4 pi f)^2, G_(t_X) G_(r_X) c^2) d^n $ e quindi $ L_(d B) = 10 log_10 (P_t / P_r) = 20 (log_10 (frac(4 pi f, c)) - log_10 (G_(t_X)) - log_10 (G_(r_X))) $

Vediamo il multipath: io sto mandando in LOS, ma ho interazioni con l'ambiente, tipo:
- riflessione
- scattering (se $lambda tilde$ oggetto)
- diffrazione (se $lambda lt.double$ oggetto, effetto sui bordi)

Uno degli effetti è il *fading* (evanescenza), dovuto a interferenze distruttive tra più onde elettromagnetiche; le interferenze sono variabili nel tempo, perché siamo in un ambiente dinamico, e dipende anche dalla mobilità del dispositivo (entrambi ciao). Un altro è l'*interferenza Inter-Simbolo* (ISI Inter-symbol interference) ovvero la ricezione sovrapposta di simboli adiacenti a causa del ritardo di ricezione delle onde dei diversi percorsi. La durata è del simbolo è $tilde =$ o $<$ la max differenza dei tempi di arrivo.

Nel fading, il coherence time è la scala temporale in cui si possono considerare le caratteristiche del segnali costanti. Si calcola con $ T_c = 1 / f_D . $ La frequenza doppler dipende dalla velocità di movimento e dalla frequenza (oltre che da $c$) ed è $ f_D = v/c f_c $

Usiamo il MIMO (Multiple Input Multiple Output), che può essere di diversi tipi

== Codifica e trasmissione dei dati

Dati utente --> forward error correction (FEC) ovvero encoder --> modulation e coding con la frequenza portante --> power amplifier (amplificatore) e lo mandiamo. Quando riceviamo abbiamo de-modulazione (demodulation) e decoding --> forward error correction (FEC) e decoder

Schema di modulazione e codifica. Sappiamo che $ s(t) = A sin(2 pi f_c t + phi.alt) $ ed esistono diverse tecniche per codificare dati digitali in segnali analogici.

Diversi livelli di ampiezza per diversi bit (o gruppi) parliamo di Amplitude-shift keying (ASK)

Diverse frequenze per diversi bit (o gruppi) parliamo di Frequency-shift keying (FSK)

Diverse fasi per diversi bit (o gruppi) parliamo di Phase-shift keying (PSK)

Il simbolo è una forma d'onda, uno stato o una condizione significativa del canale di comunicazione che persiste in un intervallo di tempo fissato. Il symbol rate è il numero di simboli trasmessi al secondo [baud]

In generale, un simbolo può contenere più bit, quindi symbol rate diverso da bit rate

Metti esempi vari

Tecniche che permettono più di un bit per simbolo:
- MFSK multilevel frequency-shift keying ($L = log_2(M)$)
- QPSK quadrature phase-shift keying (2)
- X-QAM quadrature Amplitude modulation ($L = log_2(X)$)

Vediamo ora QPSK. Usa la fase per determinare ...

Siamo nello spazio complesso (viva Edu) ma usiamo le coordinate polari. Il segnale è $ s(t) = 1/sqrt(2) ... $

Ogni punto codifica una coppia di bit. Sono 4 fasi differenti, distanziate di 90 gradi. Usiamo 2 bit per simbolo, usando una codifica Gray per punti adiacenti.

Vediamo QAM. Cambia un po', ma combina variazioni di ampiezza e fase, ad esempio 16-QAM usa 4 bit per simbolo e la costellazione è più densa.

Bit error rate curve: le curve di BER rappresentano la probabilità di errore di un bit in funzione del rapporto tra la densità di energia del segnale per bit ed il livello del rumore, ovvero $ B E R = f u n c (E_b / N_0) $

La formula analitica (verificata poi sperimentalmente) è una stima ottimistica rispetto al caso reale, ovvero $ B E R = 4/n (1 - 1/sqrt(M)) e r f c (sqrt(frac(3 n E_B, (M - 1) N_0))) $ con $n$ bit per simbolo, $M$ numero di simboli diversi (costellazione) e erfc funzione degli errori di Gauss complementare, ovvero $ e r f c (x) = 2/sqrt(pi) integral_x^infinity e^(-t^2) dif t $

AMC è adaptive modulation and coding

Il forward error correction aggiunge bit ai dati, così il ricevente li può usare per vedere se ci sono stati errori. Se la error detection vede un errore il blocco di dati viene ritrasmesso usando lo schema ARQ. Nelle trasmissioni wireless la probabilità di errore di un bit è elevata. Definiamo code redundancy come $ (n-k)/k $ mentre la coding rate come $ k/n $

A seconda delle condizioni del canale wireless il trasmettitore sceglie lo schema di modulazione e codifica opportuno
