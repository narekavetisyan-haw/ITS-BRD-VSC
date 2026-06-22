# GTP Praktikum - Woche 7 - 9: Algorithmen und Unterprogramme

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

## Umsetzung der Stoppuhr (Woche 8–9)

### Zustandsmaschine (FSM)

Für die Stoppuhr wurde eine endliche Zustandsmaschine mit drei Zuständen implementiert:

* **INIT**
* **RUNNING**
* **HOLD**

Die Zustandsvariable wird im Speicher abgelegt und in jedem Durchlauf der Endlosschleife ausgewertet.

#### Zustandsübergänge

| Aktueller Zustand | Taste | Neuer Zustand |
| ----------------- | ----- | ------------- |
| INIT              | S7    | RUNNING       |
| RUNNING           | S6    | HOLD          |
| HOLD              | S7    | RUNNING       |
| RUNNING           | S5    | INIT          |
| HOLD              | S5    | INIT          |

Die Zustandsprüfung erfolgt im Unterprogramm `check_state`, welches abhängig vom aktuellen Zustand die entsprechenden Routinen aufruft.

### Zeitmessung

Die Zeitmessung erfolgt mit dem Hardware-Timer TIM2.

Der Prescaler wird so eingestellt, dass ein Timer-Tick einer Auflösung von 10 µs entspricht.

Beim Übergang von **INIT** nach **RUNNING** wird der aktuelle Timerstand als Startzeitpunkt gespeichert:

```asm
state_run_stamp
```

Während des Zustands **RUNNING** wird die verstrichene Zeit berechnet:

```text
aktuelle Zeit = TIMER - state_run_stamp
```

Anschließend erfolgt die Umrechnung in:

* Minuten
* Sekunden
* Hundertstelsekunden

Das Ausgabeformat lautet:

```text
mm:ss.nn
```

Beispiel:

```text
01:23.45
```

### Anzeige auf dem TFT-Display

Die aktuelle Zeit wird in dem String

```
MY_TEXT_TIMER
```

gespeichert.

Zusätzlich existiert ein zweiter String

```
MY_TEXT_TIMER_DISP
```

der den zuletzt auf dem Display dargestellten Zustand enthält.

Vor jeder Ausgabe werden beide Strings Zeichen für Zeichen verglichen.

Nur wenn sich ein Zeichen geändert hat, wird dieses neu ausgegeben.

Dadurch werden:

* unnötige Displayzugriffe vermieden
* die Prozessorlast reduziert
* sichtbares Flackern des TFT-Displays verhindert

Zusätzlich wird pro Aufruf von `displaytime` höchstens ein Zeichen aktualisiert. Dadurch erfolgt die Anzeige besonders flüssig und entspricht den Anforderungen des Praktikums.

### LED-Anzeige

Die LEDs dienen zur Visualisierung des aktuellen Zustands:

| Zustand | LEDs          |
| ------- | ------------- |
| INIT    | alle LEDs aus |
| RUNNING | D8 an         |
| HOLD    | D8 und D9 an  |

Die LEDs werden über die Register `GPIO_D_SET` und `GPIO_D_CLR` gesteuert.

### Verwendete Unterprogramme

| Unterprogramm | Aufgabe                                                  |
| ------------- | -------------------------------------------------------- |
| `check_state` | Auswertung des aktuellen Zustands                        |
| `INIT`        | Verarbeitung der Eingaben im Zustand INIT                |
| `RUNNING`     | Verarbeitung der Eingaben und Zeitmessung                |
| `HOLD`        | Verarbeitung der Eingaben im Zustand HOLD                |
| `entry_init`  | Eintrittsaktion für INIT                                 |
| `entry_run`   | Eintrittsaktion für RUNNING                              |
| `entry_hold`  | Eintrittsaktion für HOLD                                 |
| `check_timer` | Umrechnung der Zeit in Minuten, Sekunden und Hundertstel |
| `displaytime` | Flackerfreie Aktualisierung der TFT-Anzeige              |

### Ergebnis

Die Stoppuhr erfüllt alle geforderten Funktionen:

* Starten mit S7
* Anhalten mit S6
* Fortsetzen mit S7
* Zurücksetzen mit S5
* Anzeige im Format `mm:ss.nn`
* Zustandsanzeige über LEDs
* Flackerfreie Aktualisierung des TFT-Displays
* Realisierung als endliche Zustandsmaschine (FSM)
