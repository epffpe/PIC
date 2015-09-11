;LCD and keys
;Nigel Goodwin 2002

	LIST	p=16F628		;tell assembler what chip we are using
	include "P16F628.inc"		;include the defaults for the chip
	ERRORLEVEL	0,	-302	;suppress bank selection messages
	__config 0x3D18			;sets the configuration settings (oscillator type etc.)




		cblock	0x20			;start of general purpose registers
			count			;used in looping routines
			count1			;used in delay routine
			counta			;used in delay routine
			countb			;used in delay routine
			tmp1			;temporary storage
			tmp2
			templcd			;temp store for 4 bit mode
			templcd2
			flags
        		menupos			;menu level	
		endc

LCD_PORT	Equ	PORTA
LCD_TRIS	Equ	TRISA
LCD_RS		Equ	0x04			;LCD handshake lines
LCD_RW		Equ	0x06
LCD_E		Equ	0x07

SWPORT		Equ	PORTB			;set constant SWPORT = 'PORTB'
LEDPORT		Equ	PORTB
SWTRIS		Equ	TRISB			;set constant for TRIS register
SW1		Equ	7			;set constants for the switches
SW2		Equ	6
SW3		Equ	5
SW4		Equ	4
LED1		Equ	3			;and for the LED's
LED2		Equ	2
LED3		Equ	1
LED4		Equ	0

change		Equ	0

SWDel		Set	Delay50			;set the de-bounce delay (has to use 'Set' and not 'Equ')

		org	0x0000
		goto	Start

HEX_Table  	ADDWF   PCL       , f
            	RETLW   0x30
            	RETLW   0x31
            	RETLW   0x32
            	RETLW   0x33
            	RETLW   0x34
            	RETLW   0x35
            	RETLW   0x36
            	RETLW   0x37
            	RETLW   0x38
            	RETLW   0x39
            	RETLW   0x41
            	RETLW   0x42
            	RETLW   0x43
            	RETLW   0x44
            	RETLW   0x45
            	RETLW   0x46

Menu		addwf	PCL, f
		retlw	'P'
		retlw	'r'
		retlw	'e'
		retlw	's'
		retlw	's'
		retlw	' '
		retlw	'm'
		retlw	'e'
		retlw	'n'
		retlw	'u'
		retlw	'.'
		retlw	0x00


Menu1		addwf	PCL, f
		retlw	'M'
		retlw	'e'
		retlw	'n'
		retlw	'u'
		retlw	' '
		retlw	'1'
		retlw	0x00

Menu2		addwf	PCL, f
		retlw	'M'
		retlw	'e'
		retlw	'n'
		retlw	'u'
		retlw	' '
		retlw	'2'
		retlw	0x00

Menu3		addwf	PCL, f
		retlw	'M'
		retlw	'e'
		retlw	'n'
		retlw	'u'
		retlw	' '
		retlw	'3'
		retlw	0x00

Menu4		addwf	PCL, f
		retlw	'M'
		retlw	'e'
		retlw	'n'
		retlw	'u'
		retlw	' '
		retlw	'4'
		retlw	0x00

Menu5		addwf	PCL, f
		retlw	'M'
		retlw	'e'
		retlw	'n'
		retlw	'u'
		retlw	' '
		retlw	'5'
		retlw	0x00

Menu6		addwf	PCL, f
		retlw	'M'
		retlw	'e'
		retlw	'n'
		retlw	'u'
		retlw	' '
		retlw	'6'
		retlw	0x00


Start		movlw	0x07
		movwf	CMCON			;turn comparators off (make it like a 16F84)

Initialise	clrf	count
		clrf	PORTA
		clrf	PORTB
		clrf	menupos
		clrf	flags


SetPorts	bsf 	STATUS,		RP0	;select bank 1
		movlw	0x00			;make all pins outputs
		movwf	LCD_TRIS
		movlw	0xf0
		movwf	SWTRIS
		bcf 	STATUS,		RP0	;select bank 0

		call	LCD_Init		;setup LCD

		call	MainText

