;================================================================
; ПП опроса кнопки
;================================================================

ButOpros:

	cbr		flags,(1<<ButOpros_flag)
	sbis	BUT_PIN,BUTTON	
	rjmp	But_pressed
	clr		buttons			
	sts		But_LongPress+1,buttons			; Очищаем таймер автоповтора
	sts		But_LongPress,buttons

	ret

But_pressed:
	sbrc	buttons,but_btn
	rjmp	start_auto_repeat

	sbr		buttons,(1<<but_btn)

;---------------------------------------------	
; Здесь начинается обработка нажатия

	sbrs	buttons,autorepeat_1
	rjmp	But_pressed_once				// Переход на обработку однократного нажатия

;---------------------------------------------	
; Длительное удержание
	ldi		tempreg,(1<<sm_on)
	eor		set_mode,tempreg

	ret

But_pressed_once:
	sbrc	set_mode,sm_on
	rjmp	But_pressed_once_set_mode

	lds		tempreg,ustavka_1
	rcall	ShowUstavka

	ret

But_pressed_once_set_mode:
	cbr		flags,(1<<show_ust_flag)
	sbrc	set_mode,mode_0
	ldi		tempreg,(1<<mode_1|1<<sm_on)
	sbrc	set_mode,mode_1
	ldi		tempreg,(1<<mode_2|1<<sm_on)
	sbrc	set_mode,mode_2
	ldi		tempreg,(1<<mode_3|1<<sm_on)
	sbrc	set_mode,mode_3
	ldi		tempreg,(1<<mode_0|1<<sm_on)

	mov		set_mode,tempreg

	ret

start_auto_repeat:
	sbrc	buttons,autorepeat
	ret

	sbr		buttons,(1<<autorepeat)
	ldi		tempreg,low(3000)
	ldi		tempreg1,high(3000)

set_autorepeat_timer:
	sts		But_LongPress,tempreg
	sts		But_LongPress+1,tempreg1
	ret

