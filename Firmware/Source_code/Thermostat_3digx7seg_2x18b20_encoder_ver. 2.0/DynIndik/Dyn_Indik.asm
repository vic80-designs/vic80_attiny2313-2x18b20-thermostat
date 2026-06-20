;================================================================
; ПП динамической индикации (Для работы нужны tempreg, tempreg1, Z)
;================================================================

DynIndik:
	push	tempreg
	push	tempreg1
	push	Zl
	push	Zh
	in		Zl,SREG
	push	Zl

	in		tempreg,ComPort
#ifdef		COM_AN
	sbr		tempreg,(1<<Com_0|1<<Com_1|1<<Com_2)
#else
	cbr		tempreg,(1<<Com_0|1<<Com_1|1<<Com_2)
#endif
	out		ComPort,tempreg

	lds		tempreg,indikCounter

	clr		Zh

	ldi		Zl,low(indik)
	add		Zl,tempreg
	ld		tempreg1,Z
#ifdef		COM_AN
	com		tempreg1
#endif
	out		SegPort,tempreg1

	ldi		Zl,low(switch_com)
	add		Zl,tempreg

	inc		tempreg
	cpi		tempreg,3
	brlo	pc+2
	clr		tempreg
	sts		indikCounter,tempreg

	ijmp

switch_com:
	rjmp	turn_on_com_0
	rjmp	turn_on_com_1
	rjmp	turn_on_com_2

turn_on_com_0:
#ifdef		COM_AN
	cbi		ComPort,Com_0
#else
	sbi		ComPort,Com_0
#endif
	rjmp	End_DynIndik

turn_on_com_1:
#ifdef		COM_AN
	cbi		ComPort,Com_1
#else
	sbi		ComPort,Com_1
#endif
	rjmp	End_DynIndik

turn_on_com_2:
#ifdef		COM_AN
	cbi		ComPort,Com_2
#else
	sbi		ComPort,Com_2
#endif
	/*rjmp	End_DynIndik*/

End_DynIndik:
	pop		Zl
	out		SREG,Zl
	pop		Zh
	pop		Zl
	pop		tempreg1
	pop		tempreg
	reti

;================================================================
; ПП декодирования числа для вывода на 7seg
; на входе в tempreg - число 1 байт (со знаком)
;================================================================
DecodeNum7Seg:
	clr		tempreg1					// Гасим все индикаторы						
	sts		indik,tempreg1
	sts		indik+1,tempreg1
	sts		indik+2,tempreg1

	bst		tempreg,7					; Если число неотрицательное
	brtc	pc+2						; То пропускаем инверсию

	neg		tempreg						; Инвертируем

	cpi		tempreg,100					; Это начало декодирования числа
	brlo	pc+2

	rjmp	DecodeHundreds

	cpi		tempreg,10
	brlo	pc+6

	brtc	pc+4
	ldi		tempreg1,(1<<Seg_G)			; Зажигаем минус на третьем знакоместе
	sts		indik+2,tempreg1
	rjmp	DecodeTens

	brtc	pc+4
	ldi		tempreg1,(1<<Seg_G)			; Зажигаем минус на втором знакоместе
	sts		indik+1,tempreg1
	rjmp	DecodeOnes


DecodeHundreds:							; Пересчет сотен
	ldi		Zh,high(matrix*2)
	ldi		Zl,low(matrix*2)
	adiw	Z,1
	lpm		tempreg1,Z
	subi	tempreg,100

	sts		indik+2,tempreg1

DecodeTens:
	ldi		Zh,high(matrix*2)
	ldi		Zl,low(matrix*2)

	subi	tempreg,10					; Пересчет десятков
	brcs	pc+3
	adiw	Z,1
	rjmp	pc-3						; Зацикливаем пересчет десятков

	subi	tempreg,(-10)

	lpm		tempreg1,Z
	sts		indik+1,tempreg1

