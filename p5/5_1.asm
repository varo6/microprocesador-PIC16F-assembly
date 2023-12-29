;-------------------------------------------------------
	LIST p=16F876A
	INCLUDE "p16f876a.inc"
	__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF
;-------------------------------------------------------
	ORG	0
	goto	inicio

	ORG 4
	goto	ISR
	ORG 5

inicio

    bsf		RCSTA,SPEN
	bcf		RCSTA,RX9
	bsf		RCSTA,CREN
	
    bsf     STATUS,RP0
	CLRF	TRISB
	BSF		TRISC, 7
	BSF		TRISC, 6
	movlw	.25
	movwf	SPBRG
	bcf		TXSTA,SYNC
	bsf		TXSTA,BRGH
	bsf		PIE1,RCIE
;	bsf		PIE1,TXIE
	bcf		STATUS,RP0

	bsf		INTCON,GIE
	bsf		INTCON,PEIE	

main
	goto	main

ISR
	
	movf	RCREG,0
	movwf	PORTB
	movwf	TXREG
	retfie

	END