// Setup

#import "alias.typ": *

#import "@local/typst-theorems:1.0.0": *
#show: thmrules.with(qed-symbol: $square.filled$)


// Lezione
// Inizio 01_intro_radio

= Lezione 01 [16/01]

== Introduzione

In questo corso tratteremo dei *dispositivi* che comunicano *wireless* (quindi senza *isolamento*) utilizzando almeno un *hop* ad un punto di accesso alla rete, detto *access point*.

Noi vedremo tre grandi tipologie di dispositivi:
+ *tecnologie a corto raggio*, come il *bluetooth*, che accettano un basso numero di dispositivi e sono indicati per l'uso estremamente locale;
+ *tecnologie wireless ma non mobili*, come il *Wi-fi*, che cerca di dare un alto data rate ma ha una bassa proprietà di *mobilità*;
+ *tecnologie wireless e mobili*, come la *rete cellulare*, che permette il roaming tra access point e la presenza di un alto numero di utenti senza che il servizio e la qualità del servizio cadano, a discapito però di un data rate più basso.

Grazie agli access point siamo in grado di collegarci ai *servizi cloud* ed *edge*, che nient'altro sono che servizi cloud spostati vicino all'utente.

#align(center)[
  #image("assets/01/evoluzione.png", width: 70%)
]

Nella foto precedente vediamo l'evoluzione della rete cellulare di decennio in decennio. In particolare possiamo dire che:
+ in *1G* sono state introdotte le chiamate analogiche in mobilità;
+ in *2G* nasce uno standard globale e si implementa la voce digitale;
+ in *3G* nasce effettivamente il mondo internet;
+ in *4G* viene usata una banda larga in mobilità;
+ in *5G* si ha la virtualizzazione della rete;
+ in *6G* vedremo un uso massiccio di AI e ML.

Nel tempo sono cambiati anche i *servizi*. Più andiamo avanti e più la rete si *specializza*: non esiste una soluzione che va bene per tutto, ma ogni tecnologia ha un particolare nel quale spicca.

Le reti wireless e mobili hanno tantissime applicazioni:
+ *IoT e smart city*, che tramite un elevatissimo numero di sensori ed attuatori, gestiti dalla rete, permettono di controllare il traffico e altri aspetti delle città;
+ *guida assistita e autonoma*, che usa reti Wi-fi o mobili molto rapide per permettere una response action quasi istantanea, non potendo cablare le macchine lol;
+ *smart factories*, o Industry 4.0, che hanno un loop simile al precedente.

== Principi di teoria della trasmissione

Il modello generale di una *trasmissione dati* è riassunto nel seguente schema.

#align(center)[
  #image("assets/01/schema.png", width: 70%)
]

Nel nostro caso, la trasmissione sarà *analogica*, ovvero tramite *onde elettromagnetiche*.

Come vediamo, un *trasmettitore* codifica i *dati digitali* in ingresso $d(t)$ in *dati analogici* $s(t)$, che vengono poi spediti su un *canale* per raggiungere un *ricevitore*, che deve decodificare il segnale per ottenere nuovamente i dati $d(t)$.

Questo purtroppo è un *mondo ideale*: la situazione reale è quella dell'immagine successiva.

#align(center)[
  #image("assets/01/schema_reale.png", width: 70%)
]

Nella realtà infatti sono presenti *fenomeni* di:
+ *attenuazione*, ovvero un *abbassamento della potenza del segnale* per via di una propagazione prolungata nel tempo;
+ *rumore*, ovvero la presenza di *altri segnali* che si sovrappongono al nostro segnale, come il *rumore termico* o *gaussiano*;
+ *interferenza*, ovvero la *condivisione* dello stesso spettro di frequenze.

Quello che si ottiene è quindi un segnale analogico $s'(t)$, che è ovviamente diverso dal segnale reale che è uscito dall'antenna del trasmettitore. Il nostro compito è capire il segnale $s'(t)$ nel tempo per poterlo ricostruire alla perfezione.

