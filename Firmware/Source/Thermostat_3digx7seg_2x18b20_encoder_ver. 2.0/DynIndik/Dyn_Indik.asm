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

	reti
