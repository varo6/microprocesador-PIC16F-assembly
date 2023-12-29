
	LIST p=16F876A
	INCLUDE "p16f876a.inc"
	__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF

PWM			EQU	0x20
TH			EQU	0x21
apagado		EQU	0x22
puntero_RX	EQU	0x23
puntero_TX	EQU	0x24
letra		EQU	0x25
TH_unit		EQU	0x26
TH_decs		EQU	0x27
n_datosRX	EQU	0x28
n_datosTX	EQU	0x29
TH_aux		EQU	0x2A
TH_aux2		EQU	0x2B

	ORG	0
	goto	inicio

	ORG 4
	goto	ISR
	ORG 5

inicio
	
	call	inicializar
	BSF		STATUS,RP0
	movlw	0x00
	movwf	OPTION_REG	;Falling edge, módulo TMR0 y prescaler 1:2

	clrf	ADCON1

	movlw	b'00100100'
	movwf	TXSTA
	movlw	b'01100000'	
	movwf	PIE1

	movlw	b'00000001'
	movwf	TRISA
	movlw	b'11000000'
	movwf	TRISC
	
	BCF		STATUS,RP0

	movlw	0x81		;10000001
	movwf	ADCON0

	movlw	0x90
	movwf	RCSTA

	movlw	.25
	movwf	SPBRG

	movlw	.56	
	movwf	TMR0		

	movlw	0xF0
	movwf	INTCON
	movlw	.32			
	movwf	PWM
	movlw	0x0A
	movwf	TH
	
	clrf	apagado

	movlw	0x30
	movwf	puntero_RX

	movlw	0x40
	movwf	puntero_TX
	
	movlw	.06
	movwf	n_datosRX

main
	goto	main

ISR

	BTFSC	INTCON,T0IF
	goto	int_TMR0
	BTFSC	INTCON,INTF
	goto	int_RB0
	BTFSC	PIR1,ADIF
	goto	int_AD
	BTFSC	PIR1,RCIF
	goto	int_RX
	BTFSC	PIR1,TXIF
	goto	int_TX
	RETFIE	


int_TMR0
	
	BCF		INTCON,T0IF
	movlw	.56
	movwf	TMR0
 	
	DECFSZ	TH,1
	goto	sigue_TMR0		
	BCF		PORTC,0
	goto	sigue_TMR0
	RETFIE

sigue_TMR0

	DECFSZ	PWM,1
	RETFIE

	movlw	.32
	movwf	PWM		
	BTFSS	apagado,0	;Apagada
	BSF		PORTC,0		;enciendo RC0
	BSF		ADCON0,GO
	RETFIE

int_AD
	
	BCF		PIR1,ADIF
	
	movf	ADRESH,0
	movwf	TH

	RRF		TH,1
	RRF		TH,1
	RRF		TH,1
	movlw	0x1F
	ANDWF	TH,1
	movf	TH,0
	sublw	0x00
	BTFSC	STATUS,Z
	BSF		TH,0
	btfss	apagado,3
	RETFIE
	;Aqui compruebo lo del comando sdbmT
	movf	TH_aux,0
	XORWF	TH,0
	BTFSS	STATUS,Z
	goto	mismo_TH	;Esta subrutina es porque si el valor es el mismo TH
	bcf		apagado,3
	RETFIE

mismo_TH

	movf	TH_aux2,0
	movwf	TH
	RETFIE
	
int_RB0
	
	BCF		INTCON,INTF
	BTFSS	apagado,0
	goto	apagar
	goto	encender
	RETFIE

apagar
	BSF		apagado,0
	RETFIE
encender
	BCF		apagado,0
	RETFIE
int_rx
	
	;Aquí recibo los datos
	movf	punteroRX,0
	movwf	FSR
	incf	punteroRX
	movf	RCREG,0
	movwf	INDF
	decfsz	n_datosRX
	RETFIE

	;Aquí ya he recibido los datos y empiezo a analizar
	movlw	0x30
	movwf	punteroRX
	movwf	FSR
	
	movf	INDF,0
	sublw	's'
	
	BTFSS	STATUS,Z
	goto	not_found
	goto	es_s	
	RETFIE
	
not_found

	movlw	.8
	movwf	n_datosTX
	movlw	0x40
	movwf	puntero_TX
	bsf		STATUS,RP0		
	bsf		PIE1,TXIE
	bcf		STATUS,RP0
	retfie
	
es_s
	
	incf	FSR,1
	movf	INDF,0
	sublw	'd'
	BTFSS	STATUS,Z
	goto	not_found
	incf	FSR,1
	movf	INDF,0
	sublw	'b'
	BTFSS	STATUS,Z
	goto	not_found
	incf	FSR,1
	movf	INDF,0
	sublw	'm'
	BTFSS	STATUS,Z
	goto	not_found

	incf	FSR,1
	movf	INDF,0
	movwf	letra
	movlw	'T'
	subwf	letra,0
	btfsc	STATUS,Z
	goto	es_T
	movlw	'S'
	subwf	letra,0
	BTFSC	STATUS,Z
	goto	es_S2
	goto	invalid_command
	RETFIE

