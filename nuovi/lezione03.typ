// Setup

#import "alias.typ": *

#import "@local/typst-theorems:1.0.0": *
#show: thmrules.with(qed-symbol: $square.filled$)


// Lezione
// Slide 90 01_intro_radio.pdf

= Lezione 03 [26/01]

== Esercizio

Vediamo un tipico esercizio d'esame su *Modulation and Coding Scheme*.

#example[
  Dobbiamo determinare il *data rate massimo* dato:
  + un SNR di $8decibel$;
  + un target BER di $10^(-2)$.

  #align(center)[
    #image("assets/03/grafico.png", width: 65%)
  ]

  Come vediamo abbiamo il SNR sull'asse $x$ e la probabilità di errore sull'asse $y$. Ci viene data anche la tabella dei coding rate.

  #align(center)[
    #image("assets/03/tabella.png", width: 50%)
  ]

  Avendo $8decibel$ prendiamo l'asse verticale centrato in $8$. Prendiamo anche il BER indicato sull'asse delle y.

  Per capire quali *costellazioni* sono *ammissibili* dobbiamo vedere quali curve andiamo ad intersecare con l'asse verticale, sotto il BER dato: in questo caso teniamo *BPSK* e *QPSK*, mentre escludiamo *$16$-QAM*.

  Per calcolare il data rate delle due costellazioni dobbiamo fare $ (syms) times (bpsym) times CR = bits . $

  Per *BPSK* abbiamo $ (1000 syms) times (1 bpsym) times 0.8 = 800 bps $ mentre per *QPSK* abbiamo $ (1000 syms) times (2 bpsym) times 0.6 = 1200 bps . $

  Il data rate massimo è quindi $1200bps$ di *QPSK*.
]

== OFDM

*OFDM*, o Orthogonal Frequency Division Multiplexing, è una *tecnica di multiplexing* molto simile a FDM ma che aggiunge la caratteristica di *ortogonalità*.

Anche qui vengono creati dei *sotto-canali*, o *sotto-portanti*, cosi da poter avere dei flussi paralleli su frequenze diverse. La *frequenza* viene divisa in frequenze multiple di una certa frequenza $f_b$. La *banda* è quindi $N f_b$, con $N$ numero di canali che vogliamo creare.

/*
Mettere su TDM vecchio

IN TDM dividiamo il tempo in pezzi $1/R$ (R data rate) e in ognuno parla un utente. Qua avevamo problema dell'ISI (multipath)
*/

In questo caso abbiamo una caratteristica di *ortogonalità*, che distanzia le varie frequenze in modo che quando abbiamo il picco di una le altre sono nulle.

/*
Mettere su multiplexing vecchio

Abbiamo sempre data rate uguale, cambia come usiamo tempo e frequenze.
*/

Vediamo come funziona OFDM con uno *schema grafico*.

#align(center)[
  #image("assets/03/divisione_OFDM.png", width: 50%)
]

Come vediamo, prendiamo un *flusso seriale* di $R bps$ e lo trasformiamo, con un *converter*, in un *flusso parallelo*, che contiene $N$ flussi da $R / N bps$ ciascuno. Questi flussi sono le nostre *sotto-portanti*, che vengono modulate con la frequenza del canale selezionato, usando sempre lo stesso schema di modulazione e codifica.

L'onda risultante è poi la combinazione di tutte queste sotto-portanti, usando la *IFFT* per passare da questo dominio delle frequenze a quello del tempo.

La potenza di OFDM, rispetto a FDM, risiede nella *bandwidth*:
+ in *FDM* dobbiamo lasciare uno *spazio di guardia* tra le varie sotto-portanti per evitare delle interferenze;
+ in *OFDM* lo spazio di guarda *non esiste* perché le sotto-portanti sono ortogonali tra loro, e quindi la banda da utilizzare è molto più piccola.

Questa soluzione è nata negli anni $'60$, ma la sua Implementazione in hardware è avvenuta molto dopo perché richiede una equalizzazione molto precisa.

OFDM e anche FDM sono molto comodi in molti protocolli perché la divisione in sotto-portanti permette di sceglierne alcune per i *pilot*, ovvero delle sotto-portanti che contengono un *segnale standard*, usato per capire la qualità del canale e quindi scegliere il MCS corretto.

