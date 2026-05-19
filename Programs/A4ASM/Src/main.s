;*******************************************************************************
;* Einstieg in die effektive Nutzung von Kontrollstrukturen                    *
;*                                                                             *
;* GTP - Aufgabe A4                                                            *
;*                                                                             *
;* Narek Avetisyan (Matrikel-Nr. 2844345)                                      *
;* Thore Zumpe (Matrikel-Nr. 2583766)                                          *
;*                                                                             *
;* Programm: Sieb des Eratosthenes (Feld startet bei Index 0)                  *
;*******************************************************************************

;-------------------------------------------------------------------------------
; DATENSEGMENT (Speicherbereich definieren)
;-------------------------------------------------------------------------------
                AREA MyData, DATA, align = 2

; Konstanten definieren
STARTWERT       EQU 2
ENDWERT         EQU 1000

; Speicherbereich für das 'Sieb' (Array)
; Da wir bei 0 starten und bis 1000 gehen, brauchen wir exakt 1001 Bytes.
; Der Index im Feld entspricht direkt der Zahl selbst (Index i = Zahl i).
SIEB            SPACE 1001
                ALIGN

; Speicherstelle für das Endergebnis Anzahl_Primzahlen (1 Word = 32-Bit)
Anzahl_Primzahlen SPACE 4
                ALIGN


;-------------------------------------------------------------------------------
; CODESEGMENT (Hauptprogramm und Teilfunktionen)
;-------------------------------------------------------------------------------
                AREA |.text|, CODE, READONLY, ALIGN = 3
                EXPORT main
                EXTERN initITSboard

;===============================================================================
; HAUPTPROGRAMM (MAIN)
;===============================================================================
main            PROC
                BL    initITSboard                 ; HW Initialisieren

                ; --- AUFRUF TEILFUNKTION SIEB ---
                ; Führe den Sieb-Algorithmus aus, um alle Nicht-Primzahlen zu streichen
                BL    sieb_funktion

                ; --- AUFRUF TEILFUNKTION ZAEHLEN ---
                ; Zähle die Primzahlen im gesiebten Feld zusammen und speichere das Ergebnis
                BL    zaehlen_funktion

; Programmende
forever         B     forever
                ENDP


;===============================================================================
; TEILFUNKTION: SIEB
;===============================================================================
sieb_funktion   PROC
                ; --- Initialisierung des Feldes ---
                ; Registerbelegung:
                ; R0 = Basisadresse von SIEB
                ; R1 = Schleifenzähler i
                ; R2 = Wert 1 (Markierung "Ist Primzahl")
                ; R3 = Wert 0 (Markierung "Keine Primzahl")

                ; FOR i FROM 0 TO ENDWERT DO
                ;     SIEB[i] = 1 (Zunächst alle Einträge von 0 bis 1000 auf 1 setzen)
                ; END FOR

                ; --- Spezialfälle ausschließen (0 und 1 sind keine Primzahlen) ---
                ; SIEB[0] = 0;
                ; SIEB[1] = 0;


                ; --- Beginn des Siebens ---
                ; Registerbelegung:
                ; R1 = i (startet bei STARTWERT = 2)
                ; R4 = j (Vielfaches für die innere Schleife)
                ; R5 = Wert 0 (Markierung "Nicht-Primzahl")
                ; R6 = Hilfsregister für i * i

                ; i = STARTWERT (2)
                ; WHILE (i * i <= ENDWERT) DO (Streichen beginnt nur, solange i^2 <= 1000)

                    ; Prüfe, ob die aktuelle Zahl i eine Primzahl ist (noch nicht gestrichen)
                    ; Berechne Adresse: R0 + i (Kein Versatz nötig!)
                    ; Lade Byte aus SIEB[i]

                    ; IF SIEB[i] == 1 THEN (Wenn i noch als Primzahl markiert ist)

                        ; Starte das Streichen der Vielfachen beim Quadrat der Zahl (i*i)
                        ; j = i * i

                        ; --- Schleife zum Streichen der Vielfachen von i ---
                        ; WHILE (j <= ENDWERT) DO
                        
                            ; SIEB[j] = 0 (Markiere j als Nicht-Primzahl / streichen)
                            ; j = j + i (Gehe zum nächsten Vielfachen)
                            
                        ; END WHILE

                    ; END IF

                    ; i = i + 1 (Gehe zur nächsten Zahl: 3, 4, 5, ...)

                ; END WHILE

                BX    LR                           ; Rücksprung ins Hauptprogramm
                ENDP


;===============================================================================
; TEILFUNKTION: ZAEHLEN
;===============================================================================
zaehlen_funktion PROC
                ; Registerbelegung:
                ; R0 = Basisadresse von SIEB
                ; R1 = Schleifenzähler i (STARTWERT bis ENDWERT)
                ; R2 = Anzahl_Primzahlen (Zähler, startet bei 0)
                ; R7 = Geladener Wert aus dem Feld (0 oder 1)
                ; R8 = Basisadresse der Ergebnis-Speicherstelle (Anzahl_Primzahlen)

                ; Anzahl_Primzahlen = 0

                ; Durchlaufe das gesiebte Feld vom Startwert (2) bis zum Endwert (1000)
                ; (Wir starten bei 2, da 0 und 1 per Definition eh keine Primzahlen sind)
                ; FOR i FROM STARTWERT TO ENDWERT DO

                    ; Prüfe den Eintrag im Feld, ob es eine Primzahl ist
                    ; Berechne Adresse: R0 + i
                    ; Lade Byte aus SIEB[i] in R7

                    ; IF SIEB[i] == 1 THEN (Wenn der Eintrag auf "Ist Primzahl" steht)
                    ;     Anzahl_Primzahlen = Anzahl_Primzahlen + 1 (Zähler hochzählen)
                    ; END IF

                ; END FOR

                ; Speichere das Endergebnis (Anzahl_Primzahlen) an der dafür vorgesehenen Speicherstelle
                ; Schreibe den Wert aus R2 in die Speicherstelle 'Anzahl_Primzahlen'

                BX    LR                           ; Rücksprung ins Hauptprogramm
                ENDP

                END