invalid_command

	movlw	.15
	movwf	n_datosTX
	movlw	0x49
	movwf	puntero_TX
	bsf		STATUS,RP0		
	bsf		PIE1,TXIE
	bcf		STATUS,RP0
	retfie	

es_T
;Usaré el tercer bit de apagado para ver si cambia el valor de TH en AD
	bsf		apagado,3
	movf	TH,0
	movwf	TH_aux
	;Hasta que la conversion de AD sea distinta de TH_aux, no cambiaré el valor de TH
	movlw	0x34	;Decenas
	movwf	FSR
	movf	INDF,0
	movwf	TH
	incf	FSR,1
	movf	INDF,0
	addwf	TH,1
	RRF		TH,1
	RRF		TH,1
	RRF		TH,1
	movlw	0x1F
	ANDWF	TH,1
	movf	TH,0
	movwf	TH_aux2
	RETFIE
	
es_S2	;Aquí comprobaré si es 0,1,T, o A

	incf	FSR,1
	movf	INDF,0
	movwf	letra
	movlw	'0'
	subwf	letra,0
	btfsc	STATUS,Z
	goto	apagar
	movlw	'1'
	subwf	letra,0
	btfsc	STATUS,Z
	goto	encender
	movlw	'A'
	subwf	letra,0
	btfsc	STATUS,Z
	goto	es_A
	goto	invalid_command
	RETFIE
	
es_A
	
	movf	TH,0
	movwf	TH_unit
	movwf	TH_decs
	RRF		TH_decs,1
	RRF		TH_decs,1
	RRF		TH_decs,1
	RRF		TH_decs,1
	movlw	0x0F
	andwf	TH_decs,1
	andwf	TH_unit,1
	
	movf	TH_decs,0
	movwf	0x5B
	movf	TH_unit,0
	movwf	0x5C
	
	movlw	0x58
	movwf	puntero_TX
	movlw	.5
	movwf	n_datosTX
	bsf		STATUS,RP0		
	bsf		PIE1,TXIE
	bcf		STATUS,RP0
	btfsc	apagado,0
	goto	poner_1
	goto	poner_0
	RETFIE	

poner_1

	movlw	0x01
	movwf	0x5A
	RETFIE

poner_0

	movlw	0x00
	movwf	0x5A
	RETFIE

int_tx
	
	movf	puntero_TX,0
	movwf	FSR
	movf	INDF,0
	movwf	TXREG
	decfsz	n_datosTX,1

	goto 	sigue_enviando
	BTFSS	apagado,5	;Como el bit 5 no lo uso, lo usaré para el envío de LF y CR
	goto	LFCR

	bcf		apagado,5
	BCF		STATUS,RP0
	BCF		PIE1,TXIE
	BSF		STATUS,RP0
	retfie

sigue_enviando

	incf	puntero_TX,1
	retfie

LFCR

	movlw	.2
	movwf	n_datosTX
	movlw	0x5D
	movwf	puntero_TX
	bsf		apagado,5
	retfie

inicializar

	movlw	'N'
	movwf	0x40

	movlw	'o'
	movwf	0x41

	movlw	't'
	movwf	0x42

	movlw	' '
	movwf	0x43

	movlw	'f'
	movwf	0x44

	movlw	'o'
	movwf	0x45

	movlw	'u'
	movwf	0x46

	movlw	'n'
	movwf	0x47

	movlw	'd'
	movwf	0x48

	movlw	'I'
	movwf	0x49

	movlw	'n'
	movwf	0x4A

	movlw	'v'
	movwf	0x4B

	movlw	'a'
	movwf	0x4C

	movlw	'l'
	movwf	0x4D

	movlw	'i'
	movwf	0x4E

	movlw	'd'
	movwf	0x4F

	movlw	' '
	movwf	0x50

	movlw	'c'
	movwf	0x51

	movlw	'o'
	movwf	0x52

	movlw	'm'
	movwf	0x53

	movlw	'm'
	movwf	0x54

	movlw	'a'
	movwf	0x55

	movlw	'n'
	movwf	0x56

	movlw	'd'
	movwf	0x57

	movlw	'L'
	movwf	0x58

	movlw	'1'
	movwf	0x59

	movlw	''
	movwf	0x5A

	movlw	''
	movwf	0x5B

	movlw	''
	movwf	0x5C

	movlw	.10
	movwf	0x5D

	movlw	.13
	movwf	0x5E
	return

END
	