			list p=16f84
			Radix Hex
puertaa		equ		0x05
puertab		equ		0x06
estado		equ		0x03
w			equ		0

			ORG		0
			bsf		estado, 5
			movlw	0xff
			movwf	puertaa
			movlw	0x00
			movwf	puertab
			bcf		estado, 5
inicio		movf	puertaa,w
			addlw	2
			movwf	puertab
			goto	inicio
			end