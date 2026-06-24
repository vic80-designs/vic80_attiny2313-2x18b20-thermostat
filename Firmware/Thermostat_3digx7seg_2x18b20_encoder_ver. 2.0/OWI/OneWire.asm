;================================================================
; ПП обработки шины 1-Wire
; для работы необходиме временные регистры tempreg, tempreg1
; все процедуры влияют на бит Т
; Работает при частоте процессора:2,4,8,10,12,16 МГЦ
; !!!!!!! В дефайнах задать XTAL (напр. #define XTAL 4000000)
;================================================================
owi_reset:
	clr		errors						; Очищаем ошибки датчиков

	clt
	brid	pc+3
	cli
	set

	OWI_OUT
	OWI_PULLDWN
	OWI_DELAY	110
	OWI_IN
	OWI_DELAY	20
	sbic	OWI_PIN,OWI_BUS_0
	sbr		errors,(1<<mis_sens_0)							; Ошибка - нет датчикa1
	sbic	OWI_PIN,OWI_BUS_1
	sbr		errors,(1<<mis_sens_1)							; Ошибка - нет датчикa2
	OWI_DELAY	30

	brtc	pc+2
	sei

	ret

;================================================================
; Чтение бита с шины 1-wire
;================================================================
owi_read_bit:

	OWI_OUT
	OWI_PULLDWN
	OWI_DELAY	1
	OWI_IN
	OWI_PULLUP
	OWI_DELAY	2

	lds		tempreg,owi_temp
	clc
	sbic	OWI_PIN,OWI_BUS_0
	sec
	ror		tempreg
	sts		owi_temp,tempreg
	
	lds		tempreg,owi_temp+1
	clc
	sbic	OWI_PIN,OWI_BUS_1
	sec
	ror		tempreg
	sts		owi_temp+1,tempreg

	OWI_DELAY	10

	ret

;================================================================
; Чтение байта с шины 1-wire (на выходе - байт с первой шины
; в owi_temp, байт со второй шины в owi_temp+1)
;================================================================
owi_read_byte:
	clt
	brid	pc+3
	cli
	set

	push	tempreg1
	clr		tempreg
	sts		owi_temp,tempreg
	sts		owi_temp+1,tempreg

	ldi		tempreg1,8
cycle_owi_read_byte:
	rcall	owi_read_bit
	dec		tempreg1
	brne	cycle_owi_read_byte
	OWI_OUT
	OWI_PULLUP
	pop		tempreg1

	brtc	pc+2
	sei

	ret

;================================================================
; Запись бита на шину 1-wire
;================================================================
owi_write_bit:
	push	tempreg
	OWI_OUT
	OWI_PULLDWN
	OWI_DELAY	2

	brcc	pc+3					; Пропускаем сл. два шага, если С==1
	sbi		OWI_PORT,OWI_BUS_0
	sbi		OWI_PORT,OWI_BUS_1

	OWI_DELAY	12
	OWI_PULLUP
	OWI_DELAY	2
	pop		tempreg

	ret

;================================================================
; Запись байта на шину 1-wire (на входе - байт
; в регистре tempreg)
;================================================================
owi_write_byte:
	clt
	brid	pc+3
	cli
	set

	push	tempreg1
	ldi		tempreg1,8

cycle_owi_write_byte:
	lsr		tempreg
	rcall	owi_write_bit
	dec		tempreg1
	brne	cycle_owi_write_byte
	OWI_OUT
	OWI_PULLUP
	pop		tempreg1

	brtc	pc+2
	sei

	ret



	owi_delay_cycle:
#if		XTAL==2000000
	ret
#else
	push	tempreg1
	#if		XTAL==4000000
		ldi		tempreg1,2
	#endif
	#if		XTAL==8000000
		ldi		tempreg1,8
	#endif
	#if		XTAL==10000000
		ldi		tempreg1,12
	#endif
	#if		XTAL==12000000
		ldi		tempreg1,15
	#endif
	#if		XTAL==16000000
		ldi		tempreg1,22
	#endif
#endif
wait_delay:
	dec		tempreg1
	brne	wait_delay
	pop		tempreg1
	ret
