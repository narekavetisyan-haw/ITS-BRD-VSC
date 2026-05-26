;*******************************************************************************
;* Einstieg in die effektive Nutzung von Kontrollstrukturen                    *
;*                                                                             *
;* GTP - Aufgabe A4                                                            *
;*                                                                             *
;* Narek Avetisyan (Matrikel-Nr. 2844345)                                      *
;* Thore Zumpe (Matrikel-Nr. 2583766)                                          *
;*                                                                             *
;* Programm: Sieb des Eratosthenes 							                   *
;*******************************************************************************

;-------------------------------------------------------------------------------
; DATENSEGMENT
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