;*******************************************************************************
; Universidad del Valle de Guatemala
; IE2023 Programación de Microcontroladores
; Autor: Byron Barrientos  
; Compilador: PIC-AS (v2.36), MPLAB X IDE (v6.00)
; Proyecto: Hoja de Trabajo 2
; Hardware: PIC16F887, dos botones y dos leds
; Creado: 12/08/2022
; Última Modificación: 16/08/2022 
;******************************************************************************* 
PROCESSOR 16F887
#include <xc.inc>
;******************************************************************************* 
; Palabra de configuración    
;******************************************************************************* 
; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO 
                                ;oscillator: I/O function on RA6/OSC2/CLKOUT
				;pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF             ; Watchdog Timer Enable bit (WDT enabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR 
                                ;pin function is digital input, MCLR internally
				;tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code
                                ;protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code
                                ;protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit 
                                ;(Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit 
                                ;(Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin
                                ;has digital I/O, HV on MCLR must be used for 
				;programming)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out 
                                ;Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits 
                                ;(Write protection off)
;******************************************************************************* 
; Variables    
;******************************************************************************* 
PSECT udata_bank0
CONTADOR:
    DS 1
CONTADOR_20MS:
    DS 1
ESTADO:
    DS 1
W_TEMP:
    DS 1
STATUS_TEMP:
    DS 1
;******************************************************************************* 
; Vector Reset    
;******************************************************************************* 
PSECT CODE, delta=2, abs
 ORG 0x0000
    goto MAIN
;******************************************************************************* 
; Vector ISR Interrupciones    
;******************************************************************************* 
PSECT CODE, delta=2, abs
 ORG 0x0004
ISR: 
    BANKSEL INTCON
    BCF INTCON, 0       ; Baja la bandera que indica una interrupción en
                        ; el PORTB
    BTFSS INTCON, 2	; Revisa el bit 2 de INTCON, si vale 1 se salta el GOTO
    GOTO  ISR_RBIF 
    BCF INTCON, 2	; Baja la bandera que indica una interrupción en 
                        ; el TMR0
    INCF CONTADOR_20MS	; Se incrementa el valor de CONTADOR_20MS
    MOVLW 178           ; Cargamos 178 a W
    MOVWF TMR0		; Se carga W a TMR0 (se carga al valor de N en  el TMR0)
    GOTO POP

ISR_RBIF:
    BTFSS PORTB, 0      ; Revisa el bit 0 de PORTB, si vale 1 se salta el GOTO
                        ; (revisa si el boton de cambio está presionado)  
    GOTO ESTADO0_ISR

ESTADO0_ISR:
    MOVF CONTADOR, W    ; Copia el valor de CONTADOR a W
    SUBLW 0             ; Se hace la resta 0 - W
    BTFSS STATUS, 2     ; Revisa el bit 2 de STATUS, si vale 1 se salta el GOTO
                        ; (si la resta fue igual a 0, se salta el GOTO) 
    GOTO ESTADO1_ISR
    BTFSS PORTB, 1      ; Revisa el bit 1 de PORTB, si vale 1 se salta el GOTO
                        ; (revisa si el boton de acción está presionado)
    INCF PORTC, F       ; Se incrementa el valor de PORTC
    BTFSS PORTB, 0      ; Revisa el bit 0 de PORTB, si vale 1 se salta el GOTO
                        ; (revisa si el boton de cambio está presionado)
    BCF ESTADO, 0       ; Se hace 0 el bit 0 de ESTADO
    BCF INTCON, 0	; Baja la bandera que indica una interrupción en
                        ; el PORTB
    GOTO POP
    
ESTADO1_ISR:
    MOVF CONTADOR, W    ; Copia el valor de CONTADOR a W
    SUBLW 1             ; Se hace la resta 1 - W
    BTFSS STATUS, 2     ; Revisa el bit 2 de STATUS, si vale 1 se salta el GOTO
                        ; (si la resta fue igual a 0, se salta el GOTO) 
    GOTO CLEAR
    BTFSS PORTB, 1      ; Revisa el bit 1 de PORTB, si vale 1 se salta el GOTO
                        ; (revisa si el boton de acción está presionado)
    DECF PORTC, F       ; Se decrementa el valor de PORTC
    BTFSS PORTB, 0      ; Revisa el bit 0 de PORTB, si vale 1 se salta el GOTO
                        ; (revisa si el boton de cambio está presionado)
    BCF ESTADO, 0       ; Se hace 0 el bit 0 de ESTADO
    BCF INTCON, 0	; Baja la bandera que indica una interrupción en
                        ; el PORTB
    GOTO POP

CLEAR:
    MOVF CONTADOR, W    ; Copia el valor de CONTADOR a W
    SUBLW 4             ; Se hace la resta 4 - W
    BTFSS STATUS, 2     ; Revisa el bit 2 de STATUS, si vale 1 se salta el GOTO
                        ; (si la resta fue igual a 0, se salta el GOTO)
    GOTO POP
    CLRF CONTADOR       ; Limpia CONTADOR
    GOTO POP

 POP:
    SWAPF STATUS_TEMP, W
    MOVWF STATUS
    SWAPF W_TEMP, F
    SWAPF W_TEMP, W
    RETFIE
    
;******************************************************************************* 
; Código Principal    
;******************************************************************************* 
PSECT CODE, delta=2, abs
 ORG 0x0100

MAIN:
    
    BANKSEL OSCCON
    
    BSF OSCCON, 6	; IRCF2 Selección de 2MHz
    BCF OSCCON, 5	; IRCF1
    BSF OSCCON, 4	; IRCF0
    
    BSF OSCCON, 0	; SCS Reloj Interno
    
    BANKSEL TRISC
    
    CLRF TRISC		; Limpiar el registro TRISC (Output)
    BCF TRISA, 6
    BCF TRISA, 7	; Outputs para LEDs que indican el modo
    
    BSF TRISB, 0
    BSF TRISB, 1	; Entradas para los botones
    
    BANKSEL IOCB
    
    BSF IOCB, 0
    BSF IOCB, 1		; Habilitando RB0 y RB1 para las ISR de RBIE
    
    BANKSEL WPUB
    
    BSF WPUB, 0
    BSF WPUB, 1		; Habilitando los pull-ups en RB0 y RB1
    
    BANKSEL ANSEL
    
    CLRF ANSEL          
    CLRF ANSELH         ; I/O Digitales
    
    BANKSEL PORTC
    CLRF PORTA		; Se limpia PORTA
    CLRF PORTC          ; Se limpia PORTC
    CLRF CONTADOR       ; Se limpia CONTADOR
    CLRF CONTADOR_20MS  ; Se limpia CONTADOR_20MS
    CLRF ESTADO         ; Se limpia ESTADO
    
    ; Configuración TMR0
    
    BANKSEL OPTION_REG
    BCF OPTION_REG, 7	; Habilitando que el PORTB tenga pull-ups
    BCF OPTION_REG, 5	; T0CS: FOSC/4 como reloj (modo temporizador)
    BCF OPTION_REG, 3	; PSA: Se asigna el Prescaler al TMR0
    
    BSF OPTION_REG, 2
    BSF OPTION_REG, 1
    BCF OPTION_REG, 0	; PS2-0: Prescaler 1:128 
    
    MOVLW 178           ; Cargamos 178 a W
    MOVWF TMR0		; Se carga W a TMR0 (se carga al valor de N en  el TMR0)

;******************************************************************************* 
; Loop   
;*******************************************************************************     
    
LOOP:
    
    PB_INC:
	MOVF CONTADOR, W	; Copia el valor de CONTADOR a W
	SUBLW 0			; Se hace la resta 0 - W
	BTFSS STATUS, 2		; Revisa el bit 2 de STATUS, si vale 1 se salta 
				; el GOTO
				; (si la resta fue igual a 0, se salta el GOTO) 
	GOTO PB_DEC
	BSF PORTA, 6
	BCF PORTA, 7
	GOTO LOOP

    PB_DEC:
	MOVF CONTADOR, W	; Copia el valor de CONTADOR a W
	SUBLW 1			; Se hace la resta 1 - W
	BTFSS STATUS, 2		; Revisa el bit 2 de STATUS, si vale 1 se salta 
				; el GOTO
				; (si la resta fue igual a 0, se salta el GOTO) 
	GOTO UNSEG_INC
	BCF PORTA, 6
	BSF PORTA, 7
	GOTO LOOP

    UNSEG_INC:
	MOVF CONTADOR, W	; Copia el valor de CONTADOR a W
	SUBLW 2			; Se hace la resta 2 - W
	BTFSS STATUS, 2		; Revisa el bit 2 de STATUS, si vale 1 se salta 
				; el GOTO
				; (si la resta fue igual a 0, se salta el GOTO) 
	GOTO UNSEG_DEC
	MOVF CONTADOR_20MS, W   ; Copia el valor de CONTADOR_20MS a W
	SUBLW 50                ; Se hace la resta 50 - W
	BTFSS STATUS, 2	        ; Revisa el bit 2 de STATUS, si vale 1 se salta 
				; el GOTO
				; (si la resta fue igual a 0, se salta el GOTO)
	GOTO UNSEG_INC          ; Se queda enloopado hasta que 50 - W = 0
	CLRF CONTADOR_20MS      ; Se limpia CONTADOR_20MS
	INCF PORTC, F           ; Incrementa el valor de PORTC
	BSF PORTA, 6
	BSF PORTA, 7
	GOTO LOOP

    UNSEG_DEC:
        MOVF CONTADOR, W	; Copia el valor de CONTADOR a W
	SUBLW 3			; Se hace la resta 2 - W
	BTFSS STATUS, 2		; Revisa el bit 2 de STATUS, si vale 1 se salta 
				; el GOTO
				; (si la resta fue igual a 0, se salta el GOTO) 
	GOTO LOOP
	MOVF CONTADOR_20MS, W   ; Copia el valor de CONTADOR_20MS a W
	SUBLW 50                ; Se hace la resta 50 - W
	BTFSS STATUS, 2	        ; Revisa el bit 2 de STATUS, si vale 1 se salta 
				; el GOTO
				; (si la resta fue igual a 0, se salta el GOTO)
	GOTO UNSEG_DEC          ; Se queda enloopado hasta que 50 - W = 0
	CLRF CONTADOR_20MS      ; Se limpia CONTADOR_20MS
	DECF PORTC, F           ; Decrementa el valor de PORTC
	BCF PORTA, 6
	BCF PORTA, 7
	GOTO LOOP
    
;******************************************************************************* 
; Fin de Código    
;******************************************************************************* 
END   