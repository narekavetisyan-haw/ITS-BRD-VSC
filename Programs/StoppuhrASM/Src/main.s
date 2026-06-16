;******************** (C) COPYRIGHT HAW-Hamburg ********************************
;* File Name          : main.s
;* Author             : Franz Korf	
;* Version            : V1.0
;* Date               : 11.05.2022
;* Description        : Rahmen zur Loesung von GTP Woche 7-9 (Stoppuhr).
;
;*******************************************************************************

; Define address of selected GPIO and Timer registers
PERIPH_BASE     	equ	0x40000000                 ;Peripheral base address
AHB1PERIPH_BASE 	equ	(PERIPH_BASE + 0x00020000)
APB1PERIPH_BASE     equ PERIPH_BASE

GPIOD_BASE			equ	(AHB1PERIPH_BASE + 0x0C00)
GPIOF_BASE			equ	(AHB1PERIPH_BASE + 0x1400)
TIM2_BASE           equ (APB1PERIPH_BASE + 0x0000)
	
GPIO_F_PIN        	equ	(GPIOF_BASE + 0x10)

GPIO_D_PIN			equ	(GPIOD_BASE + 0x10)
GPIO_D_SET			equ (GPIOD_BASE + 0x18)
GPIO_D_CLR			equ	(GPIOD_BASE + 0x1A)
	
TIMER				equ (TIM2_BASE + 0x24)   ; CNT : current time stamp (32 bit),  resolution
TIM2_PSC			equ (TIM2_BASE + 0x28)   ; Prescaler  resolution
TIM2_ERG			equ (TIM2_BASE + 0x14)   ; 16 Bit register, Bit 0 : 1 Restart Timer

STATE_INIT			equ	0
STATE_RUN			equ 1
STATE_HOLD			equ 2

LED_D8      		equ 0x01
LED_D9      		equ 0x02

    EXTERN initITSboard
    EXTERN GUI_init
	EXTERN TP_Init
	EXTERN initTimer
	EXTERN lcdSetFont
	EXTERN lcdGotoXY      		; TFT goto x y function
	EXTERN lcdPrintS			; TFT output function
    EXTERN lcdPrintC            ; TFT output one character		
	EXTERN Delay				; Delay (ms) function


;********************************************
; Data section, aligned on 4-byte boundery
;********************************************
	AREA MyData, DATA, align = 2

state				DCB		STATE_INIT


DEFAULT_BRIGHTNESS	DCW     800
MY_TEXT				DCB		"Hold down different buttons from S0 to S7 and watch D8 to D15.", 0

MY_TEXT_TIMER		DCB		"00:00.00", 0

state_run_stamp		DCD		0
state_hold_stamp	DCD		0
;********************************************
; Code section, aligned on 8-byte boundery
;********************************************
	AREA |.text|, CODE, READONLY, ALIGN = 3


;--------------------------------------------
; main subroutine
;--------------------------------------------
	EXPORT main [CODE]
	
main	PROC

		; Initialisierung der HW
		BL		initITSboard
		ldr   	r1, =DEFAULT_BRIGHTNESS
		ldrh 	r0, [r1]
		bl   	GUI_init
		bl  	initTimer
		ldr 	R1,=TIM2_PSC   			; Set pre scaler such that 1 timer tick represents 10 us
		mov 	R0,#(90*10-1) 
		strh	R0,[R1]
		ldr 	R1,=TIM2_ERG   			; Restart timer	
		mov		R0,#0x01
		strh	R0,[R1]					; Set UG Bit
		MOV 	R0, #24
		bl  	lcdSetFont

		; Ihre Initialisierung

		; Simple test Code
		MOV R0,#1		; X-Achsen-Wert auf dem Display
		MOV R1,#1		; Y-Achsen-Wert 
		BL lcdGotoXY
		LDR 	R0,=MY_TEXT_TIMER
		BL  	lcdPrintS

superloop
		; read buttons	
		LDR		R0,=GPIO_F_PIN
		ldrh	R0,[R0]
		and		R0,#0xFF   ; set bit 31 to 8 of R0 to 0 ; bit 7 to 0 do not change
		; bit i for R0 is 1 <=> button S<i> not pressed (for 0 <= i <= 7)
		; bit i for R0 is 0 <=> button S<i>     pressed (for 0 <= i <= 7)
		
		LDR		r1, =state
		LDRB	r1, [r1]

		CMP		r0, #0xDF	; if (Taster == s5)
		BNE		nots5		; if (Taster != s5) dann überspringen
		
		CMP		r1, #STATE_INIT
		BEQ		nots5
		BL		INIT		; spring zum INIT
	
