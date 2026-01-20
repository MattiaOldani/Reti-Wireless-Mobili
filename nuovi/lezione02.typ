// Setup

#import "alias.typ": *

#import "@local/typst-theorems:1.0.0": *
#show: thmrules.with(qed-symbol: $square.filled$)


// Lezione
// Slide 42 00_intro_radio

= Lezione 02 [19/01]

== Esercizio

Riprendiamo il secondo esercizio della lezione precedente.

#example()[
  Lo spettro di trasmissione va dai $3"M"hertz$ ai $4"M"hertz$, mentre il rapporto segnale-rumore vale $SNR_decibel = 12 decibel$.

  Le domande che vengono fatte sono tipicamente due:
  + trovare la *capacità del canale*;
  + trovare i *livelli di voltaggio* per avere quella capacità.

  Per Shannon e Nyquist la capacità massima è $ C & = B log_2(1 + SNR) \
  C & = 2 B log_2(M) . $

  Dobbiamo trasformare il SNR senza decibel, quindi $ SNR = 10^(12/10) approx 16 . $

  Ma allora per Shannon vale $ C = 10^6 log_2(1 + 16) approx 4"M"bps . $

  Ora con Nyquist possiamo calcolare i livelli di voltaggio come $ M = 2^frac(4 dot 10^6, 2 dot 10^6) = 4 . $
]

== Comunicazione wireless

=== Banda base

Le trasmissioni su cavo avvengono in *banda base*, ovvero lo spettro utilizzato per la trasmissione va da $0hertz$ alla banda massima $B$.

#example([Spettro sonoro])[
  Lo *spettro sonoro* che siamo in grado di sentire va dagli $0hertz$ (in realtà poco più) fino ai $22"M"hertz$, quindi questa è in banda base.
]

Via cavo questo va benissimo, perché non dobbiamo *sintonizzarci* su un range di frequenze. Sul lato wireless ci sono invece molti *problemi*:
+ se tutti i dispositivi radio usano lo stesso spettro $[0,B]$ tutte le comunicazioni *interferiscono*;
+ più è bassa la frequenza è più l'antenna deve essere *grande*. Si stima che la grandezza deve essere circa la metà della lunghezza d'onda $lambda$ per antenne dipole;
+ ogni range di frequenze possiede diverse *proprietà* di propagazione e attenuazione.

#align(center)[
  #image("assets/02/spettro.png", width: 70%)
]

In questa immagine vediamo come viene diviso lo *spettro elettromagnetico*.

=== Banda traslata

Quello che viene fatto per evitare questa sovrapposizione nelle trasmissioni è la trasmissione in *banda traslata*, o *banda passante*.

Viene scelta una *frequenza carrier*, o *frequenza portante*, e lo spettro da $[0,B]$ viene traslato in $ [f_c - B/2, f_c + B/2] $ dove $f_c$ rappresenta la frequenza carrier.

Come vediamo, la *bandwidth* è mantenuta, avendo effettuato una traslazione delle frequenze massima e minima. Inoltre, manteniamo lo *stesso data rate* di partenza.

#align(center)[
  #image("assets/02/carrier.png", width: 70%)
]

Come vediamo, dopo l'*encoding* (che vedremo dopo) prima avviene una *modulazione* con la frequenza portante, modificando i *tre parametri* base di una sinusoide, e poi un'*amplificazione*.

La modulazione è di tre tipi:
+ *amplitude modulation*, che modifica l'ampiezza (come nelle radio AM);
+ *frequency modulation*, che modifica la frequenza (come nelle radio FM);
+ *phase modulation*, che modifica la fase.

Lato ricevente dobbiamo invece fare una *demodulazione*, togliendo la frequenza portante dal segnale, e una volta tornati in *banda base* possiamo eseguire la *decodifica*.

=== Simboli

Un *simbolo* è una forma d'onda, uno stato (livello di voltaggio) o una condizione significativa del canale di comunicazione che persiste per un intervallo di tempo fissato. Non è rumore, è un qualcosa che ha *significato*.

Il *symbol rate* è il numero di simboli trasmessi al secondo dal livello fisico, misurato in *baud*.

