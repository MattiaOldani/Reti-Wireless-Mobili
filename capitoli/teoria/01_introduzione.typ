// Setup

#import "../alias.typ": *

#import "@local/typst-theorems:1.0.0": *
#show: thmrules.with(qed-symbol: $square.filled$)


// Capitolo

= Principi di teoria della trasmissione

Il modello generale di una *trasmissione dati* è riassunto nel seguente schema.

#align(center)[
  #image("assets/01/schema_ideale.png", width: 70%)
]

Nel nostro caso, la trasmissione sarà *analogica*, ovvero tramite *onde elettromagnetiche*.

Come vediamo, un *trasmettitore* codifica i *dati digitali* in ingresso $d(t)$ in *dati analogici* $s(t)$, che vengono poi spediti su un *canale* per raggiungere un *ricevitore*, che deve decodificare il segnale per ottenere nuovamente i dati $d(t)$.

Questo purtroppo è un *mondo ideale*: la situazione *reale* è la seguente.

#align(center)[
  #image("assets/01/schema_reale.png", width: 70%)
]

Nella realtà infatti sono presenti *fenomeni* di:
+ *attenuazione*, ovvero un *abbassamento della potenza del segnale* per via di una propagazione prolungata nel tempo;
+ *rumore*, ovvero la presenza di *altri segnali* che si sovrappongono al nostro segnale, come il *rumore termico* o *gaussiano*;
+ *interferenza*, ovvero la *condivisione* dello stesso spettro di frequenze.

Quello che si ottiene è quindi un segnale analogico $s'(t)$, che è ovviamente diverso dal segnale reale che è uscito dall'antenna del trasmettitore. Il nostro compito è capire il segnale $s'(t)$ nel tempo per poterlo ricostruire alla perfezione.

Nelle architetture moderne su cavo il *livello data link affidabile* è in disuso perché si ha una altissima affidabilità su *cavo*, quindi l'affidabilità si è spostata al *livello di trasporto*.

In ambito *wireless* il livello data link fornisce *spesso* la funzionalità di *affidabilità* perché il *canale* è *altamente inaffidabile*:
+ non si ha *protezione*;
+ il mezzo è *totalmente broadcast*;
+ non si possono creare *canali virtuali*.

Vedremo tecniche di *ridondanza* e *NACK*, a discapito di un *minore data rate*: infatti, a parità di banda e capacità del canale, il *throughput* via cavo è maggiore di quello wireless.

== Segnali

=== Domini di definizione

Possiamo *rappresentare un segnale*, analogico o digitale, utilizzando il *dominio del tempo*: questi grafici mostrano l'ampiezza di questi segnali, in Volt, al variare del tempo.

#align(center)[
  #image("assets/01/segnali.png", width: 70%)
]

In questi due grafici notiamo come:
+ il *segnale analogico* ha una variazione continua della sua intensità, senza interruzioni e discontinuità;
+ il *segnale digitale* mantiene un livello costante per un determinato periodo di tempo, e poi ha un cambio di livello quasi istantaneo.

Un segnale elettromagnetico è un *segnale analogico periodico*, spesso definito come una *sinusoidale*, ovvero $ s(t) = A sin(2 pi f t + phi) quad bar quad s(t + T) = s(t) "con" T "periodo" . $

In questa definizione notiamo *tre parametri fondamentali*:
+ *ampiezza* $A$, il massimo livello o *forza* del segnale nel tempo, definito in Volt;
+ *frequenza* $f$, il numero di cicli al secondo, definito in Hertz;
+ *fase* $phi$, la posizione relativa all'interno del periodo.

Dati questi tre parametri possiamo definire due *valori derivati*:
+ *periodo* $T$, ovvero il tempo impiegato per un ciclo, definito in secondi e calcolato come l'inverso della frequenza;
+ *lunghezza d'onda* $lambda$, ovvero la distanza occupata da un singolo ciclo, definito come $lambda = T c$.

Noi dobbiamo giocare con questi parametri per metterci dentro i bit da trasmettere.

Il dominio del tempo ci piace, ma si può utilizzare anche il *dominio delle frequenze*.

Ogni segnale periodico può essere *scomposto* in una serie di segnali periodici (seno e coseno) con ampiezze, frequenze e fasi differenti. Questo può essere fatto con la *Serie di Fourier* $ s(t) = 1/2 c + sum_(n=1)^infinity a_n sin(2 pi n f t) + sum_(n=1)^infinity b_n cos(2 pi n f t) $ dove:
+ $f$ è la *frequenza fondamentale*, definita come inverso del periodo;
+ $a_n$ e $b_n$ sono le ampiezze delle *armoniche* (con $n > 1$);
+ $c$ è la costante che rappresenta il *valore medio* del segnale.

Con questa formula noi possiamo decomporre ogni segnale periodico.

La *trasformata di Fourier* è la funzione $ cal(F){f(t)}(omega) = integral_(-infinity)^infinity f(t) e^(-i omega t) dif t $ che permette di ottenere le ampiezze delle frequenze del segnale.

L'*antitrasformata di Fourier* invece è l'inversa della trasformata, definita come $ f(t) = frac(1, 2 pi) integral_(-infinity)^infinity cal(F)(omega) e^(i omega t) dif omega $ che permette invece di ricavare il segnale dato lo spettro delle frequenze.

Questa funzione è fondamentale: permette di passare dal dominio del tempo al dominio delle frequenze (trasformata) e viceversa (antitrasformata).

