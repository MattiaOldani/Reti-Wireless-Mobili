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

= Lezione 01 [25/02]

== Principi di Teoria della Trasmissione

Tipicamente è uno schema del tipo $ d(t) arrow "trasmettitore" arrow s(t) arrow "channel" arrow s(t) arrow "receiver" arrow d(t) $ con dati analogici/digitali che vengono passati al trasmettitore (ho una sequenza di bit). s è segnale, d è dato.

Questo schema però è utopico, non è mai cosi: infatti, il canale è soggetto a
- rumore
- attenuazione (certa potenza che piano piano si perde, si affievolisce)
- interferenze

Ci esce un $s'(t)$ che esce dal canale. Ci saranno casi di s' impossibile da riconoscere oppure casi di s' che partono da un s cosi robusto da poterlo sistemare.

Segnale analogico:
- ha una variazione continua e non ci sono interruzioni/discontinuità

Segnale digitale:
- mantiene un livello di segnale costante per un determinato intervallo, con un rapido (quasi istantaneo) cambio di livello

I grafici sono nel dominio del tempo, ovvero come varia la misurazione nel tempo

Il segnale analogico, se periodico, è una sinusoidale $ s(t) = A sin(2 pi f t + phi.alt) $ con 3 parametri sui quali giochiamo:
- $A$ ampiezza, massimo livello o forza del segnale nel tempo (volt)
- $f$ frequenza quanti cicli fa al secondo (Hertz)
- $phi.alt$ fase posizione relativa all'interno del periodo, dove parte

Abbiamo anche il periodo $T$ inverso della frequenza, tempo impiegato per un ciclo. Infine anche la lunghezza d'onda $lambda$ che è la distanza occupata da un singolo ciclo, ed è tale che $lambda = c/f = T c$ con $c$ velocità della luce, lunghezza spaziale.

Metti 4 esempi

Nel dominio delle frequenze, ogni segnale ragionevolmente periodico può essere scomposto in una serie di segnali periodici (onde seno e coseno) con ampiezza, frequenza e fase differenti. Idea di Fourier ad inizio 1800. Una serie di Fourier è tale che $ s(t) = 1/2 c + sum_(n=1)^infinity a_n sin(2 pi n f t) + sum_(n=1)^infinity b_n cos(2 pi n f t) $ dove $f = 1/T$ è la frequenza fondamentale ($n = 1$), $a_n$ e $b_n$ sono le ampiezze delle singole componenti dette armoniche e $c$ è una costante che è il valore medio del segnale. Partendo dalla f fondamentale, ogni armonica avrà un multiplo di questa frequenza fondamentale.

Dato un grafico, come facciamo a determinare le ampiezze di ciascuna componente? Con quale frequenza dobbiamo campionare il nostro segnale?

#theorem([Teorema del campionamento di Shannon])[
  La frequenza di campionamento deve essere almeno il doppio della frequenza massima del segnale in ingresso.
]

Per passare dal dominio del tempo al dominio delle frequenze usiamo la FFT (Fast Fourier Transform), ovvero passiamo il campionamento fatto alla FFT e mi genera le frequenze. La Inverse FFT passa dalle frequenze al tempo.

Quando tutte le frequenze sono multipli interi di una frequenza base $f$ (frequenza fondamentale, le altre sono kf armoniche), il periodo del segnale $s(t)$ è il periodo della frequenza fondamentale. Lo *spettro* (spectrum) del segnale è il range di frequenze che lo contiene. La absolute bandwidth è l'ampiezza dello spettro (max - min)

ESEMPIO

Trasmettiamo due bit per ogni due bit, quindi il data rate è di 2f bits. Maggior parte energia concentrata nelle prime frequenze (kf --> ampiezza 1/k), effective bandwidth

La capacità del canale è il massimo bit rate alla quale è possibile trasmettere dati su un canale di comunicazione in determinate condizioni. Il noise è un segnale NON VOLUTO che si combina al segnale trasmesso che lo altera o distorce. L'error rate, o tasso di errore, a questo livello si intende bit error rate.

Esempio che non capisco

Considerazioni: impulso rettangolare ha banda infinita, noi vogliamo usare una banda finita. Banda minore ha maggiore distorsione

Scelgo la banda finita più ampia? Ho costi economici e limitazioni del dispositivo

Nyquist bandwidth

Dato un canale noise-free (ideale) la bandwidth limita il data rate

Ovvero, la Nyquist capacity ha un binary signals (2 livelli di voltaggio) quindi C=2B o ha un multilevel signaling C=2B log_2(M) (con M numero di segnali discreti o livelli di voltaggio)

Il rumore è un segnale non voluto che si combina al segnale trasmesso che lo altera e distorce. Può essere:
- thermal noise
- intermodulation noise
- cross talk
- impulse noise
