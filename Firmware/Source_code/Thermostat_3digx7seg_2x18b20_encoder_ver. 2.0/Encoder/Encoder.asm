;================================================================
; ПП опроса энкодера
;================================================================
ENC_opros:
	clr		tempreg
	sbis	ENC_PIN,ENC_A
	sbr		tempreg,(1<<0)
	sbis	ENC_PIN,ENC_B
	sbr		tempreg,(1<<1)

	lds		tempreg1,ENCOld

	cp		tempreg,tempreg1
	breq	exit_ENC_opros

ENC_test_00:
	tst		tempreg1
	brne	ENC_test_01
	sts		ENCCounter,tempreg1			; если старое == 0, то сбрасывем счетчик
	cpi		tempreg,0b01				; если новое = 01
	breq	ENC_count_dec				; то счетчик --
	cpi		tempreg,0b10				; если новое = 10
	breq	ENC_count_inc				; то счетчик ++
	rjmp	ENC_count_reset

ENC_test_01:
	cpi		tempreg1,0b01
	brne	ENC_test_11
	cpi		tempreg,0b11				; если новое = 11
	breq	ENC_count_dec				; то счетчик --
	tst		tempreg						; если новое = 00
	breq	ENC_count_inc				; то счетчик ++
	rjmp	ENC_count_reset

ENC_test_11:
	cpi		tempreg1,0b11
	brne	ENC_test_10
	cpi		tempreg,0b10				; если новое = 10
	breq	ENC_count_dec				; то счетчик --
	cpi		tempreg,0b01				; если новое = 01
	breq	ENC_count_inc				; то счетчик ++
	rjmp	ENC_count_reset

ENC_test_10:
	cpi		tempreg1,0b10
	brne	ENC_count_reset
	tst		tempreg						; если новое = 00
	breq	ENC_count_dec				; то счетчик --
	cpi		tempreg,0b11				; если новое = 11
	breq	ENC_count_inc				; то счетчик ++
ENC_count_reset:
	clr		tempreg1
	sts		ENCCounter,tempreg1

exit_ENC_opros:
	sts		ENCOld,tempreg
	ret

ENC_count_inc:
	lds		tempreg1,ENCCounter
	inc		tempreg1
	sts		ENCCounter,tempreg1
	rjmp	ENC_count_test

ENC_count_dec:
	lds		tempreg1,ENCCounter
	dec		tempreg1
	sts		ENCCounter,tempreg1

ENC_count_test:
	tst		tempreg						; если новое <> 00
	brne	exit_ENC_opros				; то выход с сохранением нового в старое
	cpi		tempreg1,4					; если счетчик == 4
	breq	ENC_right					; то вращение на один щелчок вправо
	cpi		tempreg1,-4					; если счетчик == -4
	breq	ENC_left					; то вращение на один щелчок влево
	rjmp	exit_ENC_opros

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Реакция на вращение энкодера вправо
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ENC_right:
	
	rcall	IncUstavka
	rjmp	exit_ENC_opros

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Реакция на вращение энкодера влево
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ENC_left:

	rcall	DecUstavka
	rjmp	exit_ENC_opros