Anche se fondamentale, questa funzione presenta alcuni *problemi*:
+ non avendo la nozione di infinito possiamo sì calcolare questa funzione ma dobbiamo introdurre degli *errori*, che però riusciamo a mantenere sotto una certa soglia;
+ la presenza del *rumore* in una *FFT* genera alcune frequenze non richieste con ampiezza non nulla;
+ può presentarsi l'*effetto doppler*, ovvero la frequenze shifta attorno alla frequenza reale.

=== Campionamento

Per determinare le ampiezze delle componenti di un segnale abbiamo a disposizione la trasformata di Fourier, mentre per ricavare il segnale usiamo l'antitrasformata.

Un ricevitore deve conoscere questo segnale, quindi deve *campionare* l'antenna. Questo campionamento deve essere fatto in maniera *discreta*, ma il tempo nel quale viviamo è continuo, quindi dobbiamo capire *quando* e *quante volte* campionare. Questo valore determina quanto veloce l'apparato fisico deve lavorare: più va veloce e più serve hardware specializzato.

#theorem([Teorema di campionamento di Shannon])[
  La frequenza di campionamento deve essere almeno il *doppio* della frequenza massima del segnale in ingresso, campionando ad intervalli regolari.
]

In un segnale periodico, costruito come somma di segnali periodici singoli, il *periodo* è il periodo della frequenza fondamentale $f$.

Lo *spettro del segnale* (spectrum) è il range di frequenze che lo contiene. La *banda del segnale* (absolute bandwidth) è invece l'ampiezza dello spettro.

=== Data rate

Vogliamo trasmettere un segnale digitale usando una combinazione di onde sinusoidali. In ogni periodo vogliamo trasmettere $alpha$ bit: quello che otteniamo è quindi un *data rate* di $alpha f$ bit al secondo, visto che mandiamo $alpha$ bit ad ogni ciclo, il cui numero è esattamente la frequenza $f$.

Dovendo approssimare un'*onda quadra* dobbiamo comporre delle armoniche, che però hanno energia più bassa mano a mano che aumentiamo il numero $n$ nella sommatoria. Nonostante ciò, un valore di $n$ alto permette una migliore approssimazione.

=== Rumore

Se abbiamo più livelli di voltaggio il *rumore* li può alterare, addirittura cambiandoli. Abbiamo diverse tipologie di rumore:
+ *termico*, rumore bianco di fondo, sempre presente;
+ *inter-modulare*, ottenuto durante la modulazione del segnale;
+ *cross talk*, presente quando ci sono dei cavi vicini;
+ *impulso*, rumore esterno rappresentato da una serie di impulsi.

#example()[
  Vediamo un esempio di come il rumore modifica il segnale.

  #align(center)[
    #image("assets/01/rumore.png", width: 70%)
  ]

  In questo caso un rumore molto aggressivo compromette due bit del segnale.

  Usando invece $M$ livelli di voltaggio questo effetto di distorsione può essere ben peggiore.
]

=== SNR

Per misurare il *rapporto tra due potenze* in scala logaritmica usiamo il *Decibel*, definito come $ (frac(P_1, P_2))_(decibel) = 10 log_10(frac(P_1, P_2)) . $

Quando invece fissiamo il denominatore a $1 mW$ otteniamo il *Decibel-milliWatt*, che l'unità di misura del rapporto tra una potenza arbitraria e $1 mW$.

Usiamo il *decibel* per descrivere il *rapporto segnale rumore*, o *Signal to Noise Ratio* (SNR). Vogliamo sapere quanto il nostro segnale è buono rispetto alla rumorosità del canale, e questo lo possiamo definire come $ (SNR)_decibel = 10 log_10(frac("potenza del segnale", "potenza del rumore")) . $

== Canale

=== Capacità

Definiamo la *capacità del canale* come il *massimo bit rate* al quale è possibile trasmettere dati su un canale di comunicazione in determinate condizioni.

Un *impulso rettangolare* lo si ottiene con una banda infinita, che ovviamente non possiamo avere. Usiamo quindi una *banda finita* molto grande, ma questo porta alcuni problemi:
+ presenza di *rumore* e *distorsione* maggiore in tutta la banda;
+ una banda maggiore non porta per forza un data rate maggiore;
+ *costi economici* elevati;
+ *limitazioni* fisiche e regolamentari del dispositivo.

Il primo risultato che abbiamo per la capacità del canale è la *banda di Nyquist*.

#definition([Banda di Nyquist])[
  Dato un canale *noise-free*, la banda $B$ limita il data rate.

  In un *segnale binario* ($2$ segnali di voltaggio) la capacità vale $ C = 2 B bits. $

  In un *segnale multi-livello* ($M$ segnali di voltaggio) la capacità vale $ C = 2 B log_2(M) bits . $
]

Come vediamo, Nyquist non tiene conto del rumore, ma noi ne abbiamo e anche *parecchio*.

#definition([Capacità del canale secondo Shannon])[
  La capacità del canale è la massima capacità teorica di un canale, in bit al secondo, in funzione del SNR, e vale $ C = B log_2(1 + SNR) . $
]

Questo risultato è *puramente teorico* e considera solo il rumore termico, ma comunque ci dà un limite superiore al data rate che può essere trasmesso senza errori.

Possiamo aumentare il data rate in due modi:
+ *aumentiamo la banda* $B$, ma il rumore termico è *bianco*, quindi maggiore è la banda e maggiore è il rumore del sistema;
+ *aumentiamo la potenza*, aumentando quindi il SNR, ma la potenza è limitata e si ha la presenza di rumore inter-modulare e cross talk.