*In generale* un simbolo può contenere più bit, quindi il symbol rate è *diverso* dal bit rate. Vedremo in particolare che il bit rate *non è peggiore* del symbol rate, e questi due valori sono uguali quando il livello fisico può produrre solo due segnali.

Una data *bandwidth* può supportare diversi data rate, a seconda dell'abilità del ricevente di distinguere $0$ e $1$ in presenza di rumore. Infatti, un simbolo può *codificare più bit* alla stessa frequenza.

=== Propagazione delle onde radio

Dato per assodato che la *terra è tonda*, le onde radio si *propagano* in tre modi diversi:
+ sotto i $2"M"hertz$ il segnale viaggia seguendo la *curvatura terrestre*, anche se i due ricevitori non si vedono;
+ nel range $[2,30]"M"hertz$ il segnale viene *riflesso* dalla ionosfera;
+ sopra i $30"M"hertz$, dove ci muoveremo noi, necessitiamo della *Line of Sight* (LoS), ovvero i due ricevitori si devono vedere per poter parlare.

Un altro aspetto da controllare è l'*antenna*.

#align(center)[
  #image("assets/02/antenne.png", width: 70%)
]

A sinistra abbiamo un'*antenna omnidirezionale*, ovvero un'*antenna ideale*, che però non è sempre voluta. A destra invece abbiamo un'*antenna direzionale*, che ha un grande *lobo* che punta in *una direzione* e altri piccoli lobi per coprire le altre direzioni.

Tendenzialmente le antenne direzionali sono quelle usate per le *comunicazioni* perché concentrano l'energia in una certa direzione, ovvero la direzione LoS.

=== Trasmissione LoS

La *trasmissione radio LoS* presenta molti problemi:
+ *free space loss* e *path loss*, che abbiamo anche su cavo (il path loss ovviamente), ed è una *attenuazione del segnale* dovuta alla distanza e all'ambiente in cui il segnale si propaga;
+ *rumore*, al quale siamo sempre sensibili visto che non abbiamo protezione;
+ *multipath*, che grazie a fenomeni di *riflessione*, *diffrazione* e *scattering* causa la ricezione di più onde dello stesso segnale in tempi diversi;
+ *effetto doppler*, ovvero si ha una variazione del segnale a causa del *movimento* di TX, RX e ostacoli; una velocità ampia porta una differenza ampia.

==== Path loss

Il *path loss* è l'*attenuazione del segnale radio* in funzione della *distanza* tra RX e TX, ed è definito come $ frac(P_t, P_r) = (frac(4 pi, lambda))^2 d^n = (frac(4 pi f, c))^2 d^n . $

Questo rapporto tra la *potenza del segnale trasmesso* e la *potenza del segnale ricevuto* va ad indicare quanta potenza è stata persa. Ovviamente, il valore $P_t$ è di solito maggiore di $P_r$.

Notiamo che questo rapporto:
+ è *direttamente proporzionale* al quadrato della frequenza;
+ è *direttamente proporzionale* ad una potenza della distanza, e questa dipende dall'ambiente.

Facciamo qualche confronto:
+ a parità di *potenza*, abbiamo *maggiore copertura* se abbiamo delle *frequenze più basse*, visto che abbiamo meno effetto di path loss;
+ a parità di *distanza*, una frequenza più alta comporta un path loss più alto.

Spesso è comodo definire il path loss $L$ in *decibel*.

#align(center)[
  #image("assets/02/pathloss.png", width: 70%)
]

In questa immagine vediamo quanti decibel perdiamo, indicati sull'asse $y$, data una certa distanza tra TX e RX, indicata sull'asse $x$.

Il *gain*, o *guadagno*, di un'antenna è definito come il *rapporto* tra l'intensità della radiazione elettromagnetica in una data direzione e l'intensità che si avrebbe se si usasse un'antenna isotropica.

Le *antenne isotropiche* sono le antenne ideali (e allora chiamale ideali).

Il gain si indica con $G$ ed è misurato in *decibel isotropici*, indicati con dBi.

