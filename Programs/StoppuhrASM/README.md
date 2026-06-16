# GTP Praktikum - Woche 7: Algorithmen und Unterprogramme

## Teammitglieder
* **Narek Avetisyan** (Matrikel-Nr. 2844345)
* **Thore Zumpe** (Matrikel-Nr. 2583766)

## Aufgabenstellung
Ziel der Aufgabe von Woche 7 ist die Analyse der Aufgabe und Erstellung einer Grobstruktur von Funktionen für eine Stoppuhr.

Zentrale Kontrollstruktur

In der Endlosschleife (superloop) wird immer:

1. Zustand prüfen
2. Taster afragen (abhängig vom Zustand)
3. LEDs aktualisieren (abhängig vom Zustand)
4. Zeit lesen + berechnen (abhängig vom Zustand)
5. Display aktualisieren (abhängig vom Zustand)
6. Wiederholen

Zustände
Reaktion auf S5, S6, S7

Gefordert:

Taste	Zustand	Aktion
S7	INIT	→ RUNNING
S6	RUNNING	→ HOLD
S7	HOLD	→ RUNNING
S5	RUNNING/HOLD	→ INIT

Zeitformat:
"mm:ss.nn" - Minute:Sekunden.Hundertstelsekunden



Wichtig
Bit = 1 → Taster NICHT gedrückt
Bit = 0 → Taster gedrückt

LEDs ausschalten
LDR R1,=GPIO_D_CLR
STR R0,[R1]
Für alle Bits mit Wert 1 werden die entsprechenden LEDs ausgeschaltet.

LEDs einschalten
EOR R1,R1,#0xFF
Sollte eigentlich die Bits invertieren (0 → 1, 1 → 0).
In diesem Beispiel bringt die Zeile aber nichts, weil direkt danach R1 überschrieben wird.

LDR R1,=GPIO_D_SET
STR R0,[R1]
Schaltet LEDs entsprechend den Tasterzuständen ein.

Für die Unterprogramme

welcher Taster ist gedrückt?


## Ziel der Aufgabe

Im Rahmen des Praktikums soll eine Stoppuhr für das ITS-Board entwickelt werden. In Woche 7 werden die grundlegenden Hardwarekomponenten getestet und angesteuert.

Bearbeitete Komponenten
LEDs

Die LEDs D8 bis D15 werden über die Register GPIO_D_SET und GPIO_D_CLR angesteuert.

Taster

Die Taster S0 bis S7 werden über das Register GPIO_F_PIN eingelesen.

TFT-Display

Das Display wird mit den Funktionen

lcdGotoXY
lcdPrintS
lcdPrintC

angesteuert.

Durchgeführte Tests
Ausgabe eines Textes auf dem TFT-Display
Positionierung von Text mit lcdGotoXY
Zeichenweise Ausgabe mit lcdPrintC
Einlesen der Taster S0 bis S7
Schalten der LEDs D8 bis D15 entsprechend der Tasterzustände
Vorbereitung für Woche 8

In der nächsten Woche wird die Zustandsmaschine (FSM) der Stoppuhr implementiert. Die Zustände INIT, RUNNING und HOLD werden entwickelt und getestet. Außerdem wird die Zeitmessung über den Hardware-Timer umgesetzt.