L'unione delle due formule appena viste ci permette di calcolare i *livelli di voltaggio* che dobbiamo usare per raggiungere un certo data rate.

#example()[
  Supponiamo di avere a disposizione uno spettro tra $3"M"hertz$ e $4"M"hertz$ con un rapporto segnale rumore $SNR_decibel = 24 decibel$.

  Noi vogliamo sapere quanti *livelli di voltaggio* utilizzare.

  $
              B & = 4 - 3 = 1"M"hertz \
    SNR_decibel & = 10 log_10(SNR) = 24 decibel arrow.long SNR = 251 \
              C & = 10^6 log_2(1 + 251) approx 8"M"bps \
              C & = 2 B log_2(M) arrow.long M = 16 .
  $
]

#example()[
  Supponiamo di avere a disposizione uno spettro tra $3"M"hertz$ e $4"M"hertz$ con un rapporto segnale rumore $SNR_decibel = 12 decibel$.

  Noi vogliamo sapere ancora quanti *livelli di voltaggio* utilizzare.

  $
              B & = 4 - 3 = 1"M"hertz \
    SNR_decibel & = 10 log_10(SNR) = 12 decibel arrow.long SNR = 10^(1.2) approx 16 \
              C & = 10^6 log_2(1 + 16) approx 4"M"bps \
              C & = 2 B log_2(M) arrow.long M = 4 .
  $
]

=== Multiplexing

Esistono delle tecniche che dividono la comunicazione secondo alcuni criteri per ottimizzare l'uso del canale, aumentare il data rate e avere una serie di altri effetti positivi. Queste tecniche sono dette *tecniche di multiplexing*.

Spesso la capacità del mezzo di trasmissione è molto più grande della capacità della singola comunicazione: vogliamo ottenere più *sotto-canali*, quindi più segnali nello stesso mezzo. Questo ci permette di avere un *maggiore data rate* e un *minore costo* dei bit per secondo.

Il primo multiplexing che si può avere è il *Time-Division Multiplexing*.

#align(center)[
  #image("assets/01/tdm.png", width: 55%)
]

Questa divisione sfrutta il fatto che il data rate del mezzo di trasmissione *eccede* il data rate richiesto da un singolo segnale. Come notiamo, un istante di tempo viene diviso in più canali, nel quale ogni segnale può essere inviato. Lasciamo quindi tutta la banda ma ogni canale ha un tempo limitato per parlare.

In questo caso *non si ha interferenza*, ma è richiesta una *sincronizzazione* e si ha un *uso meno efficiente* della banda. Per permettere la sincronizzazione si usa spesso una *finestra di delay*.

Il secondo multiplexing che si può avere è il *Frequency-Division Multiplexing*.

#align(center)[
  #image("assets/01/fdm.png", width: 55%)
]

In questo caso le "fette" sono opposte: l'unità di tempo è usata per intero, ma la comunicazione avviene su *sotto-bande* diverse. Si sfrutta infatti il fatto che la banda disponibile sul mezzo di trasmissione *eccede* la banda del singolo segnale per avere il suo data rate.

In questo multiplexing *non serve una sincronizzazione temporale* e si usa la banda in maniera *efficiente*, ma si è suscettibili ad *interferenze* tra canali vicini. Per evitare fenomeno di interferenza si usa spesso una *banda di guardia*.

Il terzo multiplexing che si può avere è l'*Orthogonal Frequency-Division Multiplexing* (OFDM), molto simile all'FDM ma che aggiunge la caratteristica di *ortogonalità*.

Anche qui vengono creati dei *sotto-canali*, o *sotto-portanti*, cosi da poter avere dei flussi paralleli su frequenze diverse. La *frequenza* viene divisa in frequenze multiple di una certa frequenza $f_b$. La *banda* è quindi $N f_b$, con $N$ numero di canali che vogliamo creare.

In questo caso abbiamo una caratteristica di *ortogonalità*, che distanzia le varie frequenze in modo che quando abbiamo il picco di una le altre sono nulle.

Per applicare OFDM, prendiamo un *flusso seriale* di $R bps$ e lo trasformiamo, con un *converter*, in un *flusso parallelo*, che contiene $N$ flussi da $R / N bps$ ciascuno. Questi flussi sono le nostre *sotto-portanti*, che vengono modulate con la frequenza del canale selezionato, usando sempre lo stesso schema di modulazione e codifica.

#align(center)[
  #image("assets/01/divisione_OFDM.png", width: 50%)
]


L'onda risultante è poi la combinazione di tutte queste sotto-portanti, usando la *IFFT* per passare da questo dominio delle frequenze a quello del tempo.

La potenza di OFDM, rispetto a FDM, risiede nella *bandwidth*:
+ in *FDM* dobbiamo lasciare uno *spazio di guardia* tra le varie sotto-portanti per evitare delle interferenze;
+ in *OFDM* lo spazio di guarda *non esiste* perché le sotto-portanti sono ortogonali tra loro, e quindi la banda da utilizzare è molto più piccola.

Questa soluzione è nata negli anni $'60$, ma la sua implementazione in hardware è avvenuta molto dopo perché richiede una equalizzazione molto precisa.

OFDM e anche FDM sono molto comodi in molti protocolli perché la divisione in sotto-portanti permette di sceglierne alcune per i *pilot*, ovvero delle sotto-portanti che contengono un *segnale standard*, usato per capire la qualità del canale e quindi scegliere il MCS corretto.

