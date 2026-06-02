// Titolo e indice

#import "template.typ": *

#show: project.with(title: "Reti Wireless e Mobili")

#pagebreak()


// Introduzione
#include "capitoli/00_introduzione.typ"
#pagebreak()


// Teoria della trasmissione
#parte("Teoria della Trasmissione")

#include "capitoli/teoria/01_introduzione.typ"
#pagebreak()


// WPAN
#parte("WPAN")

#include "capitoli/wpan/01_BT.typ"
#pagebreak()
#include "capitoli/wpan/02_BLE.typ"
#pagebreak()
#include "capitoli/wpan/03_ZigBee.typ"
#pagebreak()


// WLAN
#parte("WLAN")

#include "capitoli/wlan/01_wifi.typ"
#pagebreak()
#include "capitoli/wlan/02_AODV.typ"
#pagebreak()


// Mobile
#parte("Rete Mobile")

#include "capitoli/mobile/01_introduzione.typ"
#pagebreak()
#include "capitoli/mobile/02_2g3g.typ"
#pagebreak()
#include "capitoli/mobile/03_4g.typ"
