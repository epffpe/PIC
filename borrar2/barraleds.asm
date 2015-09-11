			list p=16f84
pc			equ 02h
status		equ	03h
ptoa		equ	05h
ptob		equ	06h
trisa		equ	85h
trisb		equ 86h
w			equ 00h
reset		org		0
			goto	inicio
			org		5
inicio		bsf		status,5
			movlw	0f0h
			movwf	trisa
			movlw	0ffh
			movwf	trisb
			bcf		status,5		
ciclo		movf	ptob,w
			xorlw	0ffh
			movwf	ptoa
			goto	ciclo
			end