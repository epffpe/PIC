;Este programa hace que un mensaje circule en la pantalla
;de un modulo lcd			;p=16f84a, osc=xt, wdt=off
	;LIST	p=16F84A		;tell assembler what chip we are using
	;include "P16F84A.inc"
indf	equ		0h		;para direccionamiento indirecto
tmr0	equ		1h
pc		equ		2h
status	equ		3h
rp0		equ		5h
fsr		equ		4h
ptoa	equ		5h
ptob	equ		6h
r0c		equ		0ch
r0d		equ		0dh
r13		equ		13h
r14		equ		14h
z		equ		2h
c		equ		0h
w		equ		0h
r		equ		1h
e		equ		1h
rs		equ		0h
		cblock	0x20			;start of general purpose registers
			count			;used in looping routines
			count1			;used in delay routine
			counta			;used in delay routine
			countb			;used in delay routine
			tmp1			;temporary storage
			tmp2
			templcd			;temp store for 4 bit mode
			templcd2	
		endc

		org		00
		goto 	inicio

ret40u 	movlw	0x0D
		goto	sig				
ret100u movlw	0x21
sig		movwf	r13
decre	decfsz	r13,r
		goto 	decre
		retlw	0

ret15ms movlw	0x0f
		goto	cuenta
retardo movlw	0x01
		goto	cuenta
ret4ms  movlw	5h
cuenta	movwf	r14
decre2	movlw	0xff
		movwf	r13
decre1	decfsz	r13,r
		goto 	decre1
		decfsz	r14,r
		goto 	decre2
		retlw	0
;----------------------------------------------------
Delay255	movlw	0xff		;delay 255 mS
		goto	d0
Delay100	movlw	d'100'		;delay 100mS
		goto	d0
Delay50		movlw	d'50'		;delay 50mS
		goto	d0
Delay20		movlw	d'20'		;delay 20mS
		goto	d0
Delay5		movlw	0x05		;delay 5.000 ms (4 MHz clock)
d0		movwf	count1
d1		movlw	0xC7			;delay 1mS
		movwf	counta
		movlw	0x01
		movwf	countb
Delay_0
		decfsz	counta, f
		goto	$+2
		decfsz	countb, f
		goto	Delay_0

		decfsz	count1	,f
		goto	d1
		retlw	0x00
;-------------------------------------------------------------------
LCD_Cmd	;movwf	templcd
		;swapf	templcd,	w	;send upper nibble
		;andlw	0x0f			;clear upper 4 bits of W
		movwf	ptob
		bcf		ptoa, rs	;RS line to 0
		call	Pulse_e			;Pulse the E line high

		;movf	templcd,	w	;send lower nibble
		;andlw	0x0f			;clear upper 4 bits of W
		;movwf	LCD_PORT
		;bcf		LCD_PORT, LCD_RS	;RS line to 0
		;call	Pulse_e			;Pulse the E line high
		call 	Delay5
		retlw	0x00
LCD_CharD	addlw	0x30
LCD_Char	;movwf	templcd
		;swapf	templcd,	w	;send upper nibble
		;andlw	0x0f			;clear upper 4 bits of W
		movwf	ptob
		bsf		ptoa,rs	;RS line to 1
		call	Pulse_e			;Pulse the E line high

		;movf	templcd,	w	;send lower nibble
		;andlw	0x0f			;clear upper 4 bits of W
		;movwf	LCD_PORT
		;bsf	LCD_PORT, LCD_RS	;RS line to 1
		;call	Pulse_e			;Pulse the E line high
		call 	Delay5
		retlw	0x00

Pulse_e	bsf		ptoa, e
		nop
		bcf		ptoa, e
		retlw	0x00

;end of LCD routines
		
control	bcf		ptoa,rs
		goto	dato2
dato	bsf		ptoa,rs
dato2	movwf	ptob
		bsf		ptoa,e
		;call	retardo
		bcf		ptoa,e
		;call	retardo
		retlw	0
		
tabla2	addwf	pc,r
		retlw	"H"
		retlw	"o"
		retlw	"l"
		retlw	"a"
		retlw	" "
		retlw	"E"
		retlw	"s"
		retlw	"t"
		retlw	"o"
		retlw	" "
		retlw	"e"
		retlw	"s"
		retlw	" "
		retlw	"u"
		retlw	"n"
		retlw	"a"
		retlw	" "
		retlw	"P"
		retlw	"r"
		retlw	"u"
		retlw	"e"
		retlw	"v"
		retlw	"a"
		retlw	" "
		retlw	" "
		retlw	" "
		retlw	" "
		retlw	" "
		retlw	" "
		retlw	" "
		retlw	" "
		retlw	" "
		retlw	" "
		retlw	" "
		retlw	" "
		retlw	" "
		retlw	" "
		retlw	"0"

		
inicio	bsf		status,rp0
		movlw	0x00
		movwf	ptoa
		movwf	ptob
		bcf		status,rp0
		clrf	ptoa
		clrf	ptob
begin	call 	Delay100
		movlw	38h			;inicia display a 8bits 
		call 	LCD_Cmd
		call 	Delay5	
		movlw	38h			;inicia display a 8bits 
		call 	LCD_Cmd
		;call 	ret100u
		movlw 	38h			;selecciona modo desplazamiento
		call 	LCD_Cmd
		movlw	0ch			;activa display
		call 	LCD_Cmd
		movlw	01h			;
		call 	LCD_Cmd
		call 	Delay5
muestra	movlw	0			;inicia el envio de caracteres
		movwf	r0c			;al modulo
ciclo	movf	r0c,w		;hace barrido de la tabla
		call 	tabla2
		call	LCD_Char
		movlw	09fh		;retardo entre caracteres
		movwf	r0d
reta1	call	retardo
		call 	retardo
		decfsz	r0d,r
		goto	reta1
		incf	r0c,r		;sigue con el proximo carcater del mensaje
		movlw	17h
		xorwf	r0c,w		;pregunta si termino el mensaje para volver
		btfss	status,z	;a empezar
		goto 	ciclo
		goto 	muestra
		end
				