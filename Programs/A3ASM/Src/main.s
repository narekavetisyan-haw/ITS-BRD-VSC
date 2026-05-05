;************************************************
;* Vor- und Nachname: Narek Avetisyan   *
;* Matrikelnummer: 2844345              *
;************************************************

;************************************************
;* Beginn der globalen Daten *
;************************************************
                   AREA MyData, DATA, align = 2
Base
VariableA          DCW 0x1234
VariableB          DCW 0x4711

VariableC          DCD  0

MeinHalbwortFeld   DCW 0x22 , 0x3e , -52, 78 , 0x27 , 0x45

MeinWortFeld       DCD 0x12345678 , 0x9dca5986
                   DCD -872415232 , 1308622848
                   DCD 0x27000000
                   DCD 0x45000000

MeinTextFeld       DCB "ABab0123",0

                   EXPORT VariableA 
                   EXPORT VariableB
                   EXPORT VariableC
                   EXPORT MeinHalbwortFeld
                   EXPORT MeinWortFeld
                   EXPORT MeinTextFeld

;***********************************************
;* Beginn des Programms *
;************************************************
    AREA |.text|, CODE, READONLY, ALIGN = 3
; ----- S t a r t des Hauptprogramms -----
                EXPORT main
                EXTERN initITSboard
main            PROC
                bl    initITSboard                 ; HW Initialisieren

; Laden von Konstanten in Register
                mov   r0,#0x12                      ; Anw-01
                mov   r1,#-128                      ; Anw-02
                ldr   r2,=0x12345678                ; Anw-03

; Zugriff auf Variable
                ldr   r0,=VariableA                 ; Anw-04
; VariableA 16 Bit in r1 laden 
                ldrh  r1,[r0]                       ; Anw-05
; VariableA und nachfolgende 16Bit in r2 laden
                ldr   r2,[r0]                       ; Anw-06
; Inhalt von r2 speichern an der Adresse von VariableC
                str   r2,[r0,#VariableC-VariableA]  ; Anw-07

; Zugriff auf Felder (Speicherzellen)
                ldr   r0,=MeinHalbwortFeld          ; Anw-08
; Erstes Element von MeinHalbwortFeld in r1 laden
                ldrh  r1,[r0]                       ; Anw-09
; Zweites Element von MeinHalbwortFeld in r2 laden
                ldrh  r2,[r0,#2]                    ; Anw-10
; Eine Konstante in r3 laden
                mov   r3,#10                        ; Anw-11
; Letztes Element von MeinHalbwortFeld in r4 laden
                ldrh  r4,[r0,r3]                    ; Anw-12
; Zweites Element (0x3e) von MeinHalbwortFeld in r5 und Adresse wird überschrieben um 2
                ldrh  r5,[r0,#2]!                   ; Anw-13
; Drittes Element (-52) von MeinHalbwortFeld in r6 und Adresse wird überschrieben um 2
                ldrh  r6,[r0,#2]!                   ; Anw-14
; 78 mit -52 wird ersetzt
                strh  r6,[r0,#2]!                   ; Anw-15

; Addition und Subtraktion von unsigned / signed Integer-Werten
    ;   Adresse von MeinWortFeld in r0 laden
                ldr  r0,=MeinWortFeld               ; Anw-16
    ;   Erstes Element von MeinWortFeld in r1 laden
                ldr  r1,[r0]                        ; Anw-17
    ;   Zweites Element von MeinWortFeld in r2 laden
                ldr  r2,[r0,#4]                     ; Anw-18
    ;   Inhalte von r1 und r2 vorzeichenbehaftet addieren und in r3 laden
                adds r3,r1,r2                       ; Anw-19

    ;   -872415232 in r4 laden
                ldr  r4,[r0,#8]                     ; Anw-20
    ;   1308622848 in r5 laden
                ldr  r5,[r0,#12]                    ; Anw-21
    ;   r5 von r4 vorzeichenbehaftet subtrahieren und in r6 laden
                subs r6,r4,r5                       ; Anw-22

    ;   0x27000000 in r7 laden
                ldr  r7,[r0,#16]                    ; Anw-23
    ;   0x45000000 in r8 laden
                ldr  r8,[r0,#20]                    ; Anw-24
    ;   Inhalt von r8 von r7 signed subtrahieren und in r9 laden
                subs r9,r7,r8                       ; Anw-25

forever         b   forever                         ; Anw-26
                ENDP
                END