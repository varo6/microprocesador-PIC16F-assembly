	;Write a program that assigns to pin RB2 the value of the pin RB6.
	LIST P= 16f876A
	include "p16f876a.inc"

	__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF
	
	ORG	0
	goto	inicio

	
inicio

	BSF		STATUS, RP0 ;Cambia al banco 1
	CLRF	TRISB 		;Ponemos a portB en modo salida
	BCF		STATUS,	RP0 ;Volvemos al banco 0

main
	
	BTFSC	PORTB,6		;Salta si RB6 es 0
	BSF		PORTB,2		;Asigna a RB2 el valor de RB6
	BTFSS	PORTB,6		;Salta si RB6 es 1
	BCF		PORTB,2		;Asigna a RB2 el valor de RB6
	goto main

END