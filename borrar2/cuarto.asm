		list p=16f84a
puertaa	equ		0x05
puertab	equ		0x06
estado	equ		0x03
suma	equ		0x0c
w		equ		0
f		equ		1
conta	equ		0x0c

		org		0
		goto	inicio
		org 	5
inicio	bsf		estado,5
		movlw	0x00
		movwf	puertab
		bcf		estado,5

		clrf	conta
bucle1	incf	conta,f
		movf	conta,w
		movwf	puertab
		movlw	0x5f
		subwf	conta,w
		btfss	estado,2
		goto	bucle1
bucle2	goto	bucle2
		end