nots5

		CMP		r0, #0x7F	; if (Taster == s7)
		BNE		nots7
		
		CMP		r1, #STATE_RUN	
		BEQ		nots7

		CMP		R1, #STATE_INIT
		BNE		nicht_von_init
		;*********************************
		;	Zeitstempel von Run sichern
		;*********************************
		LDR		R4, =state_run_stamp
		LDR		R3, =TIMER
		LDR		R3, [R3]
		STR		R3, [R4]
nicht_von_init
		BL		RUNNING		; springe zum RUNNING

nots7

		CMP		r0, #0xBF	;if (Taster == s6)
		BNE		nots6

		CMP		r1, #STATE_RUN
		BNE		nots6

		BL		HOLD

nots6

		CMP		r1, #STATE_RUN
		BNE		not_running



		LDR 	R1,=TIMER	; Systemzeit laden
		LDR 	R0,[R1]

		; Aktuelle Zeit im RUNNING-Zeitstempel sichern
		LDR		R1, =state_run_stamp
		LDR		R1, [R1]
		SUB		R0, R1

		BL checktimer

not_running

		BAL		superloop				; End of superloop

checktimer PROC

		PUSH {R3,R4,R5,R6,R7,R8,LR}

		MOV 	R2,#1000
		UDIV 	R0,R0,R2

		MOV 	R2, #6000
		UDIV	R3, R0, R2		;R3 = Minuten
		MLS		R0, R3, R2, R0
		
		MOV		R2, #100
		UDIV	R4, R0, R2		;R4 = Sekunden
		MLS		R5, R4, R2, R0	;R5 = Hundertstel

		
		LDR 	R6,	=MY_TEXT_TIMER	; TimerString laden, um die bearbeiten

		; =========================
		; Hundertstel in String
		; =========================

		MOV 	R2,	#10
		UDIV 	R7, R5,R2
		MLS 	R8, R7,R2,R5

		;Einer Hundertstel
		ADD 	R8, R8,#'0'
		STRB 	R8, [R6,#7]

		;Zehner Hundertstel
		ADD 	R7, R7,#'0'
		STRB 	R7, [R6,#6]
		
		; =========================
		; Sekunden in String
		; =========================

		MOV     R2,#10

		UDIV    R7,R4,R2      ; Zehner Sekunden
		MLS     R8,R7,R2,R4   ; Einer Sekunden

		ADD     R8,R8,#'0'
		STRB    R8,[R6,#4]    ; Position ss Einer

		ADD     R7,R7,#'0'
		STRB    R7,[R6,#3]    ; Position ss Zehner

		; =========================
		; Minuten in String
		; =========================

		MOV     R2,#10

		UDIV    R7,R3,R2      ; Zehner Minuten
		MLS     R8,R7,R2,R3   ; Einer Minuten

		ADD     R8,R8,#'0'
		STRB    R8,[R6,#1]		;einer Minuten

		ADD     R7,R7,#'0'
		STRB    R7,[R6,#0]		;zehner Minuten

		;Anzeige aktualisieren
		BL		displaytime

		POP {R3,R4,R5,R6,R7,R8,LR}

		BX     	LR

		ENDP

displaytime PROC

		PUSH {LR}
		MOV 	R0,#1
		MOV 	R1,#1
		BL 		lcdGotoXY

		LDR R0,=MY_TEXT_TIMER
		BL lcdPrintS
		

		POP {LR}
		BX		LR
		ENDP

INIT	PROC

		PUSH {LR}

		LDR		R1, =state
		MOV R0, #STATE_INIT
		strb	R0, [R1]

		MOV 	R0, #0XFF
		; switch LEDs off (button s<i> not pressed : LED D<Ó+8> switched off (for 0 <= i <= 7))
		LDR		R1,=GPIO_D_CLR
		str		R0,[R1]


		MOV		R0, #0
		BL		checktimer

		POP {LR}

		BX LR
		ENDP

RUNNING	PROC
		PUSH {LR}

		LDR		R1, =state
		MOV R0, #STATE_RUN
		strb	R0, [R1]

			; switch LEDs off (button s<i> not pressed : LED D<Ó+8> switched off (for 0 <= i <= 7))

		MOV R0,#0xFF
		LDR R1,=GPIO_D_CLR
		STR R0,[R1]
			
			; switch LEDs on (button s<i>      pressed : LED D<Ó+8> switched on  (for 0 <= i <= 7))

		MOV 	R0,#LED_D8
		LDR 	R1,=GPIO_D_SET
		STR 	R0,[R1]

		POP {LR}
		BX LR
		ENDP

HOLD	PROC
		PUSH {LR}

		LDR		R1, =state
		MOV R0, #STATE_HOLD
		strb	R0, [R1]

		MOV R0,#0xFF
		LDR R1,=GPIO_D_CLR
		STR R0,[R1]

		MOV R0,#(LED_D8+LED_D9)
		LDR R1,=GPIO_D_SET
		STR R0,[R1]	

		POP {LR}
		BX LR
		ENDP
		


		ALIGN
		END