DecodeOnes:
	ldi		Zh,high(matrix*2)				; Пересчет единиц
	ldi		Zl,low(matrix*2)

	add		Zl,tempreg
	clr		tempreg
	adc		Zh,tempreg
	lpm		tempreg,Z					;загружаем в R0 декодированное число
	sts		indik,tempreg

	ret

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; матрица кодов индикатора
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
matrix:
	.db		(1<<Seg_A)|(1<<Seg_B)|(1<<Seg_C)|(1<<Seg_D)|(1<<Seg_E)|(1<<Seg_F),\					; '0' - 0
			(1<<Seg_B)|(1<<Seg_C),\																; '1' - 1
			(1<<Seg_A)|(1<<Seg_B)|(1<<Seg_D)|(1<<Seg_E)|(1<<Seg_G),\							; '2' - 2
			(1<<Seg_A)|(1<<Seg_B)|(1<<Seg_C)|(1<<Seg_D)|(1<<Seg_G),\							; '3' - 3
			(1<<Seg_B)|(1<<Seg_C)|(1<<Seg_F)|(1<<Seg_G),\										; '4' - 4
			(1<<Seg_A)|(1<<Seg_C)|(1<<Seg_D)|(1<<Seg_F)|(1<<Seg_G),\							; '5' - 5
			(1<<Seg_A)|(1<<Seg_C)|(1<<Seg_D)|(1<<Seg_E)|(1<<Seg_F)|(1<<Seg_G),\					; '6' - 6
			(1<<Seg_A)|(1<<Seg_B)|(1<<Seg_C),\													; '7' - 7
			(1<<Seg_A)|(1<<Seg_B)|(1<<Seg_C)|(1<<Seg_D)|(1<<Seg_E)|(1<<Seg_F)|(1<<Seg_G),\		; '8' - 8
			(1<<Seg_A)|(1<<Seg_B)|(1<<Seg_C)|(1<<Seg_D)|(1<<Seg_F)|(1<<Seg_G)					; '9' - 9
	/*		(1<<Seg_A)|(1<<Seg_B)|(1<<Seg_C)|(1<<Seg_E)|(1<<Seg_F)|(1<<Seg_G),\					; 'A' - 10
			(1<<Seg_C)|(1<<Seg_D)|(1<<Seg_E)|(1<<Seg_F)|(1<<Seg_G),\							; 'B' - 11
			(1<<Seg_A)|(1<<Seg_D)|(1<<Seg_E)|(1<<Seg_F),\										; 'C' - 12
			(1<<Seg_B)|(1<<Seg_C)|(1<<Seg_D)|(1<<Seg_E)|(1<<Seg_G),\							; 'D' - 13
			(1<<Seg_A)|(1<<Seg_D)|(1<<Seg_E)|(1<<Seg_F)|(1<<Seg_G),\							; 'E' - 14
			(1<<Seg_A)|(1<<Seg_E)|(1<<Seg_F)|(1<<Seg_G),\										; 'F' - 15
			0x00,\																				; ' ' - 16
			(1<<Seg_B)|(1<<Seg_C)|(1<<Seg_E)|(1<<Seg_F)|(1<<Seg_G),\							; 'H' - 17
			(1<<Seg_B)|(1<<Seg_C)|(1<<Seg_D)|(1<<Seg_E),\										; 'J' - 18
			(1<<Seg_D)|(1<<Seg_E)|(1<<Seg_F),\													; 'L' - 19
			(1<<Seg_A)|(1<<Seg_B)|(1<<Seg_E)|(1<<Seg_F)|(1<<Seg_G),\							; 'P' - 20
			(1<<Seg_B)|(1<<Seg_C)|(1<<Seg_D)|(1<<Seg_E)|(1<<Seg_F),\							; 'U' - 21
			(1<<Seg_D)|(1<<Seg_E)|(1<<Seg_G),\													; 'c' - 22
			(1<<Seg_C)|(1<<Seg_E)|(1<<Seg_F)|(1<<Seg_G),\										; 'h' - 23
			(1<<Seg_C)|(1<<Seg_E)|(1<<Seg_G),\													; 'n' - 24
			(1<<Seg_C)|(1<<Seg_D)|(1<<Seg_E)|(1<<Seg_G),\										; 'o' - 25
			(1<<Seg_A)|(1<<Seg_B)|(1<<Seg_C)|(1<<Seg_F)|(1<<Seg_G),\							; 'q' - 26
			(1<<Seg_E)|(1<<Seg_G),\																; 'r' - 27
			(1<<Seg_D)|(1<<Seg_E)|(1<<Seg_F)|(1<<Seg_G),\										; 't' - 28
			(1<<Seg_C)|(1<<Seg_D)|(1<<Seg_E),\													; 'u' - 29
			(1<<Seg_A)|(1<<Seg_F)|(1<<Seg_E),\													; 'Г' - 30
			(1<<Seg_A)|(1<<Seg_B)|(1<<Seg_C)|(1<<Seg_E)|(1<<Seg_F),\							; 'П' - 31
			(1<<Seg_B)|(1<<Seg_C)|(1<<Seg_D)|(1<<Seg_F)|(1<<Seg_G),\							; 'У' - 32
			(1<<Seg_G)																			; '-' - 33*/


