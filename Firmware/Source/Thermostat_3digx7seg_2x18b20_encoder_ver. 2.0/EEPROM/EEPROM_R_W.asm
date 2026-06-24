;================================================================
; ПП считывания и записи уставок в EEPROM
;================================================================

SaveUstEEPROM:
	sbrc	flags,show_ust_flag
	ret
	cbr		flags,(1<<save_ustavka_1)		; очищаем флаг сохранения уставки внешнего датчика
	cli
	rcall	ee_write_ust
	sei
	ret

ee_read_ust:
	ldi		Zl,low(ustavka_0)
	ldi		Yl,low(ee_ustavka_0)
	ldi		tempreg1,5
ee_wait_to_read:						; читаем ROM из EEPROM
	sbic 	EECR,EEPE					; Ждем пока будет завершена прошлая запись.
	rjmp	ee_wait_to_read				; также крутимся в цикле.
	out 	EEARl,Yl					; загружаем адрес нужной ячейки
	sbi 	EECR,EERE 					; Выставляем бит чтения
	in		tempreg,EEDR 				; Забираем из регистра данных результат
	st		Z+,tempreg					; сохраняем в уставках
	adiw	Y,1							; прибавляем 1 к адресу EEPROM
	dec		tempreg1
	brne	ee_wait_to_read
	ret


ee_write_ust:
	ldi		Zl,low(ustavka_0)
	ldi		Yl,low(ee_ustavka_0)
	ldi		tempreg1,5
ee_wait_to_write:							; Записываем в EEPROM уставки температуры
	sbic	EECR,EEPE
	rjmp	ee_wait_to_write
	out		EEARl,Yl
	ld		tempreg,Z+
	out		EEDR,tempreg
	sbi 	EECR,EEMWE						; взводим предохранитель
	sbi 	EECR,EEWE						; записываем байт
	adiw	Y,1
	dec		tempreg1
	brne	ee_wait_to_write
	ret
