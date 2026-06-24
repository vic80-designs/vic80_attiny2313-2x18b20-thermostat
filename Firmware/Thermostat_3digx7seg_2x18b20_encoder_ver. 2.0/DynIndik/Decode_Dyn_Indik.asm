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