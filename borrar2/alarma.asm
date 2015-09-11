 		list 	p=16f84a
		radix	hex
w		equ	0
f		equ	1
estado	equ	0x03
puertaa	equ	0x05
puertab	equ	0x06
intcon	equ	0x0B

		org		0
		goto	inicio
		
		org		4
		goto	inter

		org		5
inicio	bsf		estado,5
		clrf	puertaa
		movlw	0xff
		movwf	puertab
		bcf		estado,5

		clrf	puertaa
		clrf	puertab

		movlw	b'10011000'
		movwf	intcon
bucle	goto	bucle

inter	btfss	intcon,0	;flag de int por cambio de RB4 RB7
		goto 	parar
alarma	clrf	puertab
		movlw	b'10011000'
		movwf	intcon
buzzer	bsf		puertaa,0
		nop
		bcf		puertaa,0
		bsf		puertaa,1
		nop
		bcf		puertaa,1
		goto	buzzer

parar	clrf	puertaa
		bcf		puertab,0
		movlw	b'10011000'
		movwf	intcon
		goto	bucle
		end
		