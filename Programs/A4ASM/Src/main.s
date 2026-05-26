;*******************************************************************************
;* Einstieg in die effektive Nutzung von Kontrollstrukturen                   *
;* *
;* GTP                                                                         *
;* Aufgabe A5                                                                  *
;* *
;* Narek Avetisyan (Matrikel-Nr. 2844345)                                      *
;* Thore Zumpe (Matrikel-Nr. 2583766)                                          *
;* *
;* Berechnung der Primzahlen 2 bis 1000                                        *
;*******************************************************************************

                AREA MyData, DATA, READWRITE, ALIGN = 2
Base

; Konstante für die Anzahl der zu berechnenden Primzahlen:
MaxPrimzahl     EQU 1000

; Feld ohne Schleife von Anfang an mit 0 und 1 deklariert:
IstPrimzahlFeld
                DCB   0, 0                 ; Index 0 und 1 initial auf 0 setzen
                FILL  999, 1, 1            ; Indizes 2 bis 1000 (999 Bytes) initial auf 1 setzen

                ALIGN

;*******************************************************************************
;* Beginn des Programms                                                        *
;*******************************************************************************
                AREA |.text|, CODE, READONLY, ALIGN = 3
                EXPORT main
                EXTERN initITSboard

main            PROC
                bl    initITSboard                 ; HW Initialisieren

                ldr   r0, =IstPrimzahlFeld         ; Basisadresse in R0 laden
                mov   r5, #0                       ; R5 fest auf 0 setzen (für Streichvorgang)

; --- Beginn des Siebens ---

; ==============================================================================
; ÄUSSERE SCHLEIFE (Prüfung bis i * i > 1000)
; ==============================================================================
for1
                mov   r1, #2                       ; i = STARTWERT (2)
until1
                mul   r6, r1, r1                   ; R6 = i * i
                cmp   r6, #MaxPrimzahl             ; Schleifenbedingung prüfen: i * i <= 1000
                bls   do1                          ; DO: Wenn wahr (<=), in den Schleifenbody springen
                b     enddo1                       ; Sonst: Äußere Schleife beenden

do1
                ; Prüfe, ob die aktuelle Zahl i eine Primzahl ist (noch nicht gestrichen)
                ; Berechne Adresse: R0 + i
                ; Lade Byte aus SIEB[i] nach R7
                ldrb  r7, [r0, r1]                 
if1
                ; IF SIEB[i] == 1 THEN
                cmp   r7, #1                       
                beq   then1                        ; Wenn wahr (== 1) Springe in den THEN
                b     endif1                       ; Wenn falsch (== 0) IF-Block überspringen
then1
                ; Starte das Streichen der Vielfachen beim Quadrat der Zahl (i*i)
; ==============================================================================
; INNERE SCHLEIFE (Streichen der Vielfachen)
; ==============================================================================
for2
                mul   r4, r1, r1                   ; j = i * i
until2
                cmp   r4, #MaxPrimzahl             ; Schleifenbedingung prüfen: j <= 1000
                bls   do2                          ; DO: Wenn wahr (<=), Vielfaches streichen
                b     enddo2                       ; Sonst: Innere Schleife beenden

do2
                ; SIEB[j] = 0 (Markiere j als Nicht-Primzahl / streichen)
                strb  r5, [r0, r4]                 ; Schreibt die 0 aus R5 an die Adresse R0 + j
step2
                ; j = j + i (Gehe zum nächsten Vielfachen)
                add   r4, r4, r1
                b     until2                       ; Rücksprung zur inneren Bedingungsprüfung
enddo2

endif1
                ; END IF

step1
                ; i = i + 1 (Gehe zur nächsten Zahl: 3, 4, 5, ...)
                add   r1, r1, #1
                b     until1                       ; Rücksprung zur äußeren Bedingungsprüfung
enddo1
                ; END WHILE

                bx    lr                           ; Rücksprung ins Hauptprogramm
                ENDP
                END