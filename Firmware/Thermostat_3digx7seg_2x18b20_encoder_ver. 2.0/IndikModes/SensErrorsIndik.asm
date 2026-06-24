;================================================================
; ПП отображения в режиме ошибки датчиков
;================================================================
SensErrorsIndik:

	LOAD_OFF

	ldi		tempreg,(1<<Seg_A|1<<Seg_D|1<<Seg_E|1<<Seg_F|1<<Seg_G)
	sts		indik+2,tempreg
	ldi		tempreg,(1<<Seg_E|1<<Seg_G)
	sts		indik+1,tempreg

SensErrorsTest:
	cpi		errors,1
	brne	pc+2
	ldi		tempreg,(1<<Seg_B|1<<Seg_C)

	cpi		errors,2
	brne	pc+2
	ldi		tempreg,(1<<Seg_A|1<<Seg_B|1<<Seg_D|1<<Seg_E|1<<Seg_G)

	cpi		errors,3
	brne	pc+2
	ldi		tempreg,(1<<Seg_A|1<<Seg_B|1<<Seg_C|1<<Seg_D|1<<Seg_G)

	sts		indik,tempreg

	sbrc	flags,read_temp_flag
	rcall	read_temperature

	tst		errors
	breq	pc+2

	rjmp	SensErrorsTest
	
	rjmp	start


