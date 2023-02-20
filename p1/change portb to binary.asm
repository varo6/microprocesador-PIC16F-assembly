	LIST P= 16F876A
	include "p16f876a.inc"

	__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF

	ORG 0
	goto	inicio

	ORG 5 ;Instruccion 5
;----------------Inicio del programa----------------
inicio
	
	BSF		STATUS, RP0 ;Cambia al banco 1
	CLRF	TRISC 		;Ponemos a portc en modo salida
	BCF		STATUS,	RP0 ;Volvemos al banco 0

main
	movlw	b'10100101' ;Paso el binario al acumulador
	movwf	PORTC		;Paso lo del acumulador a PORTC
	goto main

END