Questa quantità ci aiuta con il path loss: avendo delle antenne direzionali noi stiamo concentrando l'energia in una certa direzione, quindi dal path loss dobbiamo *togliere* alcune quantità.

Il nuovo path loss, non misurato in decibel, diventa $ frac(P_t, P_r) & = frac((4 pi f)^2, G_tx G_rx c^2) d^n $ che poi trasformati in *decibel* ci dà una perdita pari a $ L_decibel = 10 log_10(frac(P_t, P_r)) = 20 (log_10(frac(4 pi f d, c)) - underbracket(log_10(G_tx), "gain tx") - underbracket(log_10(G_rx), "gain rx")) . $

Questi conti sono ovviamente a parità di distanza e ambiente free space: con le antenne direzionali abbiamo un *path loss minore*.

==== Multipath

Il *multipath* si presenta quando l'ambiente è *complesso* e possono presentarsi effetti di:
+ *riflessione* del segnale;
+ *scattering*, che spara il segnale in tutte le direzioni perché la lunghezza d'onda del segnale è simile a quella dell'oggetto;
+ *diffrazione*, che è come lo scattering ma avviene sui bordi perché la lunghezza d'onda del segnale è molto più piccola di quella dell'oggetto.

#align(center)[
  #image("assets/02/multipath.png", width: 70%)
]

Come vediamo, per fare da TX a RX abbiamo il segnale *LoS* ma anche molti altri percorsi, dovuti agli effetti appena presentati.

Il multipath può provocare due *effetti fastidiosi*: il fading e l'interferenza inter-simbolo.

===== Fading

Il *fading*, o evanescenza, avviene quando si ha *interferenza distruttiva* tra più onde elettromagnetiche. Abbiamo due tipi di interferenza: *costruttiva*, che va ancora ancora bene, e *distruttiva*, che è fastidiosa perché abbassa i picchi e crea un'onda che non c'entra niente con quella di partenza.

Per risolvere questo problema dobbiamo garantire un *tempo di coerenza*, ovvero una scala temporale in cui possiamo considerare "costanti" le caratteristiche del segnale. Questo tempo di coerenza è tale che $ T_c = 1 / f_D . $

Questo valore dipende dalla *frequenza doppler*, basata sulla velocità di movimento (di chi non lo so) e sulla frequenza, ed è tale che $ f_D = (v / c) f_c . $

Se abbiamo alta velocità e alta frequenza allora abbiamo un periodo molto basso, e quindi dobbiamo *campionare* più spesso il segnale.

Nel prossimo esempio vediamo una serie di segnali che vanno incontro al problema del fading.

#example([Fading])[
  Allunghiamo per bene questi appunti.

  Nella prima immagine vediamo l'effetto del path loss, che rende più debole il segnale.

  #align(center)[
    #image("assets/02/fading01.png", width: 80%)
  ]

  Nella seconda immagine abbiamo invece l'effetto del fading con $2$ path che non sono LoS.

  #align(center)[
    #image("assets/02/fading02.png", width: 80%)
  ]

  Nella terza immagine aggiungiamo l'effetto doppler ai segnali precedenti.

  #align(center)[
    #image("assets/02/fading03.png", width: 80%)
  ]

  Infine, nell'ultima immagine aggiungiamo anche il rumore.

  #align(center)[
    #image("assets/02/fading04.png", width: 80%)
  ]
]

===== Interferenza inter-simbolo

L'*interferenza inter-simbolo* (ISI) avviene molto spesso in ambito mobile.

Questo fenomeno si presenta come una *ricezione sovrapposta* di simboli adiacenti a causa del ritardo di ricezione delle onde del primo simbolo. Arabo vero? In realtà no.

Se l'intervallo di tempo tra un simbolo e l'altro è molto breve può succedere che se le onde non LoS del primo simbolo arrivino al RX nello stesso momento in cui arrivano le onde LoS del secondo simbolo.

#align(center)[
  #image
]

Siamo così sfigati che interferiamo con *noi stessi*.

