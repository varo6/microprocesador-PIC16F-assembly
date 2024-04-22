    LIST P= 16f876A
    include "p16f876a.inc"

    __CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF

    CICLO_2_5ms	EQU 0x20

    ORG	0
    goto	inicio

    ORG 4
    goto	int
    ORG 5

inicio
    ; Activo bits de interrucpcion
    BSF	INTCON,	GIE
    BSF	INTCON, T0IE

    ; Banco 1 para poner T0CS en reloj y PSA prescaler
    BSF	STATUS,RP0
    BCF		OPTION_REG, T0CS ; Ponemos T0CS a 0 para usar el reloj interno
    BCF		OPTION_REG, PSA  ; Asignamos el prescaler a Timer0
    BSF		OPTION_REG, PS0  ; Ponemos PS0 a 1
    BSF		OPTION_REG, PS1  ; Ponemos PS1 a 1
    BCF		OPTION_REG, PS2  ; Ponemos PS2 a 0
    BCF	STATUS,RP0        ; Vuelvo al banco 0
    clrf	CICLO_2_5ms      ; Inicializo mi variable

	; Prescaler 1:16 va hasta 4096. 156 equivale a 2500ms entonces 256-156=100
    movlw	.100
    movwf	TMR0

main
    goto main

int
    BCF	INTCON,T0IF	;Limpiamos el bit de flag de interrupción.
    movlw	.100	;Volvemos a poner 100 decimal en TMR0 para que falten 2,5ms para que desborde.
    movwf	TMR0
    incf	CICLO_2_5ms,1	;Incrementamos nuestra variable
    retfie		
END