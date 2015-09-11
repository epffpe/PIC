pc		equ 		0x02
status	equ			0x03
ptoa	equ			0x05
ptob	equ			0x06
trisa	equ			0x05
trisb	equ			0x06
w		equ			0x00
RP0		equ			5

reset	org			0
		goto		inicio
					
		org			5
inicio	bsf			status,RP0
		movlw		00h
		movwf		trisa
		movlw		0xff
        movwf		trisb
        bcf			status,RP0

ciclo	movf		ptob,w
		xorlw		0xff
		movwf		ptoa
		goto		ciclo
		END