Se siamo *distanti* questo effetto è molto presente, quindi per risolverlo bisogna *aumentare la distanza tra i simboli*, a discapito di un minor data rate. Se invece siamo *vicini* l'effetto è poco presente, quindi possiamo tenere i simboli più vicini e quindi *aumentare* il data rate.

=== Sistemi multi-antenna

I *MIMO* sono dei sistemi multi-antenna, fine, non serve sapere altro.

=== Codifica e trasmissione dei dati

Nella seguente immagine vediamo lo *schema della trasmissione radio*.

#align(center)[
  #image("assets/02/schema.png", width: 70%)
]

Il nostro segnale digitale prima passa nel blocco *FEC* con l'*encoder*, poi viene *modulato* sulla frequenza portante e infine viene *amplificato*. Una volta che questo viene spedito sul canale il ricevitore deve *demodulare* il segnale e farlo passare ancora in un blocco FEC con una *decodifica*.

Come vedremo, i blocchi FED e di modulazione sono *dinamici*, ovvero dipendono dal canale.

Ricordiamo che il segnale è una sinusoide $ s(t) = A sin(2 pi f_c t + phi) . $

==== Codifiche semplici

Esistono diverse tecniche per *codificare* i dati digitali in segnali analogici:
+ *Amplitude-Shift Keying* (ASK): usiamo diversi livelli di ampiezza $A$ per diversi bit;
+ *Frequency-Shift Keying* (FSK): usiamo diverse frequenze $f$ per diversi bit;
+ *Phase-Shift Keying* (PSK): usiamo diverse fasi $phi$ per diversi bit.

#example()[
  Vogliamo codificare $1$ per ogni simbolo.

  Vediamo i tre segnali che potremmo usare per questo scopo.

  $
    s(t) & = cases(A sin(2 pi f_c t) quad & "se" 1, 0 & "se" 0) \
    s(t) & = cases(A sin(2 pi f_1 t) quad & "se" 1, A sin(2 pi f_2 t) & "se" 0) \
    s(t) & = cases(A sin(2 pi f_c t) & "se" 1, A sin(2 pi f_c t + pi) quad & "se" 0) .
  $

  Vediamo un grafico di come sono fatti questi segnali.

  #align(center)[
    #image("assets/02/encoding.png", width: 70%)
  ]

  Come vediamo, i primi due segnali sono ok, ma "sentire" un cambiamento in queste onde è abbastanza difficile se non si ha un segnale di ottima qualità. Il terzo segnale invece è pieno di *interruzioni di fase*, che sono molto semplici da vedere e sentire.
]

Una versione alternativa del robusto phase-shift è il *Differential Phase-Shift Keying* (DPSK), che non ha una codifica fissa ma *variabile*.

Ogni volta che leggo uno $0$ *mantengo la fase*, mentre ogni volta che leggo un $1$ la fase viene *shiftata* di $180°$. Questa tecnica è molto comoda perché non richiede un allineamento preciso e si *identifica* facilmente.

==== Codifiche sofisticate

Esistono però delle codifiche più *sofisticate*, che permettono di trasmettere più di un bit per simbolo:
+ *MFSK* o Multilevel Frequency-Shift Keying, nel quale la *M* del nome indica il numero di livelli di voltaggio, con i quali codifichiamo $L = log_2(M)$ bit;
+ *QPSK* o Quadrature Phase-Shift Keying, che codifica $2$ bit per simbolo;
+ *X-QAM* o Quadrature Amplitude Modulation, nel quale la *X* del nome permette di ricavare il numero di bit codificati come $L = log_2(X)$.

===== QPSK

Con *QPSK* riusciamo a mandare $2$ bit per ciascun simbolo usando un segnale $ s(t) = cases(A cos(2 pi f_c t + pi / 4) & "se" 11, A cos(2 pi f_c t + frac(3 pi, 4) quad & "se" 01), A cos(2 pi f_c t - frac(3 pi, 4)) & "se" 00, A cos(2 pi f_c t - pi / 4) & "se" 10) $ formato da $4$ fasi diverse distanziate di $90°$ e usando una codifica Gray per i punti adiacenti.

