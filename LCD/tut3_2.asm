;LCD 16 bit counter
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

        		NumL			;Binary inputs for decimal convert routine
	        	NumH	

        		TenK			;Decimal outputs from convert routine
	        	Thou	
        		Hund	
	        	Tens	
        		Ones	
		endc

LCD_PORT	Equ	PORTA
LCD_TRIS	Equ	TRISA
LCD_RS		Equ	0x04			;LCD handshake lines
LCD_RW		Equ	0x06
LCD_E		Equ	0x07

		org	0x0000

		movlw	0x07
		movwf	CMCON			;turn comparators off (make it like a 16F84)

Initialise	clrf	count
		clrf	PORTA
		clrf	PORTB
		clrf	NumL
		clrf	NumH



SetPorts	bsf 	STATUS,		RP0	;select bank 1
		movlw	0x00			;make all pins outputs
		movwf	LCD_TRIS
		bcf 	STATUS,		RP0	;select bank 0

		call	LCD_Init		;setup LCD


		clrf	count			;set counter register to zero
Message		movf	count, w		;put counter value in W
		call	Text			;get a character from the text table
		xorlw	0x00			;is it a zero?
		btfsc	STATUS, Z
		goto	NextMessage
		call	LCD_Char
		incf	count, f
		goto	Message

NextMessage	call	LCD_Line2		;move to 2nd row, first column
	
		call	Convert			;convert to decimal
		movf	TenK,	w		;display decimal characters
		call	LCD_CharD		;using LCD_CharD to convert to ASCII
		movf	Thou,	w
		call	LCD_CharD
		movf	Hund,	w
		call	LCD_CharD		
		movf	Tens,	w
		call	LCD_CharD
		movf	Ones,	w
		call	LCD_CharD
		movlw	' '			;display a 'space'
		call	LCD_Char
		movf	NumH,	w		;and counter in hexadecimal
		call	LCD_HEX
		movf	NumL,	w
		call	LCD_HEX
		incfsz	NumL, 	f
		goto	Next
		incf	NumH,	f
Next		call	Delay255		;wait so you can see the digits change
		goto	NextMessage


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


Text		addwf	PCL, f
		retlw	'1'
		retlw	'6'
		retlw	' '
		retlw	'B'
		retlw	'i'
		retlw	't'
		retlw	' '
		retlw	'C'
		retlw	'o'
		retlw	'u'
		retlw	'n'
		retlw	't'
		retlw	'e'
		retlw	'r'
		retlw	'.'
		retlw	0x00

;This routine downloaded from http://www.piclist.com
Convert:                        ; Takes number in NumH:NumL
                                ; Returns decimal in
                                ; TenK:Thou:Hund:Tens:Ones
        swapf   NumH, w
	iorlw	B'11110000'
        movwf   Thou
        addwf   Thou,f
        addlw   0XE2
        movwf   Hund
        addlw   0X32
        movwf   Ones

        movf    NumH,w
        andlw   0X0F
        addwf   Hund,f
        addwf   Hund,f
        addwf   Ones,f
        addlw   0XE9
        movwf   Tens
        addwf   Tens,f
        addwf   Tens,f

        swapf   NumL,w
        andlw   0X0F
        addwf   Tens,f
        addwf   Ones,f

        rlf     Tens,f
        rlf     Ones,f
        comf    Ones,f
        rlf     Ones,f

        movf    NumL,w
        andlw   0X0F
        addwf   Ones,f
        rlf     Thou,f

        movlw   0X07
        movwf   TenK

                    ; At this point, the original number is
                    ; equal to
                    ; TenK*10000+Thou*1000+Hund*100+Tens*10+Ones
                    ; if those entities are regarded as two's
                    ; complement binary.  To be precise, all of
                    ; them are negative except TenK.  Now the number
                    ; needs to be normalized, but this can all be
                    ; done with simple byte arithmetic.

        movlw   0X0A                             ; Ten
Lb1:
        addwf   Ones,f
        decf    Tens,f
        btfss   3,0
        goto   Lb1
Lb2:
        addwf   Tens,f
        decf    Hund,f
        btfss   3,0
        goto   Lb2
Lb3:
        addwf   Hund,f
        decf    Thou,f
        btfss   3,0
        goto   Lb3
Lb4:
        addwf   Thou,f
        decf    TenK,f
        btfss   3,0
        goto   Lb4

        retlw	0x00


		end