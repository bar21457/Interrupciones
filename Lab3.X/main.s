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
 PB:                            ; Indica el estado del pushbutton
    DS 1
 W_TEMP:                        ; Guarda temporalmente el contenido de W
    DS 1
 STATUS_TEMP:                   ; Guarda temporalmente el contenido de STATUS
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
    
ISR:
    BANKSEL PORTB
    BTFSS PORTB,0       ; Revisa el bit 0 de PORTB, si vale 1 se salta el 
                        ; BSF PB
    BSF PB, 0           ; Cambia a 1 el bit 0 de PB
    BTFSS PORTB,1       ; Revisa el bit 1 de PORTB, si vale 1 se salta el 
                        ; BSF PB
    BSF PB, 1           ; Cambia a 1 el bit 1 de PB
    BCF INTCON, 0       ; Cambia a 0 el bit 0 de INTCON
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
    
    
;*******************************************************************************
; Ejecución del programa principal
;*******************************************************************************
    
LOOP:

    
;*******************************************************************************
; Fin de Código
;*******************************************************************************
END