La frequenza $f_b$ con la quale dividiamo lo spettro si calcola banalmente come $ f_b = 1 / T $ che è la frequenza di un *simbolo*, e tutti i segnali sono multipli di questo, quindi $M f_b$.

Vediamo come viene *implementato* OFDM.

#align(center)[
  #image("assets/03/implementazione_OFDM.png", width: 70%)
]

Come prima abbiamo una trasformazione da seriale a parallelo, l'applicazione della IFFT, poi impacchettiamo il segnale aggiungendo anche un *prefisso ciclico*, che viene utilizzato come preambolo per evitare le *interferenze*. Più le distanze di trasmissione sono lunghe e più è lungo il prefisso ciclico. Infine, avviene la modulazione e la trasmissione. Nella parte inferiore invece eseguiamo le operazioni al contrario.

OFDM è molto complesso, e infatti è *robusto* a:
+ interferenze che interessano solo alcune *sub-carrier*;
+ fenomeni di *multipath* visto che la distanza tra simboli è maggiore.

== Multiple Access

La nozione di *Multiple Access* è spesso bistrattata e confusa con il *Multiplexing*.

Il *Multiple Access* è la condivisione del canale di comunicazione tra più utenti. Il *Multiplexing* è una tecnica usata per la creazione dei canali di comunicazione.

I due concetti sono diversi ma possono essere *uniti*: creiamo i canali di comunicazione con il *Multiplexing*, e ogni canale viene diviso usando *Multiple Access*.

// aggiungi esempio di Multiple Access

== Spread spectrum

Lo *Spread Spectrum*, o spettro espanso, è una tecnica che consiste nel trasmettere il segnale su uno spettro di frequenze *più ampio* di quello del segnale di partenza.

/*
Problema: se io ho la mia banda, se la espando non rischio di andare in altre bande che non sono mie?
*/

Questo è abbastanza contro-intuitivo, perché prima cercavamo di usare meno spettro possibile, visto che è costoso e mi butta dentro un sacco di rumore.

In questo caso la soluzione è molto *robusta* e ci permette di:
+ avere *immunità* a diversi tipi di rumore e distorsioni multipath;
+ *nascondere* e *cifrare* il segnale;
+ permettere a più utenti di usare la stessa banda *contemporaneamente* (CDMA).

#align(center)[
  #image("assets/03/SS.png", width: 70%)
]

In questo schema vediamo una versione generale del Spread Spectrum: una volta che i dati sono stati codificati passiamo per un *modulatore*, che utilizza un *codice di spreading* (random o prefissato), che mappa la banda originale su una mappa più ampia. Questo codice ovviamente deve essere *condiviso*, altrimenti la de-modulazione non funziona.

=== FHSS

Una prima tecnica di Spread Spectrum è *FHSS*, o Frequency Hopping Spread Spectrum. In questo caso, il codice di spreading usato è l'*indice* di una sotto-frequenza da usare per la trasmissione. Ad ogni intervallo di tempo la frequenza viene cambiata, ecco perché si chiama *Frequency Hopping*.

#align(center)[
  #image("assets/03/FHSS.png", width: 70%)
]

Come vediamo, abbiamo sempre modulazione e codifica, ma poi abbiamo il *FH spreader*, che permette di passare allo spettro espanso. Il passaggio avviene tramite una *lookup table*, che contiene la frequenza sulla quale trasmettere in base ad un valore generato random.

Sono fondamentali due cose:
+ *sincronia temporale*, visto che passiamo da una frequenza all'altra;
+ *conoscenza* della sequenza random.

#example[
  Vediamo un esempio di FHSS.

  /* IMMAGINE APPENA QUADRI LA SISTEMA */
  #align(center)[
    #image
  ]

  In questo caso $T_C$ è il *channel time*, ovvero il tempo dopo il quale va cambiata la frequenza sulla quale trasmettere.

  Come vediamo, noi trasmettiamo due volte i bit $11$ ma in un caso siamo sulla quarta frequenza e nell'altro caso siamo sulla prima.
]

Questa tecnica ha numerosi *punti di forza*:
+ resistente al *rumore*;
+ resistente al *jamming concentrato* (su una sola frequenza, potente ma noi abbiamo più frequenze) e *generico* (su tutta la banda, meno efficace);
+ se un altro ricevitore si *sincronizza* con il trasmettitore può solo leggere alcuni pezzi dei messaggi perché *non conosce* la sequenza di Frequency Hopping. Questo vale anche perché provare a leggere tutto lo spettro è costoso e non esistono hardware che lo fanno bene.