La frequenza $f_b$ con la quale dividiamo lo spettro si calcola banalmente come $ f_b = 1 / T $ che è la frequenza di un *simbolo*, e tutti i segnali sono multipli di questo, quindi $M f_b$.

Vediamo come viene *implementato* OFDM.

#align(center)[
  #image("assets/01/implementazione_OFDM.png", width: 70%)
]

Come prima abbiamo una trasformazione da seriale a parallelo, l'applicazione della IFFT, poi impacchettiamo il segnale aggiungendo anche un *prefisso ciclico*, che viene utilizzato come preambolo per evitare le *interferenze*. Più le distanze di trasmissione sono lunghe e più è lungo il prefisso ciclico. Infine, avviene la modulazione e la trasmissione. Nella parte inferiore invece eseguiamo le operazioni al contrario.

OFDM è molto complesso, e infatti è *robusto* a:
+ interferenze che interessano solo alcune *sub-carrier*;
+ fenomeni di *multipath* visto che la distanza tra simboli è maggiore.

=== Multiple Access

La nozione di *Multiple Access* è spesso bistrattata e confusa con il *Multiplexing*.

Il *Multiple Access* è la condivisione del canale di comunicazione tra più utenti. Il *Multiplexing* è una tecnica usata per la creazione dei canali di comunicazione.

I due concetti sono diversi ma possono essere *uniti*: creiamo i canali di comunicazione con il *Multiplexing*, e ogni canale viene diviso usando *Multiple Access*.

== Comunicazione wireless

=== Banda base

Le trasmissioni su cavo avvengono in *banda base*, ovvero lo spettro utilizzato per la trasmissione va da $0hertz$ alla banda massima $B$.

#example([Spettro sonoro])[
  Lo *spettro sonoro* che siamo in grado di sentire va dagli $0hertz$ (in realtà poco più) fino ai $22"M"hertz$, quindi questa è in *banda base*.
]

Via cavo questo va benissimo, perché non dobbiamo *sintonizzarci* su un range di frequenze. Sul lato wireless ci sono invece molti *problemi*:
+ se tutti i dispositivi radio usano lo stesso spettro tutte le comunicazioni *interferiscono*;
+ più è bassa la frequenza è più l'antenna deve essere *grande*. Si stima che la grandezza deve essere circa la metà della lunghezza d'onda $lambda$ per antenne dipole;
+ ogni range di frequenze possiede diverse *proprietà* di propagazione e attenuazione.

=== Banda traslata

Quello che viene fatto per evitare questa sovrapposizione nelle trasmissioni è la trasmissione in *banda traslata*, o *banda passante*. Viene scelta una *frequenza carrier*, o *frequenza portante*, e lo spettro da $[0,B]$ viene traslato in $ [f_c - B/2, f_c + B/2] $ dove $f_c$ rappresenta la frequenza carrier.

Come vediamo, la *bandwidth* è mantenuta, avendo effettuato una traslazione delle frequenze massima e minima. Inoltre, manteniamo lo *stesso data rate* di partenza.

#align(center)[
  #image("assets/01/carrier.png", width: 70%)
]

Come vediamo, dopo l'*encoding* avviene prima una *modulazione* con la frequenza portante, modificando i *tre parametri* base di una sinusoide, e poi un'*amplificazione*.

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

=== Antenne

Dato per assodato che la *terra è tonda*, le onde radio si *propagano* in tre modi diversi, ma a noi interesserà solo la trasmissione *Line of Sight* (LoS), ovvero i due ricevitori si devono vedere per poter parlare. La comunicazione avviene tramite *antenne*.

#align(center)[
  #image("assets/01/antenne.png", width: 70%)
]

A sinistra abbiamo un'*antenna omnidirezionale*, ovvero un'*antenna ideale*, che però non è sempre voluta. A destra invece abbiamo un'*antenna direzionale*, che ha un grande *lobo* che punta in *una direzione* e altri piccoli lobi per coprire le altre direzioni.

Tendenzialmente le antenne direzionali sono quelle usate per le *comunicazioni* perché concentrano l'energia in una certa direzione, ovvero la direzione LoS.

== Problemi da affrontare

La *trasmissione radio LoS* presenta molti problemi:
+ *free space loss* e *path loss*, che abbiamo anche su cavo (solo path loss), ed è una *attenuazione del segnale* dovuta alla distanza e all'ambiente in cui il segnale si propaga;
+ *rumore*, al quale siamo sempre sensibili visto che non abbiamo protezione;
+ *multipath*, che grazie a fenomeni di *riflessione*, *diffrazione* e *scattering* causa la ricezione di più onde dello stesso segnale in tempi diversi;
+ *effetto doppler*, ovvero si ha una variazione del segnale a causa del *movimento* di TX, RX e ostacoli; una velocità ampia porta una differenza ampia.

=== Path loss

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
  #image("assets/01/pathloss.png", width: 60%)
]

In questa immagine vediamo quanti decibel perdiamo, indicati sull'asse $y$, data una certa distanza tra TX e RX, indicata sull'asse $x$.

Il *gain*, o *guadagno*, di un'antenna è definito come il *rapporto* tra l'intensità della radiazione elettromagnetica in una data direzione e l'intensità che si avrebbe se si usasse un'antenna isotropica. Le *antenne isotropiche* sono le antenne ideali.

