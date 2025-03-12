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

= Lezione 06 [12/03]

Frequenze pari master parla, frequenze dispari slave parla. Non sono mai slot separati: parla master, subito dopo parla slave.

Gli slot per parlare consecutivi sono 1,3 o 5. Sempre dispari per la divisione in time division duplex. Se fossero pari andremmo a parlare anche negli slave. Da 7 in poi sono troppi. Questo vale sia per master che per slave. Il FH va in base agli slot: nell'esempio passiamo da $f_2$ a $f_5$ perché ho uno slot da $3$, ho fatto $3$ salti, non vado in $f_3$. Inoltre, nella stessa finestra di trasmissione ($n$ dispari slot) uso sempre la stessa frequenza.

Tutti gli slave connessi alla piconet hanno questo clock ben sincronizzato con il master. Quindi scelgo FH uguale in tutta la rete, TDD per fare le parlate MS e SM e infine TDMA per far scegliere al master con chi parlare

La scatternet deve aggiungere altro

Ogni master ha la propria FH e si ha un disallineamento dei tempi, quindi ogni piconet è sfasata e non abbiamo vincoli che le leghino

FH decisa sempre dal master e condivisa nella piconet, ognuna con una sequenza diversa. Avendo 79 canali può capitare una sovrapposizione. Come si sistema:
- FH su un numero ridotti di canali (scegliamo robe diverse), riduce ma non risolve
- si usa CDMA per risolvere, ovvero evita interferenze tra piconet. Ogni master dà un codice ortogonale per tutti gli elementi della piconet (CDSMA scatter). Il MA sono le piconet

Non abbiamo veramente risolto, ma cosi riduciamo di molto perché i codici ortogonali sono molto pochi

Cosa offre la baseband come servizi (2 canali):
- synchronous connection-oriented link (SCO) point-to-point
  - canale audio/voce di 64 kbps bidirezionali
  - il master riserva una coppia di slot adiacenti ad intervalli regolari (MS e SM per arrivare a 64kbps)
  - previsti al massimo 3 canali SCO attivi contemporaneamente
  - traffico real time come la voce (delay non c'è)
- asynchronous connectionless link (ACL) point-to-multipoint
  - canali ACL occupano gli slot rimanenti, ciò che non è SCO
  - traffico dati con ciascuno degli slave (varie dimensioni)
  - un solo ACL contemporaneo tra master e uno slave
  - traffico best effort (non garanzie di delay)

Due canali logici offerti

Come sono formati i frame (pacchetti) a livello baseband?

Abbiamo:
- 68 (o 72) bit di access code, usato per ... che possono essere:
  - channel access code (CAC) identifica la piconet (48 bit dell'indirizzo HW del master)
  - device address code (DAC) derivato dall'HW dello slave ed è usato dal master per chiamare (paging) il dispositivo
  - inquiry address code (IAC) usato per trovare l'indirizzo di un dispositivo vicino (durante la fase di inquiry)
- 54 bit di packet header
  - 3 bit di AMA
  - 4 bit di tipo (tipo del pacchetto, formato di ACL)
  - 1 bit flow (controllo di flusso), vale $1$ se stop, altrimenti $0$ resume (usiamo per gli ACL, gli SCO sono cadenzati)
  - 1 bit di ARQN (automatic RQ number)
  - 1 bit di SEQN (sequence number modulo 2)
  - Ultimi due usati per il controllo degli errori
- 0-2744 bit di payload
  - SCO 30 byte (230 bit) perché abbiamo 30\*8\*1600/6 ovvero 64 kbps
  - ACL da 0 a 343 byte

Link Manager Protocol (LMP) è una macchina a stati
- si parte dalla standby mode, il dispositivo è accesso ma non è in nessuna piconet, quindi minimo consumo
- entro in ...

In standby non sono a conoscenza di niente. Come faccio a collegare? Non ho nessun coordinamento, ma c'è un concetto di "presentazione di qualcuno", ma non è lo slave che si annuncia al master (quello dal 4.0 in poi), qua è il master che si presenta allo slave. Il master fa discovery e manda pacchetti con IAC su 32 frequenze standard dove li mandiamo uno dopo l'altro. Gli slave sanno che devono ascoltare qua

I tempi di collegamento sono diversi: avendo un TDMA dobbiamo avere culo a prendere quando il master sta per mandare su quelle frequenze.

Quindi:
- mando su 32 canali wake-up un IAC packet (32 consecutivi) e i bro slave ascoltano per vedere se qualcuno ha mandato un IAC, tutto non coordinato però. Visto che spreco ad ascoltare, ascolto per 11.25 ms e aspetto. Tra una scansione e l'altra passano 1.28/2.56s
- quando si beccano dobbiamo dire chi siamo (48bit del MAC e la classe) con un random backoff per evitare le collisioni

Master passa da standard a inquiry, mentre slave da standby a inquiry-scan. Ci siamo allineati con il metronomo del master, manca solo una cosa: la FH. Non la sappiamo per ora, la dobbiamo sapere.

Uso 16 frequenze standard dei 32 di prima per mandare un DAC (access code) con il FH da usare e il suo active member address. Ora sappiamo come sincronizzarci, mando un DAC con un ACK

Passiamo poi negli stati PAGE e infine CONNECTED
