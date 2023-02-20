	LIST P= 16F876A
	include "p16f876a.inc"

	__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF

; Set up the main program
    ORG 0
	GOTO inicio

	ORG 5 ;Instruccion 5
; Main program
inicio
    
	BSF		STATUS, RP0      ; Select Bank 1, poniendo RP0 a 1
    CLRF 	TRISC            ;Vaciar TRISC para poner el PORTC en modo entrada
    movlw 	0xFF             ;Paso el bit 1 al acumulador
    movwf 	TRISB            ;Del acumulador al PORTB para que sea modo salida
    BCF   	STATUS, RP0      ;Select Bank 0 (RP0 en 0)

main    
    ; Copy value of PortB to PortC
    movf PORTB,0          ;Pasar portb al acumulador(reg 0)     
    MOVWF PORTC           ;Load the value of PortC into W
 
goto main 
    ; End of program
    END