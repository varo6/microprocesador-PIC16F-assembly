;-------------------------------------------------------
		LIST p=16F876A
		INCLUDE "p16f876a.inc"
		__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF
;-------------------------------------------------------
	
aux			EQU	0x20
punteroRX	EQU	0x21
n_datos		EQU	0x22


	ORG	0
	goto	inicio

	ORG 4
	goto	ISR
	ORG 5

inicio

	call	inicializar
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
	bsf		TXSTA,TXEN
	bsf		PIE1,RCIE
;	bsf		PIE1,TXIE
	bcf		STATUS,RP0

	bsf		INTCON,GIE
	bsf		INTCON,PEIE	

	
main
	goto	main

ISR
	btfsc	PIR1,RCIF
	goto	int_rx
	btfsc	PIR1,TXIF
	goto	int_tx
	retfie

int_rx
	
	movf	RCREG,0
	movwf	aux
	movlw	'R'
	subwf	aux,0
	btfsc	STATUS,Z
	goto	es_iniciado
	movlw	'S'
	subwf	aux,0
	btfsc	STATUS,Z
	goto	es_parado
	goto	es_error

	bsf		STATUS,RP0		
	bsf		PIE1,TXIE
	bcf		STATUS,RP0
	retfie

int_tx
	
	movf	INDF,0
	movwf	TXREG
	decfsz	n_datos,1

	goto 	sigue_enviando
	
	BCF		STATUS,RP0
	BCF		PIE1,TXIE
	BSF		STATUS,RP0
	retfie
	
sigue_enviando

	incf	FSR,1
	retfie
	
es_iniciado

	movlw	.8	
	movwf	n_datos
	movlw	0x40
	movwf	FSR
	bsf		STATUS,RP0		
	bsf		PIE1,TXIE
	bcf		STATUS,RP0
	retfie

es_parado

	movlw	.6
	movwf	n_datos
	movlw	0x47
	movwf	FSR
	bsf		STATUS,RP0		
	bsf		PIE1,TXIE
	bcf		STATUS,RP0
	retfie

es_error
	
	movlw	.5
	movwf	n_datos
	movlw	0x4D
	movwf	FSR
	bsf		STATUS,RP0		
	bsf		PIE1,TXIE
	bcf		STATUS,RP0
	retfie

inicializar

	movlw	'I'
	movwf	0x40

	movlw	'N'
	movwf	0x41

	movlw	'C'
	movwf	0x42

	movlw	'I'
	movwf	0x43

	movlw	'A'
	movwf	0x44

	movlw	'D'
	movwf	0x45

	movlw	'O'
	movwf	0x46

	movlw	'P'
	movwf	0x47

	movlw	'A'
	movwf	0x48

	movlw	'R'
	movwf	0x49

	movlw	'A'
	movwf	0x4A

	movlw	'D'
	movwf	0x4B

	movlw	'O'
	movwf	0x4C

	movlw	'E'
	movwf	0x4D

	movlw	'R'
	movwf	0x4E

	movlw	'R'
	movwf	0x4F

	movlw	'O'
	movwf	0x50

	movlw	'R'
	movwf	0x51
	return

END

