	LIST P= 16f876A
	include "p16f876a.inc"

	__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF

	decenas		EQU 0x20
	unidades	EQU	0X21
	valor		EQU	0x22
	ORG 0

	goto inicio
	ORG	5
inicio
	
	;pongo PORTA en digital(ADCON1 bank0)
	movlw	0x06
	movwf	ADCON1

	BSF	STATUS,	RP0	;Select bank 1

	movlw	b'00111111'
	movwf	TRISA
	clrf	TRISB
	clrf	TRISC

	BCF	STATUS,	RP0; Vuelvo bank 0

	movf	PORTA,0
	movwf	valor
	
	RRF	valor,1
	movlw	0x1F
	andwf	valor,1
main
	call restando
	goto	main

restando

	movlw	.10
	subwf 	valor, W    	; Restarle a valor 10 y miro acarreo (C)
    BTFSS	STATUS, C  ;Si C es 1 es positivo y si es 0 negativo (Salta si 1)
	goto	es_negati
	goto	es_positi
es_positi

	movlw .10   	 ; Carga 10 en W
	subwf valor, 1   ; Resta 10 el valor de valor xd
	incf	decenas,1	;Incremento en 1 las decenas
	goto restando

es_negati

	movf	valor,0
	movwf	unidades
	
	goto main

END
		