Loop		btfss	SWPORT,	SW1
		call	Switch1
		btfss	SWPORT,	SW2
		call	Switch2
		btfss	SWPORT,	SW3
		call	Switch3
		btfss	SWPORT,	SW4
		call	Switch4
		btfss	flags,	change
		goto	Loop
		movf	menupos,	w
		xorlw	0x01			;is it a zero?
		btfsc	STATUS, Z
		call	MainText
		movf	menupos,	w
		xorlw	0x02			;is it a two?
		btfsc	STATUS, Z
		call	DoMenu1
		goto	Loop

MainText	call	LCD_Clr
		clrf	count			;set counter register to zero
Message		movf	count, w		;put counter value in W
		call	Menu			;get a character from the text table
		xorlw	0x00			;is it a zero?
		btfsc	STATUS, Z
		goto	EndMess
		call	LCD_Char
		incf	count, f
		goto	Message
EndMess		bcf	flags,	change
		retlw	0x00

DoMenu1		call	LCD_Clr
		clrf	count			;set counter register to zero
Message1	movf	count, w		;put counter value in W
		call	Menu1			;get a character from the text table
		xorlw	0x00			;is it a zero?
		btfsc	STATUS, Z
		goto	Mess1
		call	LCD_Char
		incf	count, f
		goto	Message1
Mess1		call	LCD_Line2
		clrf	count			;set counter register to zero
Message2	movf	count, w		;put counter value in W
		call	Menu2			;get a character from the text table
		xorlw	0x00			;is it a zero?
		btfsc	STATUS, Z
		goto	EndMess2
		call	LCD_Char
		incf	count, f
		goto	Message2
EndMess2	bcf	flags,	change
		retlw	0x00

Switch1		call	SWDel			;give switch time to stop bouncing
		btfsc	SWPORT,	SW1		;check it's still pressed
		retlw	0x00			;return is not
		btfss	SWPORT,	LED1		;see if LED1 is already lit
		goto	LED1ON
		goto	LED1OFF

LED1ON		bsf	LEDPORT,	LED1	;turn LED1 on
		movlw	0x02
		movwf	menupos
		bsf	flags,	change
		call	SWDel
		btfsc	SWPORT,	SW1		;wait until button is released
		retlw	0x00
		goto	LED1ON	

LED1OFF		bcf	LEDPORT,	LED1	;turn LED1 on
		movlw	0x01
		movwf	menupos
		bsf	flags,	change
		call	SWDel
		btfsc	SWPORT,	SW1		;wait until button is released
		retlw	0x00
		goto	LED1OFF		

Switch2		call	SWDel			;give switch time to stop bouncing
		btfsc	SWPORT,	SW2		;check it's still pressed
		retlw	0x00			;return is not
		btfss	SWPORT,	LED2		;see if LED2 is already lit
		goto	LED2ON
		goto	LED2OFF

LED2ON		bsf	LEDPORT,	LED2	;turn LED2 on
		call	SWDel
		btfsc	SWPORT,	SW2		;wait until button is released
		retlw	0x00
		goto	LED2ON	

LED2OFF		bcf	LEDPORT,	LED2	;turn LED2 on
		call	SWDel
		btfsc	SWPORT,	SW2		;wait until button is released
		retlw	0x00
		goto	LED2OFF

Switch3		call	SWDel			;give switch time to stop bouncing
		btfsc	SWPORT,	SW3		;check it's still pressed
		retlw	0x00			;return is not
		btfss	SWPORT,	LED3		;see if LED3 is already lit
		goto	LED3ON
		goto	LED3OFF

LED3ON		bsf	LEDPORT,	LED3	;turn LED3 on
		call	SWDel
		btfsc	SWPORT,	SW3		;wait until button is released
		retlw	0x00
		goto	LED3ON	

LED3OFF		bcf	LEDPORT,	LED3	;turn LED3 on
		call	SWDel
		btfsc	SWPORT,	SW3		;wait until button is released
		retlw	0x00
		goto	LED3OFF

