;******************** (C) COPYRIGHT HAW-Hamburg ********************************
;* File Name          : main.s
;* Author             : Martin Becke    
;* Version            : V1.0
;* Date               : 01.06.2021
;* Description        : This is a simple main to demonstrate data transfer
;                     : and manipulation.
;                     : 
;
;*******************************************************************************
    EXTERN initITSboard ; Helper to organize the setup of the board

    EXPORT main         ; we need this for the linker - In this context it set the entry point,too

ConstByteA  EQU 0xaffe
    
;* We need some data to work on
    AREA DATA, DATA, align=2    
VariableA   DCW 0xbeef
VariableB   DCW 0x1234
VariableC	DCW	0x0000

;* We need minimal memory setup of InRootSection placed in Code Section 
    AREA  |.text|, CODE, READONLY, ALIGN = 3    
    ALIGN   
main
    BL initITSboard             ; needed by the board to setup
;* swap memory - Is there another, at least optimized approach?
    ldr     R0,=VariableA   ; Anw01 lädt die Adresse von VariableA in R0
	ldrb    R2,[R0]         ; Anw02 lade ein byte von VariableA
    ldrb    R3,[R0,#1]      ; Anw03	lade ein byte von VariableA mit offset 1 R0 = 0xbe
    lsl     R2, #8          ; Anw04	logical shift left um 8 bits
    orr     R2, R3          ; Anw05	Bytes getauscht R2 = 0xefbe
    strh    R2,[R0]         ; Anw06 speichert in memory 0xefbe
    
;* const in var
    mov     R5,#ConstByteA  ; Anw07	lädt den Wert von ConstByteA
    strh    R5,[R0]         ; Anw08	überschreibt in der VariableA 'ef be' in 'fe af'

;* 0xaffe in VariableC speichern
	ldr 	R4, =VariableC	; lade Adresse von VariableC in R4

	lsr 	R2, R5, #8		; logical shift right um 8 bits nach rechts und speichere in R2 = 0x00af
	strb	R2, [R4]		; speichere R2 an Adresse R4

	strb	R5, [R4, #1]	; speichere LSB von R5 an Adresse + 1


;* Change value from x1234 to x4321
    ldr     R1,=VariableB   ; Anw09 lädt die Adresse von VariableB
    ldrh    R6,[R1]         ; Anw0A

	lsl		R4, R6, #8		; LSB 0x34
	lsr 	R3, R6, #8		; MSB 0x12
	orr		R4, R4, R3		; 0x3412
	strh	R4, [R1]		; 0x1234 im Speicher an der Adresse VariableB

    ;mov     R7, #0x30ED     ; Anw0B
    ;add     R6, R6, R7      ; Anw0C
    ;strh    R6,[R1]         ; Anw0D

    b .                     ; Anw0E
    
    ALIGN
    END