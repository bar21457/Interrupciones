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
 DISP_D:                ; Contiene el valor de las decenas del display
    DS 1
 DISP_U:                ; Contiene el valor de las unidades del display
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
    
TT0IF:
    BCF INTCON, 0
    BTFSS INTCON, 2     ; Revisa el bit 2 de INTCON (Bandera de interrupción),
                        ; si vale 1 se salta el GOTO
    GOTO RRBIF
    BCF INTCON, 2       ; Cambia a 0 el bit 2 de INTCON (Se apaga la bandera)
    INCF CONTADOR       ; Incrementa el valor de CONTADOR
    MOVLW 178           ; Se carga 178 a W
    MOVWF TMR0		; Se carga el valor de n = 78 para obtener los 1000ms
    GOTO POP

RRBIF:
    BTFSS INTCON, 0     ; Revisa el bit 0 de INTCON (Bandera de interrupción),
                        ; si vale 1 se salta el GOTO
    GOTO POP
    BCF INTCON, 0       ; Cambia a 0 el bit 0 de INTCON (Se apaga la bandera)
    BTFSS PORTB, 0      ; Revisa el bit 0 de PORTB, si vale 1 se salta el 
                        ; BSF PB
    BSF PB, 0           ; Cambia a 1 el bit 0 de PB
    BTFSS PORTB, 1      ; Revisa el bit 1 de PORTB, si vale 1 se salta el 
                        ; BSF PB
    BSF PB, 1           ; Cambia a 1 el bit 1 de PB
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
    CLRF PORTD          ; Se inicia el puerto

    BANKSEL IOCB 
    BSF IOCB, 0         ; Se configura el pin RB0 como un pin de interrupción
    BSF IOCB, 1         ; Se configura el pin RB1 como un pin de interrupción
    BSF TRISB, 0        ; Se configura el pin RB0 como un input
    BSF TRISB, 1        ; Se configura el pin RB1 como un input
    
    banksel TRISA       ; Selección del banco donde se encuentra TRISA
    CLRF TRISA          ; Se configura el puerto TRISA como un output
    CLRF TRISC          ; Se configura el puerto TRISC como un output
    CLRF TRISD          ; Se configura el puerto TRISD como un output
    
    BANKSEL WPUB 
    BSF WPUB, 0         ; Se configura el pin RB0 con pull-up
    BSF WPUB, 1         ; Se configura el pin RB1 con pull-up
    
    CLRF PB             ; Se limpia PB
    CLRF CONTADOR       ; Se limpia CONTADOR
    CLRF DISP_D         ; Se limpia DISP_D
    CLRF DISP_U         ; Se limpia DISP_U
    
    ; Configuración de TMR0
    
    BANKSEL OPTION_REG  ; Selección del banco donde se encuentra OPTION_REG
    
    BCF OPTION_REG, 5	; T0CS: selección de FOSC/4 como reloj temporizador
    BCF OPTION_REG, 3	; PSA: asignamos el prescaler al TMR0
    
    BSF OPTION_REG, 2
    BSF OPTION_REG, 1
    BSF OPTION_REG, 0	; PS2-0: Prescaler en 1:256
    
    BANKSEL PORTB       ; Selección del banco donde se encuentra PORTB
    CLRF CONTADOR	; Se limpia CONTADOR
    MOVLW 178           ; Se carga 178 a W
    MOVWF TMR0		; Se carga el valor de n = 78 para obtener los 1000ms
    
;*******************************************************************************
; Ejecución del programa principal
;*******************************************************************************
    
LOOP:
    CALL INCREMENTO_A
    CALL DECREMENTO_A
    MOVF DISP_U, W	; Carga el valor de DISP_U a W
    PAGESEL TABLA
    CALL TABLA		
    MOVWF PORTC		; Se carga el valor de W a PORTC
    GOTO VERIFICACION2	

VERIFICACION:    
    MOVF CONTADOR, W    ; Carga el valor de CONTADOR a W
    SUBLW 50            ; Resta el valor de CONTADOR a 50
    BTFSS STATUS, 2	; Se verifica si el resultado es 0, si vale 1, se
                        ; salta el GOTO
    GOTO VERIFICACION	; Regresa a VERIFICACION hasta que la resta sea 0
    CLRF CONTADOR	      ; Se limpia CONTADOR
    INCF DISP_U, F	; Incrementamos el DISP_U
    GOTO LOOP		

VERIFICACION2:
    MOVF DISP_U, W	; Carga el valor de DISP_U a W
    SUBLW 10		; Resta el valor de DISP_U a 10
    BTFSS STATUS, 2	; Se verifica si el resultado es 0, si vale 1, se
                        ; salta el GOTO
    GOTO VERIFICACION	; Regresa a VERIFICACION hasta que la resta sea 0
    MOVLW 0b0111111	; Se carga 0 a W
    MOVWF PORTC		; Se carga el valor de W a PORTC
    CLRF DISP_U         ; Se limpia DISP_U
    GOTO RELOJ

RELOJ:
    INCF DISP_D, F	; Se incrementa el valor de DISP_D
    MOVF DISP_D, W	; Carga el valor de DISP_D a W
    PAGESEL TABLA
    CALL TABLA		
    MOVWF PORTD		; Se carga el valor de W al PORTD
    GOTO VERIFICACION3	

VERIFICACION3:
    MOVF DISP_D, W	; Carga el valor de DISP_D a W
    SUBLW 6		      ; Resta el valor de DISP_D a 50
    BTFSS STATUS, 2	; Se verifica si el resultado es 0, si vale 1, se
                        ; salta el GOTO
    GOTO VERIFICACION	; Regresa a VERIFICACION hasta que la resta sea 0
    MOVLW 0b0111111	; Se carga 0 a W
    MOVWF PORTD		; Se carga el valor de W a PORTD
    CLRF DISP_D	      ; Se limpia DISP_D
    GOTO VERIFICACION	
    
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
    
PSECT CODE, delta=2, abs
 ORG 0x64
TABLA:
    ADDWF PCL, F
    RETLW 0b0111111	;0
    RETLW 0b0000110	;1 
    RETLW 0b1011011	;2 
    RETLW 0b1001111	;3 
    RETLW 0b1100110	;4 
    RETLW 0b1101101	;5 
    RETLW 0b1111101	;6 
    RETLW 0b0000111	;7 
    RETLW 0b1111111	;8 
    RETLW 0b1101111	;9 
    RETLW 0b1110111	;A 
    RETLW 0b1111100	;b
    RETLW 0b0111001	;C 
    RETLW 0b1011110	;d 
    RETLW 0b1111001	;E
    RETLW 0b1110001	;F 
    
;*******************************************************************************
; Fin de Código
;*******************************************************************************
END