/*	push	tempreg
	push	tempreg1
	in		tempreg,SREG
	push	tempreg
	push	Zh
	push	Zl

	sbrc	flags,all_com_off_ind
	rjmp	LightIndik
	sbr		flags,(1<<all_com_off_ind)

	all_com_off

	rjmp	EndDynIndik

LightIndik:

	sbis	BUT_DATE_PIN,BUT_DATE				// Чтобы не моргало изменяемое значение когда нажата кнопка DATE
	rjmp	end_test_blinking

	sbrs	indik_coms,blink_right
	rjmp	tst_blink_left

	cbr		indik_coms,(1<<com_0_flag|1<<com_1_flag)
	sbrc	flags,migalka
	sbr		indik_coms,(1<<com_0_flag|1<<com_1_flag)

tst_blink_left:

	sbrs	indik_coms,blink_left
	rjmp	end_test_blinking

	cbr		indik_coms,(1<<com_2_flag|1<<com_3_flag)
	sbrc	flags,migalka
	sbr		indik_coms,(1<<com_2_flag|1<<com_3_flag)

	
	sbrs	mode,mod_1_0						// Проверка при установке часов если часов < 10 левая не должна зажигаться
	rjmp	end_test_blinking

	lds		tempreg,ds1307_data+2
	cbr		tempreg,0x0F
	tst		tempreg
	brne	end_test_blinking
	cbr		indik_coms,(1<<com_3_flag)

end_test_blinking:

	cbr		flags,(1<<all_com_off_ind)

	lds		tempreg,indikCounter
	push	tempreg
	inc		tempreg
	cpi		tempreg,6
	brlo	save_indikCounter
	clr		tempreg

save_indikCounter:
	sts		indikCounter,tempreg
	pop		tempreg
	ldi		Zl,low(switch_com)
	ldi		Zh,high(switch_com)
	add		Zl,tempreg
	clr		tempreg
	adc		Zh,tempreg

	cbi		dec_port,dec_A
	cbi		dec_port,dec_B
	cbi		dec_port,dec_C
	cbi		dec_port,dec_D

	ijmp

switch_com:
	rjmp	turn_on_com_0
	rjmp	turn_on_com_1
	rjmp	turn_on_com_2
	rjmp	turn_on_com_3
	rjmp	turn_on_com_4
	rjmp	turn_on_com_5

turn_on_com_0:
	in		tempreg,dec_port
	lds		tempreg1,indik
	or		tempreg,tempreg1
	out		dec_port,tempreg
	sbrc	indik_coms,com_0_flag
	com_0_on
	rjmp	EndDynIndik

turn_on_com_1:
	in		tempreg,dec_port
	lds		tempreg1,indik+1
	or		tempreg,tempreg1
	out		dec_port,tempreg
	sbrc	indik_coms,com_1_flag
	com_1_on
	rjmp	EndDynIndik

turn_on_com_2:
	in		tempreg,dec_port
	lds		tempreg1,indik+2
	or		tempreg,tempreg1
	out		dec_port,tempreg
	sbrc	indik_coms,com_2_flag
	com_2_on
	rjmp	EndDynIndik

turn_on_com_3:
	in		tempreg,dec_port
	lds		tempreg1,indik+3
	or		tempreg,tempreg1
	out		dec_port,tempreg
	sbrc	indik_coms,com_3_flag
	com_3_on
	rjmp	EndDynIndik

turn_on_com_4:
	sbrc	indik_coms,spot_dwn_flag
	spot_dwn_on
	rjmp	EndDynIndik

turn_on_com_5:
	sbrc	indik_coms,spot_up_flag
	spot_up_on
	rjmp	EndDynIndik

EndDynIndik:
	pop		Zl
	pop		Zh
	pop		tempreg
	out		SREG,tempreg
	pop		tempreg1
	pop		tempreg*/
	reti
