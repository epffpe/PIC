		list p=16f84a
w		equ		0
f		equ		1
tmr_opt	equ		0x01
estado 	equ		0x03
puertaa	equ		0x05
puertab	equ		0x06
intcon	equ		0x0b
conta 	equ		0x10
		org 	0
		goto	inicio
		org		4
		goto	inter
		org 5
inicio	bsf		estado,5
		clrf	puertab
		movlw	b'00000011'
		movwf	puertaa
		movlw	b'00000111'
		movwf	tmr_opt
		bcf		estado,5
		movlw	b'10100000'	;interrupc tmr0 y GIE
		movwf	intcon
		movlw	0x10
		movwf	conta
		movlw	0x0c
		movwf	tmr_opt
bucle	btfsc	puertaa,0
		goto 	ra0_1
		bcf		puertab,0
		goto 	ra1x
ra0_1	bsf		puertab,0
ra1x	btfsc	puertaa,1
		goto 	ra1_1
		bcf		puertab,1
		goto	bucle2
ra1_1	bsf		puertab,1
bucle2	goto	bucle

inter	decfsz	conta,1
		goto	seguir
conta_0	movlw	0x10
		movwf	conta
		btfsc	puertab,7
		goto 	rb7_1
		bsf		puertab,7
		goto	seguir
rb7_1	bcf		puertab,7
seguir	movlw	b'10100000'
		movwf	intcon
		movlw	0x0c
		movwf	tmr_opt
		retfie
		end