Il gain si indica con $G$ ed è misurato in *decibel isotropici*, indicati con dBi. Questa quantità ci aiuta con il path loss: avendo delle antenne direzionali noi stiamo concentrando l'energia in una certa direzione, quindi dal path loss dobbiamo *togliere* alcune quantità.

Il nuovo path loss, non misurato in decibel, diventa $ frac(P_t, P_r) & = frac((4 pi f)^2, G_tx G_rx c^2) d^n $ che poi trasformati in *decibel* ci dà una perdita pari a $ L_decibel = 10 log_10(frac(P_t, P_r)) = 20 (log_10(frac(4 pi f d, c)) - underbracket(log_10(G_tx), "gain tx") - underbracket(log_10(G_rx), "gain rx")) . $

Questi conti sono ovviamente a parità di distanza e ambiente free space: con le antenne direzionali abbiamo un *path loss minore*.

=== Multipath

Il *multipath* si presenta quando l'ambiente è *complesso* e possono presentarsi effetti di:
+ *riflessione* del segnale;
+ *scattering*, che spara il segnale in tutte le direzioni perché la lunghezza d'onda del segnale è simile a quella dell'oggetto;
+ *diffrazione*, che è come lo scattering ma avviene sui bordi perché la lunghezza d'onda del segnale è molto più piccola di quella dell'oggetto.

#align(center)[
  #image("assets/01/multipath.png", width: 45%)
]

Come vediamo, per fare da TX a RX abbiamo il segnale *LoS* ma anche molti altri percorsi, dovuti agli effetti appena presentati. Il multipath può provocare due *effetti fastidiosi*: il fading e l'interferenza inter-simbolo.

Il *fading*, o evanescenza, avviene quando si ha *interferenza distruttiva* tra più onde elettromagnetiche. Abbiamo due tipi di interferenza: *costruttiva*, che va ancora ancora bene, e *distruttiva*, che è fastidiosa perché abbassa i picchi e crea un'onda che non c'entra niente con quella di partenza.

Per risolvere questo problema dobbiamo garantire un *tempo di coerenza*, ovvero una scala temporale in cui possiamo considerare "costanti" le caratteristiche del segnale. Questo tempo di coerenza è tale che $ T_c = 1 / f_D . $

Questo valore dipende dalla *frequenza doppler*, basata sulla velocità di movimento e sulla frequenza, ed è tale che $ f_D = (v / c) f_c . $

Se abbiamo alta velocità e alta frequenza allora abbiamo un periodo molto basso, e quindi dobbiamo *campionare* più spesso il segnale.

Nel prossimo esempio vediamo una serie di segnali che vanno incontro al problema del fading.

#example([Fading])[
  Allunghiamo per bene questi appunti.

  Nella prima immagine vediamo l'effetto del path loss, che rende più debole il segnale.

  #align(center)[
    #image("assets/01/fading01.png", width: 75%)
  ]

  Nella seconda immagine abbiamo invece l'effetto del fading con $2$ path che non sono LoS.

  #align(center)[
    #image("assets/01/fading02.png", width: 75%)
  ]

  Nella terza immagine aggiungiamo l'effetto doppler ai segnali precedenti.

  #align(center)[
    #image("assets/01/fading03.png", width: 75%)
  ]

  Infine, nell'ultima immagine aggiungiamo anche il rumore.

  #align(center)[
    #image("assets/01/fading04.png", width: 75%)
  ]
]

L'*interferenza inter-simbolo* (ISI) avviene molto spesso in ambito mobile.

Questo fenomeno si presenta come una *ricezione sovrapposta* di simboli adiacenti a causa del ritardo di ricezione delle onde del primo simbolo.

Se l'intervallo di tempo tra un simbolo e l'altro è molto breve può succedere che se le onde non LoS del primo simbolo arrivino al RX nello stesso momento in cui arrivano le onde LoS del secondo simbolo. In poche parole siamo così sfigati che interferiamo con *noi stessi*.

Se siamo *distanti* questo effetto è molto presente, quindi per risolverlo bisogna *aumentare la distanza tra i simboli*, a discapito di un minor data rate. Se invece siamo *vicini* l'effetto è poco presente, quindi possiamo tenere i simboli più vicini e quindi *aumentare* il data rate.

== Codifica e trasmissione dei dati

Nella seguente immagine vediamo lo *schema della trasmissione radio*.

#align(center)[
  #image("assets/01/schema.png", width: 70%)
]

Il nostro segnale digitale prima passa nel blocco *FEC* con l'*encoder*, poi viene *modulato* sulla frequenza portante e infine viene *amplificato*. Una volta spedito sul canale il ricevitore deve *demodulare* il segnale e farlo passare ancora in un blocco FEC con una *decodifica*.

Come vedremo, i blocchi FEC e di modulazione sono *dinamici*, ovvero dipendono dal canale.

=== Codifiche semplici

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
    #image("assets/01/encoding.png", width: 70%)
  ]

  Come vediamo, i primi due segnali sono ok, ma "sentire" un cambiamento in queste onde è abbastanza difficile se non si ha un segnale di ottima qualità. Il terzo segnale invece è pieno di *interruzioni di fase*, che sono molto semplici da vedere e sentire.
]

Una versione alternativa del robusto phase-shift è il *Differential Phase-Shift Keying* (DPSK), che non ha una codifica fissa ma *variabile*: ogni volta che leggo uno $0$ *mantengo la fase*, mentre ogni volta che leggo un $1$ la fase viene *shiftata* di $180°$. Questa tecnica è molto comoda perché non richiede un allineamento preciso e si *identifica* facilmente.

