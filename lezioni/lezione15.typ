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

= Lezione 15 [15/04]

== Ultima parte AODV

Un nodo che vede un link rotto deve capire:
- che percorsi invalido
- che destinazione viene raggiunta con il link interrotto
- bla
- bla bla bla

Abbiamo visto il formato, riguarda lezione prima

I messaggi di controllo cerchiamo di mandarli il meno possibile. Quando inviamo/inoltriamo il messaggio di RERR:
- viene identificato un link interrotto quando il nodo deve inoltrare pacchetti DATA lungo quel link
- se riceviamo un pacchetto DATA per una destinazione per cui non si possiede una entry
- se riceviamo un pacchetto RERR da un vicino per una o più dei percorsi arrivi (li troviamo in RERR)

Possiamo inviare broadcast o unicast ai vicini (lista di predecessori)

Quando un nodo riceve un RERR processa e poi inoltriamo eventualmente. Cosa facciamo:
- invalidiamo le entry delle destinazioni indicate in RERR
- ogni entry che viene invalidata viene preservata per un tempo DELETE_PERIOD per la local repair, che vediamo tra poco
- inoltro RERR ai predecessori (con TTL=1, come hello message, pensati per essere mandati ai vicini e basta)

*Local repair*: se un nodo riceve un pacchetto per una destinazione lungo un percorso interrotto e la destinazione non è troppo lontana (ovvero MAX_REPAIR_TTL = 0.3 NET_DIAMETER) allora il nodo prova a riparare il percorso per quella destinazione. Se altre destinazioni non sono raggiungibili tramite lo stesso link, la riparazione avviene solo se arrivano pacchetti (riparazione reattiva non proattiva, riparo solo se serve, se vengo utilizzato come bro per passare a quella roba)

Il nodo invia un RREQ con un TTL impostato in modo da non raggiungere la sorgente (dei pacchetti DATI), e lo facciamo guadando l'hop count della entry verso la sorgente

Se la procedura fallisce allora mando RRER

Se trovo alternativo aggiorno la mia entry. Se più lungo del precedente il nodo invia un messaggio RERR con flag N a $1$. La sorgente deciderò autonomamente se procedere con una nuova RREQ

Cosa succede se un nodo fa reboot (spegne e riaccende o si accende e basta)? Caso particolare, dopo un reboot posso avere info vecchie sullo stato della rete

Chi è stato riattivato rispetta tre regole:
- aspetta un tempo DELETE_PERIOD prima di fare RREQ (ascolta e basta)
- durante questo period non inoltra alcun messaggio
- se riceve dei pacchetti data per altre destinazioni solleva RRER, perché non conosce niente

Fa solo hello message, altrimenti nessuno sa che esiste, però non inoltra niente e non manda niente

Condensato in zitto e ascolta

== Rete cellulare

Cambiamo paradigma, architettura molto centralizzata

Pre-cellulare: prima degli anni '80 esisteva un servizio di telefonia mobile, con trasmettitori e ricevitori ad elevate potenza, su 25 canali (multiplex) con raggio di copertura di 80km. Quindi in 80km parlavano 25 persone al massimo lol

Capacità insufficiente per fornire un servizio voce comparabile con i servizi di telefonia fissi

Rete cellulare: utilizzo di molteplici trasmettitori con una potenza $< 100 W$ (ma anche molto meno ora, più celle mettiamo meno potenza serve)

Meno potenza, minore raggio di copertura: l'area geografica viene divisa in celle ognuna con una propria antenna (o più)

Ogni cella è servita da una base station (BS), fa da:
- trasmettitore
- ricevitore
- unità di controllo

Dittatura della BS, versione più estrema di MS in blueT

Garantire la continuità tra le celle

Può operare licensed (operatori possiedono delle BS che pagano licenze di utilizzo di alcune frequenze) o unlicensed spectrum (quello spettro senza pagare)

Obiettivi principali: gestione automatica della mobilità degli utenti e continuità

Anni:
- 1980 abbiamo 1G Advanced Mobile Phone Service (AMPS), voce analogica in mobilità
- 1990 abbiamo 2G Global System for Mobile Communications (GSM), voce digitale, prima versione globale, potevamo muoverci ovunque
- 2000 abbiamo 3G Universal Mobile Telecommunications System (UMTS), servizi internet, certa qualità di servizio
- 2010 abbiamo 4G Long Term Evolution (LTE), convergenza IP e aumento delle prestazioni
- 2020 abbiamo 5G, Network softwarization and virtualization, slicing e bassa latenza
- 2030 release commerciare si ha network intelligence con AI nella rete

Non si ha retroconnettività tra major release

[IMMAGINE BS]

Abbiamo antenna e la testa della parte radio, poi abbiamo BTS (Base Transceiver Station), con connessione FTTT (fibra ottica)

La rete cellulare è divisa in celle, dobbiamo capire come organizzarle geometricamente. Dobbiamo coprire bene l'area e avere delle aree uniformi. La più uniforme è esagonale, rispetto ad una quadrata, simile ad un cerchio rispetto al quadrato (ideale)

Altro vincolo/problema: celle vicine con stessa banda di frequenza

Se tutte le celle usano la stessa frequenza, per chi è dentro ok, per chi è sui bordi sente multiple trasmissioni

Soluzioni:
- usiamo canali diversi, ovvero uso bande di frequenze diverse tra celle vicine, quindi devo avere più bande (licensed spectrum sium \$\$\$), usata da 2G questa soluzione
- usiamo CDMA, tutti stessa frequenza ma usiamo codifiche per evitare interferenze, 3G lo usa
- 4g e 5g hanno variante della prima, usiamo bande di frequenze diverse tra celle vicine solo sui bordi, interno uso molta più banda, ottima e precisa localizzazione della cella, se sbaglio trasmetto sovrapposto