Nelle architetture moderne su cavo il *livello data link affidabile* è in disuso perché si ha una altissima affidabilità su *cavo*, quindi la proprietà di affidabilità si è spostata al *livello di trasporto*.

In ambito *wireless* il livello data link fornisce *spesso* la funzionalità di *affidabilità* perché il *canale* è *altamente inaffidabile*:
+ non si ha *protezione*;
+ il mezzo è *totalmente broadcast*;
+ non si possono creare *canali virtuali*.

Vedremo quindi tecniche di *ridondanza* e *NACK*, a discapito di un *minore data rate*: infatti, a parità di banda e capacità del canale, il *throughput* via cavo è maggiore di quello wireless.

=== Dominio del tempo

Possiamo *rappresentare un segnale*, analogico o digitale, utilizzando il *dominio del tempo*: questi grafici mostrano l'ampiezza di questi segnali, in Volt, al variare del tempo.

#align(center)[
  #image("assets/01/segnali.png", width: 70%)
]

In questi due grafici notiamo come:
+ il *segnale analogico* ha una variazione continua della sua intensità, senza interruzioni e discontinuità;
+ il *segnale digitale* mantiene un livello costante per un determinato periodo di tempo, e poi ha un cambio di livello quasi istantaneo.

I *segnali* che abbiamo quindi sono esattamente il segnale $s(t)$ dello schema precedente.

Un segnale elettromagnetico è un *segnale analogico periodico*, spesso definito come una *sinusoidale*, ovvero $ s(t) = A sin(2 pi f t + phi) quad bar quad s(t + T) = s(t) "con" T "periodo" . $

In questa definizione notiamo *tre parametri fondamentali*:
+ *ampiezza* $A$, ovvero il massimo livello o *forza* del segnale nel tempo, definito in Volt;
+ *frequenza* $f$, ovvero il numero di cicli al secondo, definito in Hertz;
+ *fase* $phi$, ovvero la posizione relativa all'interno del periodo.

Dati questi tre parametri possiamo definire due *valori derivati*:
+ *periodo* $T$, ovvero il tempo impiegato per un ciclo, definito in secondi e calcolato come l'inverso della frequenza;
+ *lunghezza d'onda* $lambda$, ovvero la distanza occupata da un singolo ciclo, definito come $lambda = T c$.

Vediamo un esempio di alcune sinusoidali con vari parametri.

#align(center)[
  #image("assets/01/sinusoidali.png", width: 70%)
]

Noi dobbiamo giocare con questi parametri per metterci dentro i bit da trasmettere.

=== Dominio delle frequenze

Il dominio del tempo ci piace, ma si può utilizzare anche il *dominio delle frequenze*.

Ogni segnale periodico può essere *scomposto* in una serie di segnali periodici (onde seno e coseno) con ampiezze, frequenze e fasi differenti. Questo può essere fatto con la *Serie di Fourier* $ s(t) = 1/2 c + sum_(n=1)^infinity a_n sin(2 pi n f t) + sum_(n=1)^infinity b_n cos(2 pi n f t) $ dove:
+ $f$ è la *frequenza fondamentale*, definita come inverso del periodo;
+ $a_n$ e $b_n$ sono le ampiezze delle *armoniche* (con $n > 1$);
+ $c$ è la costante che rappresenta il *valore medio* del segnale.

Con questa formula noi possiamo decomporre ogni segnale periodico.

La *trasformata di Fourier* è la funzione $ cal(F){f(t)}(omega) = integral_(-infinity)^infinity f(t) e^(-i omega t) dif t $ che permette di ottenere l'ampiezza della frequenze del segnale.

L'*antitrasformata di Fourier* invece è l'inversa della trasformata, definita come $ f(t) = frac(1, 2 pi) integral_(-infinity)^infinity cal(F)(omega) e^(i omega t) dif omega $ che permette invece di ricavare il segnale dato lo spettro delle frequenze.