=== Codifiche sofisticate

Esistono delle codifiche più *sofisticate*, che permettono di trasmettere più di un bit per simbolo:
+ *Multilevel Frequency-Shift Keying* (MFSK), nel quale la *M* del nome indica il numero di livelli di voltaggio, con i quali codifichiamo $L = log_2(M)$ bit;
+ *Quadrature Phase-Shift Keying* (QPSK), che codifica $2$ bit per simbolo;
+ *Quadrature Amplitude Modulation* (X-QAM), nel quale la *X* del nome permette di ricavare il numero di bit codificati come $L = log_2(X)$.

Con *QPSK* riusciamo a mandare $2$ bit per ciascun simbolo usando un segnale $ s(t) = cases(A cos(2 pi f_c t + pi / 4) & "se" 11, A cos(2 pi f_c t + frac(3 pi, 4)) quad & "se" 01, A cos(2 pi f_c t - frac(3 pi, 4)) & "se" 00, A cos(2 pi f_c t - pi / 4) & "se" 10) $ formato da $4$ fasi diverse distanziate di $90°$ e usando una codifica Gray per i punti adiacenti.

Questo segnale può essere "compresso" in una formula unica $ s(t) = 1/sqrt(2) I(t) cos(2 pi f_c t) - 1/sqrt(2) Q(t) sin(2 pi f_c t) $ che dipende dai valori $I(t)$ e $Q(t)$, che si ricavano dal *digramma della costellazione*.

#align(center)[
  #image("assets/01/qpsk.png", width: 45%)
]

Quando vogliamo trasmettere un valore *AB* dobbiamo ricavare i valori di $I(t)$ e $Q(t)$ dalla costellazione, usando $A$ per il valore $I(t)$ e $B$ per il valore $Q(t)$.

In fase di ricezione facciamo l'operazione inversa, ovvero riceviamo un punto del piano, che va *mappato* nel punto più vicino della costellazione, usato per ricavare i due bit trasmessi.

Si chiama *quadratura* perché le due sinusoidi sono shiftate di $90°$.

In maniera simile possiamo definire il segnale di *X-QAM* come $ s(t) = I(t) cos(2 pi f_c t) - Q(t) sin(2 pi f_c t) . $

In questo caso però stiamo combinando *variazioni di ampiezza* e *fase*. Per ogni punto noi dobbiamo capire su quale *circonferenza* ci troviamo (ampiezza) e, successivamente, in che *punto* siamo (fase).

#align(center)[
  #image("assets/01/16qam.png", width: 55%)
]

Come vediamo, la costellazione (questa è di $16$-QAM) ora è molto più *densa* di prima. Come abbiamo fatto con QPSK, la prima metà dei bit è usata per $I(t)$ mentre la seconda metà dei bit è usata per $Q(t)$.

=== Confronto tra codifiche

La codifica X-QAM in generale ha un *data rate maggiore* rispetto a QPSK perché usiamo *meno simboli* per codificare gli stessi dati, quindi nell'unità di tempo ci stanno più simboli di X-QAM che di QPSK.

La soluzione sorge spontanea: carichiamo tantissimi bit per simbolo, così abbiamo un data rate altissimo e abbiamo una comunicazione fenomenale.

Questo non si può fare, e lo possiamo dimostrare con le *curve di BER* (Bit Error Rate). Queste curve rappresentano la *probabilità di errore di un bit* in funzione del rapporto tra la densità di energia del segnale per bit ed il livello di rumore.

#align(center)[
  #image("assets/01/ber.png", width: 60%)
]

Mano a mano che il canale migliora noi abbassiamo la probabilità di errore, ma non tutte le codifiche lo fanno allo stesso modo e con la stessa velocità.

#align(center)[
  #image("assets/01/confronto.png", width: 60%)
]

Come vediamo, le codifiche più dense, a parità di probabilità di errore, richiedono una *qualità del canale* molto più alta. Per questo noi dobbiamo cercare un *compromesso* tra codifica e qualità del canale: se la qualità è bassa e usiamo una codifica densa allora rischiamo di sbagliare il centroide della costellazione.

In poche parole usiamo uno schema *Adaptive Modulation and Coding* (AMC).

=== Confronto tra codifiche con esercizio

Vediamo un tipico esercizio d'esame su *Modulation and Coding Scheme*.

#example[
  Dobbiamo determinare il *data rate massimo* dato:
  + un SNR di $8decibel$;
  + un target BER di $10^(-2)$.

  #align(center)[
    #image("assets/01/grafico.png", width: 65%)
  ]

  Come vediamo abbiamo il SNR sull'asse $x$ e la probabilità di errore sull'asse $y$. Ci viene data anche la tabella dei coding rate.

  #align(center)[
    #image("assets/01/tabella.png", width: 50%)
  ]

  Avendo $8decibel$ prendiamo l'asse verticale centrato in $8$. Prendiamo anche il BER indicato sull'asse delle y.

  Per capire quali *costellazioni* sono *ammissibili* dobbiamo vedere quali curve andiamo ad intersecare con l'asse verticale, sotto il BER dato: in questo caso teniamo *BPSK* e *QPSK*, mentre escludiamo *$16$-QAM*.

  Per calcolare il data rate delle due costellazioni dobbiamo fare $ (syms) times (bpsym) times CR = bits . $

  Per *BPSK* abbiamo $ (1000 syms) times (1 bpsym) times 0.8 = 800 bps $ mentre per *QPSK* abbiamo $ (1000 syms) times (2 bpsym) times 0.6 = 1200 bps . $

  Il data rate massimo è quindi $1200bps$ di *QPSK*.
]