Questo segnale può essere "compresso" in una formula unica $ s(t) = 1/sqrt(2) I(t) cos(2 pi f_c t) - 1/sqrt(2) Q(t) sin(2 pi f_c t) $ che dipende dai valori $I(t)$ e $Q(t)$.

Questi valori si ricavano dal *digramma della costellazione*.

#align(center)[
  #image("assets/02/qpsk.png", width: 70%)
]

Quando vogliamo trasmettere un valore *AB* dobbiamo ricavare i valori di $I(t)$ e $Q(t)$ dalla costellazione, usando $A$ per il valore $I(t)$ e $B$ per il valore $Q(t)$.

In fase di ricezione facciamo l'operazione inversa, ovvero riceviamo un punto del piano, che va *mappato* nel punto più vicino della costellazione, usato per ricavare i due bit trasmessi.

Si chiama *quadratura* perché le due sinusoidi sono shiftate di $90°$.

===== X-QAM

In maniera simile possiamo definire il segnale di *X-QAM* come $ s(t) = I(t) cos(2 pi f_c t) - Q(t) sin(2 pi f_c t) . $

In questo caso però stiamo combinando *variazioni di ampiezza* e *fase*. Per ogni punto noi dobbiamo capire su quale *circonferenza* ci troviamo (ampiezza) e, successivamente, in che *punto* siamo (fase).

#align(center)[
  #image("assets/02/16qam.png", width: 70%)
]

Come vediamo, la costellazione (questa è di $16$-QAM) ora è molto più *densa* di prima. Come abbiamo fatto con QPSK, la prima metà dei bit è usata per $I(t)$ mentre la seconda metà dei bit è usata per $Q(t)$.

===== Confronto tra codifiche

// Esempio slide 80

La codifica X-QAM in generale ha un *data rate maggiore* rispetto a QPSK perché usiamo *meno simboli* per codificare gli stessi dati, quindi nell'unità di tempo ci stanno più simboli di X-QAM che di QPSK.

La soluzione sorge spontanea: carichiamo tantissimi bit per simbolo, così abbiamo un data rate altissimo e abbiamo una comunicazione fenomenale.

Questo non si può fare, e lo possiamo dimostrare con le *curve di BER* (Bit Error Rate). Queste curve rappresentano la *probabilità di errore di un bit* in funzione del rapporto tra la densità di energia del segnale per bit ed il livello di rumore.

// Forse immagine nuova
#align(center)[
  #image("assets/02/ber.png", width: 70%)
]

// Si può mettere la definizione della curva di BER

Mano a mano che il canale migliora noi abbassiamo la probabilità di errore, ma non tutte le codifiche lo fanno allo stesso modo e con la stessa velocità.

#align(center)[
  #image("assets/02/confronto.png", width: 70%)
]

Come vediamo, le codifiche più dense, a parità di probabilità di errore, richiedono una *qualità del canale* molto più alta.

Per questo noi dobbiamo cercare un *compromesso* tra codifica e qualità del canale: se la qualità è bassa e usiamo una codifica densa allora rischiamo di sbagliare il centroide della costellazione.

In poche parole usiamo uno schema *Adaptive Modulation and Coding* (AMC).

==== Forward Error Correction

Finiamo con la *Forward Error Correction* (FEC).

Se una funzione di *error detection* (lato ricevente) identifica la presenza di un errore allora il blocco dati viene ritrasmesso. Il problema è che nel mondo *wireless* sbagliare un bit è all'ordine del giorno, *è più facile sbagliare che farlo giusto*, quindi rischiamo di trasmettere lo stesso blocco all'infinito.

Per evitare questo loop infinito usiamo una *forward error correction*: andiamo ad abbassare il data rate aggiungendo della *ridondanza* tramite una serie di bit, che devono essere usati per verificare se ci sono stati errori.

Una misura di quanta ridondanza stiamo inserendo è il *coding rate*, definito come $ CR = k / n $ dove $k$ è il numero di *bit utili* e $n$ è il numero di bit totali.

A seconda delle *condizioni del canale* noi dobbiamo scegliere
+ quale *codifica* utilizzare;
+ quale *coding rate* utilizzare.

// Slide 89 01_intro_radio
