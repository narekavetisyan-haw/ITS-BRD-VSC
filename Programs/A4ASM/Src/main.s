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
IstKandidat
                DCB   0, 0                 ; Index 0 und 1 initial auf 0 setzen
                FILL  999, 1, 1            ; Indizes 2 bis 1000 (999 Bytes) initial auf 1 setzen
PrimzahlFeld
                FILL  400, 0, 2 
                ALIGN

;*******************************************************************************
;* Beginn des Programms                                                        *
;*******************************************************************************
                AREA |.text|, CODE, READONLY, ALIGN = 3
                EXPORT main
                EXTERN initITSboard

main            PROC
                bl    initITSboard                 ; HW Initialisieren

                ldr   r0, =IstKandidat         ; Basisadresse in R0 laden
                mov   r5, #0                       ; R5 fest auf 0 setzen (für Streichvorgang)

; --- Beginn des Siebens ---

; ==============================================================================
; ÄUSSERE SCHLEIFE (Prüfung bis i * i > 1000)
; ==============================================================================
for1
                mov   r1, #2                       ; i = STARTWERT (2)
until1
                mul   r4, r1, r1                   ; R4 = i * i
                cmp   r4, #MaxPrimzahl             ; Schleifenbedingung prüfen: i * i <= 1000
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
                mul   r4, r1, r1                   ; R4 = i * i
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
                ; END FOR

;-------------- Beginn des Abspeicherns --------------


for3
                ldr r6, =PrimzahlFeld               
                mov r1, #2
until3          
                cmp r1, #MaxPrimzahl
                bls do3
                b   enddo3
do3
                ldrb  r7, [r0, r1]              ; Lade den Zustand aus dem Sieb (0 oder 1) nach R7
if2
                cmp r7, #1
                beq then2
                b   endif2
then2
                strh  r1, [r6], #2              ; Speichere die Zahl i als Halbwort

endif2

step3
                add r1, r1, #1
                b until3
enddo3

endfor3

forever
                b forever


;                | Register | Initialisierung             | Verwendung im Programm                                   | Bedeutung                                             |
;| -------- | --------------------------- | -------------------------------------------------------- | ----------------------------------------------------- |
;| `R0`     | `ldr r0, =IstKandidat`      | Basisadresse des Arrays `IstKandidat`                    | Zeiger auf das Sieb-Feld                              |
;| `R1`     | `mov r1, #2`                | Laufvariable der äußeren Schleife                        | Aktuelle Zahl `i`, die geprüft wird                   |
;| `R4`     | keine feste Initialisierung | Zwischenspeicher für `i*i` bzw. aktuelles Vielfaches `j` | Berechnung und Schleifenvariable der inneren Schleife |
;| `R5`     | `mov r5, #0`                | Konstanter Wert `0` zum Streichen                        | Wert zum Markieren von Nicht-Primzahlen               |
;| `R7`     | keine feste Initialisierung | `ldrb r7, [r0, r1]`                                      | Geladener Inhalt von `IstKandidat[i]` zur Prüfung     |

END