=== Forward Error Correction

Se una funzione di *error detection* (lato ricevente) identifica la presenza di un errore allora il blocco dati viene ritrasmesso. Il problema è che nel mondo *wireless* sbagliare un bit è all'ordine del giorno, *è più facile sbagliare che farlo giusto*, quindi rischiamo di trasmettere lo stesso blocco all'infinito.

Per evitare questo loop infinito usiamo una *Forward Error Correction* (FEC): andiamo ad abbassare il data rate aggiungendo della *ridondanza* tramite una serie di bit, che devono essere usati per verificare se ci sono stati errori.

Una misura di quanta ridondanza stiamo inserendo è il *coding rate*, definito come $ CR = k / n $ dove $k$ è il numero di *bit utili* e $n$ è il numero di bit totali.

A seconda delle *condizioni del canale* noi dobbiamo scegliere
+ quale *codifica* utilizzare;
+ quale *coding rate* utilizzare.

== Spread spectrum

Lo *Spread Spectrum*, o spettro espanso, è una tecnica che consiste nel trasmettere il segnale su uno spettro di frequenze *più ampio* di quello del segnale di partenza.

Questo è abbastanza contro-intuitivo, perché prima cercavamo di usare meno spettro possibile, visto che è costoso e mi butta dentro un sacco di rumore.

In questo caso la soluzione è molto *robusta* e ci permette di:
+ avere *immunità* a diversi tipi di rumore e distorsioni multipath;
+ *nascondere* e *cifrare* il segnale;
+ permettere a più utenti di usare la stessa banda *contemporaneamente* (CDMA).

#align(center)[
  #image("assets/01/SS.png", width: 75%)
]

In questo schema vediamo una versione generale del Spread Spectrum: una volta che i dati sono stati codificati passiamo per un *modulatore*, che utilizza un *codice di spreading* (random o prefissato), che mappa la banda originale su una mappa più ampia. Questo codice ovviamente deve essere *condiviso*, altrimenti la de-modulazione non funziona.

=== FHSS

Una prima tecnica di Spread Spectrum è *FHSS*, o Frequency Hopping Spread Spectrum. In questo caso, il codice di spreading usato è l'*indice* di una sotto-frequenza da usare per la trasmissione. Ad ogni intervallo di tempo la frequenza viene cambiata, ecco perché si chiama *Frequency Hopping*.

#align(center)[
  #image("assets/01/FHSS.png", width: 80%)
]

Come vediamo, abbiamo sempre modulazione e codifica, ma poi abbiamo il *FH spreader*, che permette di passare allo spettro espanso. Il passaggio avviene tramite una *lookup table*, che contiene la frequenza sulla quale trasmettere in base ad un valore generato random.

Sono fondamentali due cose:
+ *sincronia temporale*, visto che passiamo da una frequenza all'altra;
+ *conoscenza* della sequenza random.

Questa tecnica ha numerosi *punti di forza*:
+ resistente al *rumore*, al *jamming concentrato* (su una sola frequenza, potente ma noi abbiamo più frequenze) e *generico* (su tutta la banda, meno efficace);
+ se un altro ricevitore si *sincronizza* con il trasmettitore può solo leggere alcuni pezzi dei messaggi perché *non conosce* la sequenza di FH. Questo vale anche perché provare a leggere tutto lo spettro è costoso e non esistono hardware che lo fanno bene.

Questa tecnica garantisce quindi *sicurezza al livello fisico*, ma può anche essere evitata se la sicurezza viene implementata ai livelli superiori.

=== DSSS

Una seconda tecnica di Spread Spectrum è il *DSSS*, o Direct Sequence Spread Spectrum. In questo caso non saltiamo più tra le frequenze, ma usiamo una soluzione alternativa.

Data una sequenza di bit $D$, ogni bit di questa viene rappresentato da un insieme di bit, che è ricavato dal *codice di spread*. Ogni bit di informazione viene infatti rappresentato da $N$ bit, ottenuti dallo *XOR* tra il bit di informazione e $N$ bit generati casualmente.

Gli $N$ bit che otteniamo sono più piccoli, durano $1/N$ dei bit di informazione, e sono chiamati *chip*. Volendo mantenere lo *stesso data rate* ci servirà $N$ volte la banda di partenza.

#example[
  Vediamo un esempio di come funziona DSSS.

  #align(center)[
    #image("assets/01/esempio_DSSS.png", width: 70%)
  ]

  In questo caso ogni dato di input (verde) diventa una sequenza di $4$ chip (blu). Il dato di input e la sequenza sono messi in XOR per calcolare cosa mandare sul canale (rosso).

  Quando riceviamo facciamo l'opposto, ovvero mettiamo in XOR il segnale e la sequenza, ottenendo il segnale originale.
]

Vediamo ora lo *schema* di *DSSS*

#align(center)[
  #image("assets/01/schema_DSSS.png", width: 70%)
]

In questo caso il sistema è più semplice e veloce perché non avviene nessuna *lookup*.

=== CDMA

L'ultima tecnica che vediamo è *CDMA*, o Code Division Multiple Access.

