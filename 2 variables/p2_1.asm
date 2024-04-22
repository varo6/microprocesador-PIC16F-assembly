	LIST P= 16f876A
	include "p16f876a.inc"

	__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF
	
	valor	EQU	0x30
	ORG 0 
	goto	inicio	

	ORG 5

inicio

	call inicializar
	BSF	STATUS,RP0	;Banco 1
	movlw	b'00111100'	
	movwf	TRISC
	clrf	TRISB

	BCF	STATUS,RP0;Banco 0
	clrf	INDF
main	
	movf	PORTC,0
	movwf	valor
	RRF	valor,1
	RRF	valor,1
	movlw	0x0F
	andwf	valor,1
	movf	valor,0
	addlw	0x20
	movwf	FSR
	movf	INDF,0
	movwf	PORTB
	goto main

inicializar
	movlw	0xFC
	movwf	0x20
	
	movlw	0x60
	movwf	0x21

	movlw	0xDA
	movwf	0x22

	movlw	0xF2
	movwf	0x23
	
	movlw	0x66
	movwf	0x24

	movlw	0xB6
	movwf	0x25

	movlw	0xBE
	movwf	0x26
	
	movlw	0xE0
	movwf	0x27

	movlw	0xFE
	movwf	0x28
	
	movlw	0xE6
	movwf	0x29

	movlw	0xEE
	movwf	0x2A

	movlw	0x3E
	movwf	0x2B

	movlw	0x9C
	movwf	0x2C

	movlw	0x7A
	movwf	0x2D

	movlw	0x9E
	movwf	0x2E

	movlw	0x8E
	movwf	0x2F
return

END	
	