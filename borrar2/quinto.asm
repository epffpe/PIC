			list 	p=16f84a
puertab		equ		0x06
estado		equ		0x03
tmr0_opt	equ		0x01
intcon		equ		0x0B
			org		0
			bsf		estado,5
			movlw	b'11010110
			movwf	tmr0_opt
			clrf	puertab
			bcf		estado,5
			clrf	puertab
		
parpa		bsf 	puertab,7
			call 	retardo
			bcf 	puertab,7
			call 	retardo
			goto	parpa
retardo		movlw	0x7A
			movwf	0x0c
retardo2	clrf	tmr0_opt
explora		btfss	tmr0_opt,6
			goto	explora
			decfsz	0x0c
			goto	retardo2
			return 
			end 