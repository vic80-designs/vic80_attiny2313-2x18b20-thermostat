;================================================================
; Файл инициализации для библиотеки динамической индикации
; 
; АХТУНГ!!! Файл располагать в сегменте кода, в файле инит!!!
;================================================================

	clr		tempreg
	sts		indik,tempreg
	sts		indik+1,tempreg
	sts		indik+2,tempreg

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; инициализация портов индикатора
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	in		tempreg,ComPort
#ifdef		COM_AN
	sbr		tempreg,(1<<Com_0|1<<Com_1|1<<Com_2)
#else
	cbr		tempreg,(1<<Com_0|1<<Com_1|1<<Com_2)
#endif
	out		ComPort,tempreg

	in		tempreg,DirComPort
	sbr		tempreg,(1<<Com_0|1<<Com_1|1<<Com_2)
	out		DirComPort,tempreg

#ifdef		USE_DP
	clr		tempreg
#else
	in		tempreg,SegPort
	cbr		tempreg,(1<<Seg_A|1<<Seg_B|1<<Seg_C|1<<Seg_D|1<<Seg_E|1<<Seg_F|1<<Seg_G)
#endif
	out		SegPort,tempreg

#ifdef		USE_DP
	ser		tempreg
#else
	in		tempreg,DirSegPort
	sbr		tempreg,(1<<Seg_A|1<<Seg_B|1<<Seg_C|1<<Seg_D|1<<Seg_E|1<<Seg_F|1<<Seg_G)
#endif
	out		DirSegPort,tempreg

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Инициализируем таймер динамической индикации
; назначаем TMR0
; тикает раз в XXX мсек
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	ldi		tempreg,124
	out		OCR0A,tempreg
	ldi		tempreg,(0<<WGM02|1<<CS02|0<<CS01|0<<CS00)
	out		TCCR0B,tempreg
	ldi		tempreg,(1<<WGM01|0<<WGM00)
	out		TCCR0A,tempreg

	in		tempreg,TIMSK
	sbr		tempreg,(1<<OCIE0A)
	out		TIMSK,tempreg
