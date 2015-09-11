		list p=16f84a
puertaa	equ		0x05
puertab	equ		0x06
estado	equ		0x03
suma	equ		0x0c
w		equ		0
		org		0
		bsf		estado,5
		movlw	0x0f
		movwf	puertaa
		movlw	0x0f
		movwf	puertab
		bcf		estado,5
inicio	movf	puertaa,w
		andlw	0x0f
		movwf	suma
		movf	puertab,w
		andlw	0x0f
		addwf	suma,1
		goto	inicio
		end
		