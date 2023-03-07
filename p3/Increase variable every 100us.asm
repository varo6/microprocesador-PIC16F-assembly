	;Exercise 3.3.  Write  a  program  using  the  Timer  0  module  and  its  interrupt  on  overflow  to  increase  variable 
	;CICLO_100us every 100 µs. CICLO_100us must be cleared at initialization.
	LIST P= 16f876A
	include "p16f876a.inc"

	__CONFIG _XT_OSC & _WDT_OFF & _LVP_OFF
	
	ciclo_100us	EQU 0x20	;Creamos la variable ciclo_100us
	ORG	0
	goto	inicio

	ORG 4					;Definimos la dirección de la interrupción.
	goto	int_tmr
	ORG	5
	;Importante: No es lo mismo incrementar 1 vez cada ciclo que 1 vez cada 100us. Cuando tmr0 desborde será cuando sumaremos 1.
inicio

	BSF INTCON,GIE	;Habilitar la interrupción
	BSF	INTCON,T0IE	;Habilitar timer0

	;Enable T0CS si queremos usar tiempo. (Bit del option register)
	BSF STATUS,RP0		;Cambiamos al banco 1 poniendo RP0 a 1
	BCF	OPTION_REG,T0CS	;Ponemos T0CS a 0 para poner tmr0 en reloj interno(T0cs pin de option_register)
	BSF	OPTION_REG,PSA	;Ponemos prescaler a 1 para que sea de watchdog timer
	;Si queremos el rate1:1 PSA tendrá que ser del WDT(a 1), para otros rate tenemos que poner prescaler a 0 para que sea de timer0
	BCF	STATUS,RP0		;Volvemos al banco 0
	movlw	.156
	movwf	TMR0	
	clrf ciclo_100us	;Inicializamos la variable ciclo100us (Poniendo el registro a 0)
main 
	;256-100=156 TMR0 tiene q empezar en 156
	goto main

;incf para sumar
int_tmr
	bcf	INTCON,T0IF		;ponemos a 0 t0if (Flag Interruption Activated)
	incf ciclo_100us,1	;incrementamos 1 cada vez
	movlw	.166
	movwf	TMR0
retfie
END
	

	
	