Data una sequenza di bit $D$, ogni bit di questa viene convertito in un insieme di $k$ chip (quindi la banda diventa $k$ volte tanto) usando un *pattern prefissato* detto *codice*. Perdiamo quindi la proprietà di *pseudo-casualità*.

Una sequenza di *chip* è formata da $1$ e $-1$, e queste sequenze possono essere:
+ *ortogonali* (sequenze di Walsh, poche);
+ *quasi ortogonali* (sequenze di PN, Gold e Kasami, che sono di più).

L'accesso multiplo al canale avviene dando a ciascun dispositivo un *codice ortogonale diverso*, evitando quindi che questi vadano a collidere. Con questa tecnica noi possiamo parlare tutti assieme con l'entità che dà i codici perché questa qui, con i codici, è in grado di capire da chi è arrivato un dato messaggio.

Quando un utente ha il *codice*, manda esattamente quello se vuole trasmettere un $1$, mentre calcola il chip complementare (tutto per $-1$) se vuole trasmettere uno $0$.

Vediamo come funziona CDMA: prima vediamo come codici diversi abbiano delle codifiche diverse, poi vediamo come fa il ricevitore a decodificare il messaggio.

#example[
  Vogliamo spedire i bit $1101$.

  #align(center)[
    #image("assets/01/codifica_CDMA.png", width: 70%)
  ]

  Come vediamo, tre codici diversi codificano in diversi modi lo stesso dato.
]

Un ricevitore per distinguere tra $0$ e $1$ calcola la seguente *funzione* $ s_u (d) = sum_(i=1)^k d_i dot c_i $ dove $d$ è la sequenza ricevuta e $c$ è il codice scelto per decodificare.

Se abbiamo scelto il *codice corretto* per decodificare il segnale otteniamo:
+ $k$ se il trasmettitore ha inviato $1$;
+ $-k$ se il trasmettitore ha inviato $0$.

Se invece abbiamo scelto il *codice sbagliato* otteniamo $0$ se i codici sono *ortogonali*, oppure un valore più vicino a $0$ che a $plus.minus k$ se i codici *non* sono *ortogonali*.

Una cosa interessante è che questo funziona anche quando i *segnali* sono *combinati*. Se più utenti parlano *contemporaneamente* noi siamo in grado di ottenere:
+ somma $plus.minus k$ se abbiamo scelto il *codice corretto*;
+ valori più vicini a $0$ che a $plus.minus k$ se abbiamo scelto il *codice sbagliato*.

Vediamo lo *schema* di come funziona CDMA.

#align(center)[
  #image("assets/01/schema_CDMA.png", width: 70%)
]

Come vediamo, ogni utente va a modulare il segnale usando il proprio *codice*, ma anche in caso di trasmissioni contemporanee il ricevitore è in grado di *decodificare* usando la conoscenza di tutti i codici.

Diamo una *valutazione* su CDMA:
+ più siamo in pochi e più possiamo usare dei codici piccoli, quindi il *data rate* è *maggiore* (potenzialmente);
+ più siamo in tanti e più i codici sono ampi, quindi il *data rate* è *minore*;
+ funziona molto bene in *ambito satellitare* perché tutti i satelliti sono alla stessa distanza.

L'ultimo punto della valutazione è anche un *punto di debolezza*: se siamo in tanti a trasmettere, tutti con la *stessa potenza* ma a *distanze diverse*, gli utenti più lontani sono più *difficili* da *interpretare*. Questo perché in caso di ricezioni simultanee è necessario avere tutti i segnali con la stessa potenza per effettuare un calcolo corretto.

Questo problema è anche detto *Near-Far problem*, che può essere risolto usando delle potenze diverse in base alla *distanza* tra TX e RX. Facile, ok, però i dispositivi che sono più lontani hanno un *dispendio energetico* maggiore, e questo sui *dispositivi mobili* pesa e non poco.

#align(center)[
  #image("assets/01/nearfar.png", width: 70%)
]

== ISM Band

Terminiamo con qualche nozione preliminare sulle *bande ISM*.

Le *Industrial, Scientific and Medical Band*, o ISM Band, sono porzioni dello spettro riservate ad usi industriali, scientifici e medici.

In poche parole sono *range di frequenze* che possiamo usare *senza licenza* (unlicensed) quando progettiamo dispositivi industriali, scientifici e medici.

Esistono anche bande dello spettro che sono *sotto licenza*, ma quelle sono acquistate da grandi aziende, soprattutto operatori telefonici.

Avendo tante tecnologie, abbiamo anche tante *interferenze*: ad esempio, sulla stessa frequenza del Wi-fi noi abbiamo anche la frequenza di un microonde.

Parliamo infine di *Pulse Code Modulation* (PCM). Quando riceviamo un segnale sappiamo come *campionarlo* grazie a Shannon, ma dobbiamo capire come *quantizzare* l'onda continua che ci arriva per avere tutte le frequenze di quel segnale.

Per *digitalizzare* il segnale scegliamo quindi dei *punti di campionamento*, nei quali noi misuriamo il segnale, e poi scegliamo anche degli intervalli, detti *livelli di quantizzazione*, nei quali noi portiamo il segnale, basandoci su quello più vicino.

#align(center)[
  #image("assets/01/PCM.png", width: 60%)
]

Ovviamente, una griglia più fitta ci dà una migliore *approssimazione* perché possiamo vedere più frequenze del segnale ricevuto. Una modulazione $N$-PCM usa $N$ bit per quantizzare, quindi abbiamo a disposizione $2^N$ livelli di segnale.