Switch4		call	SWDel			;give switch time to stop bouncing
		btfsc	SWPORT,	SW4		;check it's still pressed
		retlw	0x00			;return is not
		btfss	SWPORT,	LED4		;see if LED4 is already lit
		goto	LED4ON
		goto	LED4OFF

LED4ON		bsf	LEDPORT,	LED4	;turn LED4 on
		call	SWDel
		btfsc	SWPORT,	SW4		;wait until button is released
		retlw	0x00
		goto	LED4ON	

LED4OFF		bcf	LEDPORT,	LED4	;turn LED4 on
		call	SWDel
		btfsc	SWPORT,	SW4		;wait until button is released
		retlw	0x00
		goto	LED4OFF



;Subroutines and text tables

;LCD routines

;Initialise LCD
LCD_Init	call	Delay100		;wait for LCD to settle

		movlw	0x20			;Set 4 bit mode
		call	LCD_Cmd

		movlw	0x28			;Set display shift
		call	LCD_Cmd

		movlw	0x06			;Set display character mode
		call	LCD_Cmd

		movlw	0x0c			;Set display on/off and cursor command
		call	LCD_Cmd			;Set cursor off

		call	LCD_Clr			;clear display

		retlw	0x00

; command set routine
LCD_Cmd		movwf	templcd
		swapf	templcd,	w	;send upper nibble
		andlw	0x0f			;clear upper 4 bits of W
		movwf	LCD_PORT
		bcf	LCD_PORT, LCD_RS	;RS line to 1
		call	Pulse_e			;Pulse the E line high

		movf	templcd,	w	;send lower nibble
		andlw	0x0f			;clear upper 4 bits of W
		movwf	LCD_PORT
		bcf	LCD_PORT, LCD_RS	;RS line to 1
		call	Pulse_e			;Pulse the E line high
		call 	Delay5
		retlw	0x00

LCD_CharD	addlw	0x30			;add 0x30 to convert to ASCII
LCD_Char	movwf	templcd
		swapf	templcd,	w	;send upper nibble
		andlw	0x0f			;clear upper 4 bits of W
		movwf	LCD_PORT
		bsf	LCD_PORT, LCD_RS	;RS line to 1
		call	Pulse_e			;Pulse the E line high

		movf	templcd,	w	;send lower nibble
		andlw	0x0f			;clear upper 4 bits of W
		movwf	LCD_PORT
		bsf	LCD_PORT, LCD_RS	;RS line to 1
		call	Pulse_e			;Pulse the E line high
		call 	Delay5
		retlw	0x00

LCD_Line1	movlw	0x80			;move to 1st row, first column
		call	LCD_Cmd
		retlw	0x00

LCD_Line2	movlw	0xc0			;move to 2nd row, first column
		call	LCD_Cmd
		retlw	0x00

LCD_Line1W	addlw	0x80			;move to 1st row, column W
		call	LCD_Cmd
		retlw	0x00

LCD_Line2W	addlw	0xc0			;move to 2nd row, column W
		call	LCD_Cmd
		retlw	0x00


LCD_CurOn	movlw	0x0d			;Set display on/off and cursor command
		call	LCD_Cmd
		retlw	0x00

LCD_CurOff	movlw	0x0c			;Set display on/off and cursor command
		call	LCD_Cmd
		retlw	0x00

LCD_Clr		movlw	0x01			;Clear display
		call	LCD_Cmd
		retlw	0x00

LCD_HEX		movwf	tmp1
		swapf	tmp1,	w
		andlw	0x0f
		call	HEX_Table
		call	LCD_Char
		movf	tmp1, w
		andlw	0x0f
		call	HEX_Table
		call	LCD_Char
		retlw	0x00

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

Pulse_e		bsf	LCD_PORT, LCD_E
		nop
		bcf	LCD_PORT, LCD_E
		retlw	0x00

;end of LCD routines


		end