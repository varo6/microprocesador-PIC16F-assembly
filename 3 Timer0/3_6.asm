	LIST P= 16f876A
	include "p16f876a.inc"

	__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF

	CICLO_4ms	EQU 0x20
	segundos	EQU	0X21
	PORTB_aux	EQU	0x22
	countdown	EQU	0x23
	decenas		EQU	0x24
	unidades	EQU	0x25
	valor_aux	EQU	0x26
	valor_aux2	EQU	0x27

	ORG	0
	goto	inicio

	ORG 4
	goto	ISR
	ORG 5

inicio

	call	inicializo_valores		;Valores de los números del 1 al 9 en ASCII

	;Activo bits de interrupcion
	BSF	INTCON,	GIE
	BSF	INTCON,	RBIE			;Activo int de RB7:4
	BCF	INTCON, T0IE			;TMR0. Se activa para el display
	BSF INTCON,	INTE			;Activo RB0

	;Banco 1 para poner T0CS en reloj y PSA prescaler
	BSF	STATUS,RP0
	movlw	b'01000011' 		;A 1: INTEDG, PS1 y PS0 / A 0: T0CS, PSA
	movwf	OPTION_REG
	movlw	b'1111001' 			;Pongo a 1: RB7,RB6,RB5,RB4,RB0 
	movwf	TRISB
	clrf	TRISC
	BCF	STATUS,RP0				;Vuelvo al banco 0
	
	;Prescaler 1:16 va hasta 4096us. 4000us equivale a 250 ciclos/ 256-250 es 6
	movlw	.250
	movwf	CICLO_4ms
	movlw	.6
	movwf	TMR0
	movlw	.23
	movwf	segundos
	;

main
	goto main
	
ISR	;Aqui direccionaré depende de la interrupción que tenga

	BTFSC	INTCON,	T0IF 		;Voy a int timer si su flag es 1
	goto	int_tmr0
	BTFSC	INTCON,	RBIF		;voy a int rb47 si su flag es 1
	goto	int_rb47
	BTFSC	INTCON,	INTF		;voy a int rb0 si su flag es 1
	goto	int_rb0
	retfie

int_tmr0						;Como el display de 4ms siempre estará activo, he hecho una variable que aciva el countdown

	BCF		INTCON,T0IF
	call	display_4ms
	BTFSC	countdown			;Salta si la variable "countdown" está desactivada
	goto	rutina_countdown
	movlw	.6
	movwf	TMR0
	retfie

display_4ms

	BTFSS	PORTB,RB1			;Cada 4ms, el valor de RB2 irá a 0 si está en 1 y con RB1 tambien.
	goto	es_rb2				;RB1 valdrá 0 y serán segundos los que se muestren
	goto	es_rb1				;RB2 valdrá 0 y se mostrará los minutos
	
rutina_countdown
	
	movlw	.6
	movwf	TMR0
	movf	segundos,0			;Aquí el valor de segundos a valor_aux
	movwf	valor_aux			;Llamo a restando para actualizar los valores de decenas/unidades
	call	restando			;Los mostraré en display cuando pasen otros 4ms.
	DECFSZ	CICLO_4ms,1
	retfie						;Mientras no haya pasado 1 segundo no salta.
	movlw	.250				
	movwf	CICLO_4ms
	DECFSZ	segundos,1
	retfie
	goto	cero_segundos	  
        ; Guardar el resultado en el registro STATUS
	return

cero_segundos	;Aquí desactivaré la interrupción RB0 y la cuenta solo se podrá seguir con RB4

	clrf	decenas
	clrf	unidades
	BCF		INTCON,INTE
	BCF		countdown
	retfie
	

int_rb0							;Interrupción de RB0. Solo dos funciones.

	BCF		INTCON,	INTF
	BTFSC	countdown			
	goto	desactivo_cdown		;Si countdown estaba activado aquí lo desactivo
	BSF		countdown			;Si countdown estaba en 0 (desactivado) salto y lo activo
	retfie

desactivo_cdown

	BCF		countdown			;Desactivo TMR0
	retfie
	
int_rb47

	BCF		INTCON, RBIF
	MOVF	PORTB_aux, 0		;Paso PORTB al registro
	XORWF	PORTB, 0			;XORWF de portb al registro
	MOVWF	VALOR_XOR			;muevo resultado a valor_xor
	MOVF	PORTB, 0			;PORTB a wreg
	MOVWF	PORTB_anterior		;paso wreg a PORTB_anterior
	BTFSC	VALOR_XOR, 4		;Salto si RB4 es 0
	GOTO	RB4Soltado			;goto pulsa
	BTFSC	VALOR_XOR, 5		;
	GOTO	suelta5resta		;
	BTFSC	VALOR_XOR, 7		;
	GOTO	pulsaRB7			;
	RETFIE	

pulsa4suma

	BTFSS	PORTB, 4
	INCF	PORTC, 1
	RETFIE	

suelta5resta

	BTFSC	PORTB, 5
	DECF	PORTC, 1
	RETFIE	

pulsa7reset

	BTFSS	PORTB, 7
	CLRF	PORTC
	RETFIE

restando	;ANTES DE LLAMAR pasar segundos a valor_aux

	movlw	.10
	subwf 	valor_aux, W	;Restarle a valor 10 y miro acarreo (C)
    BTFSC	STATUS, C  		;Si C es 1 es positivo y si es 0 negativo (Salta si 1)
	goto	mayor_que10		
	goto	menor_que10


mayor_que10 ;Si Z 

	movlw 	.10   	 		; Carga 10 en W
	subwf 	valor_aux, 1	; Resta 10 el valor de valor_aux
	incf	decenas,1		;Incremento en 1 las decenas
	goto 	restando

menor_que10 ;Unidades es valor_aux

	movf	valor_aux,0
	movwf	unidades	
	return

es_cero

	clrf	decenas
	clrf	unidades
	return


es_rb2 	;Aqui rb2 vale 1 asi que lo pongo en 0

	movf	unidades,0	
	call	mostrar_portc
	BCF		PORTB,RB2
	BSF		PORTB,RB1
	retfie

es_rb1	;Aqui rb1 vale 1 asi que lo pongo en 0

	movf	decenas,0	
	call	mostrar_portc
	BSF	PORTB,RB2
	BCF	PORTB,RB1
	retfie

muestro_portc			;Direcc. indirecto con lo que haya en wreg

	addlw	0x40
	movwf	FSR
	movf	INDF,0
	movwf	PORTC
	return

inicializo_valores

	movlw	0xFC
	movwf	0x40
	
	movlw	0x60
	movwf	0x41

	movlw	0xDA
	movwf	0x42

	movlw	0xF2
	movwf	0x43
	
	movlw	0x66
	movwf	0x44

	movlw	0xB6
	movwf	0x45

	movlw	0xBE
	movwf	0x46
	
	movlw	0xE0
	movwf	0x47

	movlw	0xFE
	movwf	0x48
	
	movlw	0xE6
	movwf	0x49

	movlw	0xEE
	movwf	0x4A

	movlw	0x3E
	movwf	0x4B

	movlw	0x9C
	movwf	0x4C

	movlw	0x7A
	movwf	0x4D

	movlw	0x9E
	movwf	0x4E

	movlw	0x8E
	movwf	0x4F
return

END	

;BTFSC	STATUS,Z;z se pone a 1 cuando resultado=0
;-----------------------------------------
;Interrupcion en RB0 para iniciar countdown
;Cuando countdown es 0 interrupcion en RB4 para repetirlo
;Setting mode en RB5 para subir o bajar el countdown con RB7 y RB6
;