Questa tecnica garantisce quindi *sicurezza al livello fisico*, ma può anche essere evitata se la sicurezza viene implementata ai livelli superiori.

=== DSSS

Una seconda tecnica di Spread Spectrum è il *DSSS*, o Direct Sequence Spread Spectrum. In questo caso non saltiamo più tra le frequenze, ma usiamo una soluzione alternativa.

Data una sequenza di bit $D$, ogni bit di questa viene rappresentato da un insieme di bit, che è ricavato dal *codice di spread*. Ogni bit di informazione viene infatti rappresentato da $N$ bit, ottenuti dallo *XOR* tra il bit di informazione e $N$ bit generati casualmente.

Gli $N$ bit che otteniamo sono più piccoli, durano $1/N$ dei bit di informazione, e sono chiamati *chip*. Volendo mantenere lo *stesso data rate* ci servirà $N$ volte la banda di partenza.

#example[
  Vediamo un esempio di come funziona DSSS.

  #align(center)[
    #image("assets/03/esempio_DSSS.png", width: 70%)
  ]

  In questo caso ogni dato di input (verde) diventa una sequenza di $4$ chip (blu). Il dato di input e la sequenza sono messi in XOR per calcolare cosa mandare sul canale (rosso).

  Quando riceviamo facciamo l'opposto, ovvero mettiamo in XOR il segnale e la sequenza, ottenendo il segnale originale.
]

Vediamo ora lo *schema* di *DSSS*

#align(center)[
  #image("assets/03/schema_DSSS.png", width: 70%)
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
    #image("assets/03/codifica_CDMA.png", width: 70%)
  ]

  Come vediamo, tre codici diversi codificano in diversi modi lo stesso dato.
]

Un ricevitore per distinguere tra $0$ e $1$ calcola la seguente *funzione* $ s_u (d) = sum_(i=1)^k d_i dot c_i $ dove $d$ è la sequenza ricevuta e $c$ è il codice scelto per decodificare.

Se abbiamo scelto il *codice corretto* per decodificare il segnale otteniamo:
+ $k$ se il trasmettitore ha inviato $1$;
+ $-k$ se il trasmettitore ha inviato $0$.

Se invece abbiamo scelto il *codice sbagliato* otteniamo $0$ se i codici sono *ortogonali*, oppure un valore più vicino a $0$ che a $plus.minus k$ se i codici *non* sono *ortogonali*.

// Sicuro sia somma k????
Una cosa interessante è che questo funziona anche quando i *segnali* sono *combinati*. Se più utenti parlano *contemporaneamente* noi siamo in grado di ottenere:
+ somma $plus.minus k$ se abbiamo scelto il *codice corretto*;
+ valori più vicini a $0$ che a $plus.minus k$ se abbiamo scelto il *codice sbagliato*.

Vediamo lo *schema* di come funziona CDMA.

#align(center)[
  #image("assets/03/schema_CDMA.png", width: 70%)
]

Come vediamo, ogni utente va a modulare il segnale usando il proprio *codice*, ma anche in caso di trasmissioni contemporanee il ricevitore è in grado di *decodificare* usando la conoscenza di tutti i codici.

Diamo una *valutazione* su CDMA:
+ più siamo in pochi e più possiamo usare dei codici piccoli, quindi il *data rate* è *maggiore* (potenzialmente);
+ più siamo in tanti e più i codici sono ampi, quindi il *data rate* è *minore*;
+ funziona molto bene in *ambito satellitare* perché tutti i satelliti sono alla stessa distanza.

L'ultimo punto della valutazione è anche un *punto di debolezza*: se siamo in tanti a trasmettere, tutti con la *stessa potenza* ma a *distanze diverse*, gli utenti più lontani sono più *difficili* da *interpretare*. Questo perché in caso di ricezioni simultanee è necessario avere tutti i segnali con la stessa potenza per effettuare un calcolo corretto.

Questo problema è anche detto *Near-Far problem*, che può essere risolto usando delle potenze diverse in base alla *distanza* tra TX e RX. Facile, ok, però i dispositivi che sono più lontani hanno un *dispendio energetico* maggiore, e questo sui *dispositivi mobili* pesa e non poco.

#align(center)[
  #image("assets/03/nearfar.png", width: 70%)
]

// Fine 01_intro_radio.pdf
