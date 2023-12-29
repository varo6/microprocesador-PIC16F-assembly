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

	movlw	.208
	movwf	TMR0
	BSF		INTCON,GIE
	BSF		INTCON,PEIE
	BSF		INTCON,T0IE
	movlw	b'00010001'
	movwf	ADCON0

	BSF		STATUS,RP0
	BSF		TRISA,2
	BSF		PIE1,ADIE
	clrf 	TRISC
	movlw	b'00100010'
	movwf	OPTION_REG
	clrf	ADCON1

	BCF		STATUS,RP0

	


main
	goto	main


ISR
	
	BTFSC	INTCON,T0IF
	goto	int_tmr0
	BTFSC	PIR1,ADIF
	goto	int_ad
	retfie

int_tmr0

	BCF	INTCON, T0IF
	movlw	.208
	movwf	TMR0
	BSF		ADCON0, GO
	retfie

int_ad

	BCF		PIR1,ADIF
	movf	ADRESH,0
	movwf	PORTC
	retfie

END