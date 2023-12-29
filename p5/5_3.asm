;-------------------------------------------------------
		LIST p=16F876A
		INCLUDE "p16f876a.inc"
		__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF
;-------------------------------------------------------
punteroTX	EQU	0x20
punteroRX	EQU	0x21
n_datosRX	EQU	0x22
n_datosTX	EQU	0x23

	ORG	0
	goto	inicio

	ORG 4
	goto	ISR
	ORG 5

inicio


	movlw	.05
	movwf	n_datosRX

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

	btfss	PIR1,RCIF
	goto	int_rx
	btfss	PIR1,TXIF
	goto	int_tx
	retfie

int_rx

	movf	punteroRX,0
	movwf	FSR
	
	decfsz	n_datosRX,1	
	goto	recibe_datos
	goto	comprobarRX
	
recibe

	movf	RCREG,0
	movwf	0x40

int_tx

	