Questa funzione è fondamentale: permette di passare dal dominio del tempo al dominio delle frequenze (trasformata) e viceversa (antitrasformata).

Anche se fondamentale, questa funzione presenta alcuni *problemi*:
+ non avendo la nozione di infinito possiamo sì calcolare questa funzione ma dobbiamo introdurre degli *errori*, che però riusciamo a mantenere sotto una certa soglia;
+ la presenza del *rumore* in una *FFT* genera alcune frequenze non richieste con ampiezza non nulla;
+ può presentarsi l'*effetto doppler*, ovvero la frequenze shifta attorno alla frequenza reale.

=== Campionamento

Per determinare le ampiezze di delle componenti di un segnale abbiamo a disposizione la trasformata di Fourier, mentre per ricavare il segnale usiamo l'antitrasformata.

Un ricevitore deve conoscere questo segnale, quindi deve *campionare* l'antenna. Questo campionamento deve essere fatto in maniera *discreta*, ma il tempo nel quale viviamo è continuo, quindi dobbiamo capire *quando* e *quante volte* campionare. Questo valore determina quanto veloce l'apparato fisico deve lavorare: più va veloce e più serve hardware specializzato.

Abbiamo un risultato utile al nostro problema.

#theorem([Teorema di campionamento di Shannon])[
  La frequenza di campionamento deve essere almeno il *doppio* della frequenza massima del segnale in ingresso, campionando a intervalli regolari.
]

In un segnale periodico, costruito come somma di segnali periodici singoli, il *periodo* è il periodo della frequenza fondamentale $f$.

Lo *spettro del segnale* (spectrum) è il range di frequenze che lo contiene. La *banda del segnale* (absolute bandwidth) è invece l'ampiezza dello spettro.

=== Data rate

Vogliamo trasmettere un segnale digitale usando una combinazione di onde sinusoidali. In ogni periodo vogliamo trasmettere $alpha$ bit. Quello che otteniamo è quindi un *data rate* di $alpha f$ bit al secondo: infatti, noi mandiamo $alpha$ bit ad ogni ciclo, ma il numero di cicli è esattamente la frequenza $f$.

Dovendo approssimare un'*onda quadra* dobbiamo comporre delle armoniche, che però hanno energia più bassa mano a mano che aumentiamo il numero $n$ nella sommatoria. Nonostante ciò, un valore di $n$ alto permette una migliore approssimazione.

La formula che si utilizza per approssimare un'onda quadra è $ s(t) = frac(4 A, pi) sum_(k = 1 and k "dispari") frac(sin(2 pi k f t), k) . $

=== Capacità del canale

Definiamo la *capacità del canale* come il *massimo bit rate* al quale è possibile trasmettere dati su un canale di comunicazione in determinate condizioni.

Il *rumore* è un segnale *NON VOLUTO* che si combina al segnale trasmesso, alternandolo e distorcendolo.

L'*error rate* è il *tasso di errore* sui bit. Infatti, a questo livello noi intendiamo il *bit error rate*.

Un *impulso rettangolare* lo si ottiene con una banda infinita, che ovviamente non possiamo avere. Usiamo quindi una *banda finita* molto grande, ma questo porta alcuni problemi:
+ presenza di *rumore* e *distorsione* maggiore in tutta la banda;
+ una banda maggiore non porta per forza un data rate maggiore;
+ *costi economici* elevati;
+ *limitazioni* fisiche e regolamentari del dispositivo.

Il primo risultato che abbiamo per la capacità del canale è la *banda di Nyquist*.

#definition([Banda di Nyquist])[
  Dato un canale *noise-free*, la banda limita il data rate.

  In un *segnale binario* ($2$ segnali di voltaggio) la capacità vale $ C = 2 B bits. $

  In un *segnale multi-livello* ($M$ segnali di voltaggio) la capacità vale $ C = 2 B log_2(M) bits . $
]

=== Rumore

Se abbiamo più livelli di voltaggio il *rumore* li può alterare, addirittura cambiandoli. Abbiamo diverse tipologie di rumore:
+ *termico*, che è rumore bianco di fondo, sempre presente;
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

