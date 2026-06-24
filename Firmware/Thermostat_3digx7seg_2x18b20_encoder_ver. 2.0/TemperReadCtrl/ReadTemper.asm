;================================================================
; ПП считывания температуры с OWI
;================================================================

read_temperature:

	cbr		flags,(1<<read_temp_flag)

	rcall	owi_reset
	OWI_DELAY	75						; сколько угодно
	ldi		tempreg,0xCC				; все датчики
	rcall	owi_write_byte				; считать температуру
	ldi		tempreg,0xBE
	rcall	owi_write_byte

	rcall	owi_read_byte
	lds		Zl,owi_temp
	sts		temperatura_0,Zl
	lds		tempreg,owi_temp+1
	sts		temperatura_1,tempreg

	rcall	owi_read_byte
	lds		Zh,owi_temp
	sts		temperatura_0+1,Zh
	lds		tempreg,owi_temp+1
	sts		temperatura_1+1,tempreg
	
convert_temperature:
	rcall	owi_reset
	OWI_DELAY	75						; сколько угодно
	ldi		tempreg,0xCC				; все датчики
	rcall	owi_write_byte				; начать конвертирование температуры
	ldi		tempreg,0x44
	rcall	owi_write_byte

	ret

save_temperature_0:
	cbr		flags,(1<<sens_0_decode_flag)
	lds		Zl,(temperatura_0)
	lds		Zh,(temperatura_0+1)
	rcall	DecodeTemper
	sts		temp_0_decoded,Zh
	rcall	ControlTemper
	ret

save_temperature_1:
	cbr		flags,(1<<sens_1_decode_flag)
	lds		Zl,(temperatura_1)
	lds		Zh,(temperatura_1+1)
	rcall	DecodeTemper
	sts		temp_1_decoded,Zh
	mov		tempreg,Zh
	sbrs	flags,show_ust_flag
	rcall	DecodeNum7Seg
	rcall	ControlTemper
	ret
