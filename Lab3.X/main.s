;*******************************************************************************
; Universidad del Valle de Guatemala
; IE20203 Programación de Microcontroladores
; Autor: Byron Barrientos
; Compilador: PIC-AS (v2.36), MPLAB X IDE (v.600)
; Proyecto: TMR0_y_Botones
; Hardware: PIC16F887
; Creado: 09/08/2022
; Última Modificación: 15/08/2022
;*******************************************************************************

PROCESSOR 16F887
#include <xc.inc>
;*******************************************************************************
;Palabra de configuración
;***************************************************************************
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
;Variables
;*******************************************************************************
PSECT udata_bank0
 PB:                    ; Indica el estado del pushbutton (Bandera)
    DS 1
 W_TEMP:                ; Guarda temporalmente el contenido de W
    DS 1
 STATUS_TEMP:           ; Guarda temporalmente el contenido de STATUS
    DS 1
 CONTADOR:              ; Lleva el control del valor del contador de 1s
    DS 1
 
;*******************************************************************************
;Vector Reset
;*******************************************************************************
PSECT CODE, delta=2, abs
 ORG 0x0000
    GOTO MAIN

;******************************************************************************* 
; Vector ISR Interrupciones    
;******************************************************************************* 
PSECT CODE, delta=2, abs
 ORG 0x0004

PUSH: 
    MOVWF W_TEMP
    SWAPF STATUS, W
    MOVWF STATUS_TEMP
    
RBIF:
    BTFSS INTCON, 0     ; Revisa el bit 0 de INTCON (Bandera de interrupción),
                        ; si vale 1 se salta el GOTO
    GOTO TOIF
    BCF INTCON, 0       ; Cambia a 0 el bit 0 de INTCON (Se apaga la bandera)
    BTFSS PORTB, 0      ; Revisa el bit 0 de PORTB, si vale 1 se salta el 
                        ; BSF PB
    BSF PB, 0           ; Cambia a 1 el bit 0 de PB
    BTFSS PORTB, 1      ; Revisa el bit 1 de PORTB, si vale 1 se salta el 
                        ; BSF PB
    BSF PB, 1           ; Cambia a 1 el bit 1 de PB
    GOTO POP
    
TOIF:
    BTFSS INTCON, 2     ; Revisa el bit 2 de INTCON (Bandera de interrupción),
                        ; si vale 1 se salta el GOTO
    GOTO POP
    BCF INTCON, 2       ; Cambia a 0 el bit 2 de INTCON (Se apaga la bandera)
    INCF CONTADOR       ; Incrementa el valor de CONTADOR
    MOVLW 61            ; Se carga 61 a W
    MOVWF TMR0          ; Se carga W a TMR0 para que n = 195 y así tener 100ms
    GOTO POP

POP:
    SWAPF STATUS_TEMP, W
    MOVWF STATUS
    SWAPF W_TEMP, F
    SWAPF W_TEMP, W
    RETFIE

;*******************************************************************************
;Código Principal
;*******************************************************************************
PSECT CODE, delta=2, abs
 ORG 100h

MAIN:

    BANKSEL OSCCON
    BSF OSCCON, 0       
    BCF OPTION_REG, 7   
    
    BANKSEL ANSEL       ; Selección del banco donde se encuentra ANSEL
    CLRF ANSEL          
    CLRF ANSELH         ; Los pines son todas I/O digitales
    
    BSF TRISB, 0        ; Se configura el pin RB0 como un input
    BSF TRISB, 1        ; Se configura el pin RB1 como un input
    
    BSF INTCON, 7       ; Se activa el GIE (Interrupciones Globales)
    BSF INTCON, 5       ; Se activa el T0IE (Interrupción del TMR0)
    BSF INTCON, 3       ; Se activa el RBIE (Interrupciones del PORTB)
    BCF INTCON, 0       ; Se activa el RBIF (Banderas de interrupción del PORTB)
   
    BANKSEL PORTB
    CLRF PORTA          ; Se inicia el puerto
    CLRF PORTB          ; Se inicia el puerto
    CLRF PORTC          ; Se inicia el puerto

    BANKSEL IOCB 
    BSF IOCB, 0         ; Se configura el pin RB0 como un pin de interrupción
    BSF IOCB, 1         ; Se configura el pin RB1 como un pin de interrupción
    BSF TRISB, 0        ; Se configura el pin RB0 como un input
    BSF TRISB, 1        ; Se configura el pin RB1 como un input
    CLRF TRISA          ; Se configura el puerto TRISA como un output
    
    BANKSEL WPUB 
    BSF WPUB, 0         ; Se configura el pin RB0 con pull-up
    BSF WPUB, 1         ; Se configura el pin RB1 con pull-up
    
    CLRF PB             ; Se limpia PB
    
    ; Configuración de TMR0
    
    BANKSEL OPTION_REG  ; Selección del banco donde se encuentra OPTION_REG
    
    BCF OPTION_REG, 5	; T0CS: selección de FOSC/4 como reloj temporizador
    BCF OPTION_REG, 3	; PSA: asignamos el prescaler al TMR0
    
    BSF OPTION_REG, 2
    BSF OPTION_REG, 1
    BSF OPTION_REG, 0	; PS2-0: Prescaler en 1:256
    
    BANKSEL PORTB       ; Selección del banco donde se encuentra PORTB
    CLRF CONTADOR	; Se limpia CONTADOR
    MOVLW 61            ; Se carga 61 a W
    MOVWF TMR0		; Se carga el valor de n = 195 para obtener los 100ms
    
;*******************************************************************************
; Ejecución del programa principal
;*******************************************************************************
    
LOOP:
    CALL INCREMENTO_A
    CALL DECREMENTO_A
    GOTO LOOP
    
VERIFICACION:
    MOVF CONTADOR, W    ; Carga el valor de CONTADOR a W
    SUBLW 10            ; Resta el valor de CONTADOR a 10
    BTFSS STATUS, 2     ; Se verifica si el resultado es 10, si vale 1, se
                        ; salta el GOTO
    GOTO VERIFICACION
    INCF PORTD, F       ; Incrementa el valor del PORTC
    CLRF CONTADOR       ; Se limpia CONTADOR
    GOTO LOOP
    
;*******************************************************************************
;Subrutinas
;*******************************************************************************
   
INCREMENTO_A: 
    BTFSS PB, 0         ; Revisa el bit 0 de PB, si vale 1 se salta el REUTRN
    RETURN              
    INCF PORTA, F       ; Incrementa el valor del PORTC
    BTFSC PORTA, 4      ; Revisa el bit 4 de PORTC, si vale 0 se salta CLRF
    CLRF PORTA          ; Se limpia PORTC
    CLRF PB             ; Se limpia PB
    RETURN 
    
DECREMENTO_A: 
    BTFSS PB, 1         ; Revisa el bit 1 de PB, si vale 1 se salta el REUTRN
    RETURN              
    DECF PORTA, F       ; Decrementa el valor del PORTC
    MOVLW 0x0F          ; Se carga 0x0F a W
    BTFSC PORTA, 4      ; Revisa el bit 4 de PORTC, si vale 0 se salta MOVWF
    MOVWF PORTA         ; Se carga el valor de W al PORTC
    CLRF PB             ; Se limpia PB
    RETURN
    
;*******************************************************************************
; Fin de Código
;*******************************************************************************
END