=== Potenza di un segnale

Per misurare il *rapporto tra due potenze* in scala logaritmica usiamo il *Decibel*, definito come $ (frac(P_1, P_2))_(decibel) = 10 log_10(frac(P_1, P_2)) . $

Quando invece fissiamo il denominatore a $1 mW$ otteniamo il *Decibel-milliWatt*, che l'unità di misura del rapporto tra una potenza arbitraria e $1 mW$.

Usiamo il decibel per descrivere il *rapporto segnale rumore*, o *SNR* (Signal to Noise Ratio). Nyquist non tiene conto del rumore, ma noi ne abbiamo e anche *parecchio*.

Vogliamo sapere quanto il nostro segnale è buono rispetto alla rumorosità del canale, e questo lo possiamo definire come $ (SNR)_decibel = 10 log_10(frac("potenza del segnale", "potenza del rumore")) . $

=== Ancora capacità del canale

Vediamo un altro risultato teorico sulla capacità del canale.

#definition([Capacità del canale secondo Shannon])[
  La capacità del canale è la massima capacità teorica di un canale, in bit al secondo, in funzione del SNR, e vale $ C = B log_2(1 + SNR) . $
]

Questo risultato è *puramente teorico* e considera solo il rumore termico, ma comunque ci dà un limite superiore al data rate che può essere trasmesso senza errori.

Possiamo aumentare il data rate in due modi:
+ *aumentiamo la banda* $B$, ma il rumore termico è *bianco*, quindi maggiore è la banda e maggiore è il rumore del sistema;
+ *aumentiamo la potenza*, aumentando quindi il SNR, ma la potenza è limitata e si ha la presenza di rumore inter-modulare e cross talk.

=== Applicazione di Nyquist e Shannon

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

Finiamo questa lezione con il *multiplexing*.

Molto spesso la capacità del mezzo di trasmissione è molto più grande della capacità della singola comunicazione: per questo vogliamo ottenere più *sotto-canali*, quindi più segnali nello stesso mezzo. Questo ci permette di avere un *maggiore data rate* e un *minore costo* dei bit per secondo.

==== TDM

Il primo multiplexing che si può avere è il *time-division multiplexing*.

#align(center)[
  #image("assets/01/tdm.png", width: 70%)
]

Questa divisione sfrutta il fatto che il data rate del mezzo di trasmissione *eccede* il data rate richiesto da un singolo segnale.

Come notiamo, un istante di tempo viene diviso in più canali, nel quale ogni segnale può essere inviato. Lasciamo quindi tutta la banda ma ogni canale ha un tempo limitato per parlare.

// Da chiedere
Sinceramente mi sembra solo una divisione più raffinata dell'unità di tempo: se prima davo il canale ad un segnale nell'unità di tempo e mi accorgevo che era troppo, ora do una frazione del tempo al segnale così da sfruttare i tempi morti. Mi sembra quindi una modulazione più raffinata dell'unità di tempo.

In questo multiplexing *non si ha interferenza*, ma è richiesta una *sincronizzazione* e si ha un *uso meno efficiente* della banda.

Per permettere la sincronizzazione si usa spesso una *finestra di delay*.

==== FDM

Il secondo multiplexing che si può avere è il *frequency-division multiplexing*.

#align(center)[
  #image("assets/01/fdm.png", width: 70%)
]

In questo caso le "fette" sono opposte: l'unità di tempo è usata per intero, ma la comunicazione avviene su *sotto-bande* diverse.

Si sfrutta infatti il fatto che la banda disponibile sul mezzo di trasmissione *eccede* la banda del singolo segnale per avere il suo data rate.

In questo multiplexing *non serve una sincronizzazione temporale* e si usa la banda in maniera *efficiente*, ma si è suscettibili ad *interferenze* tra canali vicini.

Per evitare fenomeno di interferenza si usa spesso una *banda di guardia*.

// Slide 42 01_intro_radio
