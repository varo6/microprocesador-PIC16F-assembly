	LIST P= 16f876A
	include "p16f876a.inc"

	__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF

	CICLO_10ms	EQU 0x20
	SEGUNDOS	EQU	0X21
	
	ORG	0
	goto	inicio

	ORG 4
	goto	int
	ORG 5

inicio
	;Activo bits de interrucpcion
	BSF	INTCON,	GIE
	BSF	INTCON, T0IE

	;Banco 1 para poner T0CS en reloj y PSA prescaler
	BSF	STATUS,RP0
	BCF		OPTION_REG, T0CS ; Ponemos T0CS a 0 para usar el reloj interno
	BCF		OPTION_REG, PSA ; Asignamos el prescaler a Timer0
	BSF		OPTION_REG, PS0 ; Ponemos PS0 a 1
	BCF		OPTION_REG, PS1 ; Ponemos PS1 a 0
	BSF		OPTION_REG, PS2 ; Ponemos PS2 a 1
	clrf	TRISB
	BCF	STATUS,RP0	;Vuelvo al banco 0
	
	;Prescaler 1:64 va hasta 16384. 156 equivale a 10000ms entonces 256-156=100
	movlw	.100
	movwf	CICLO_10ms
	movwf	TMR0
	CLRF	SEGUNDOS
	;ciclo_10ms a 100
	
main

	goto main
	
int
	BCF	INTCON,T0IF
	movlw	.103
	movwf	TMR0
	DECFSZ	CICLO_10ms,1
	retfie
	call aumento_1sec
	retfie

aumento_1sec
	;BSF	STATUS,RP0
	movf	SEGUNDOS,0
	BSF	STATUS,RP0
	movwf	PORTB
	BCF	STATUS,RP0
	movlw	.59	; Cargar el valor 59 en W
	SUBWF SEGUNDOS, W    ; Restar el valor de SEGUNDOS a 59 y guardar el resultado en W
	BTFSC	STATUS,Z
	clrf	SEGUNDOS ;CAMBIAR PORQUE goto tal
	incf	SEGUNDOS,1
	movlw	.103
	movwf	CICLO_10ms            
        ; Guardar el resultado en el registro STATUS
	return
	
END	

;BTFSC	STATUS,Z;z se pone a 1 cuando resultado=0