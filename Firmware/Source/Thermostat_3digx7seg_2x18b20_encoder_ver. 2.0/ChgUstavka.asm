;================================================================
; ПП Отображения и изменения уставок
;================================================================
ShowUstavka:
	rcall	LoadUstavka
	rcall	DecodeNum7Seg
	ldi		Zl,low(3000)
	ldi		Zh,high(3000)
	sts		once_timer,Zl
	sts		once_timer+1,Zh
	sbr		flags,(1<<show_ust_flag)
	ret

IncUstavka:
	rcall	LoadUstavka
	rcall	LoadMaxUstavka
	cp		tempreg,tempreg1
	brge	ShowUstavka
	inc		tempreg
	rcall	SaveUstavka
	rjmp	ShowUstavka

DecUstavka:
	rcall	LoadUstavka
	rcall	LoadMinUstavka
	cp		tempreg1,tempreg
	brge	ShowUstavka
	dec		tempreg
	rcall	SaveUstavka
	rjmp	ShowUstavka

SaveUstavka:
	sbr		flags,(1<<save_ustavka_1)
	sbrs	set_mode,sm_on
	sts		ustavka_1,tempreg
	sbrc	set_mode,mode_0
	sts		ustavka_1+1,tempreg
	sbrc	set_mode,mode_1
	sts		hister_1,tempreg
	sbrc	set_mode,mode_2
	sts		ustavka_0,tempreg
	sbrc	set_mode,mode_3
	sts		hister_0,tempreg
	ret

LoadUstavka:
	sbrs	set_mode,sm_on
	lds		tempreg,ustavka_1
	sbrc	set_mode,mode_0
	lds		tempreg,ustavka_1+1
	sbrc	set_mode,mode_1
	lds		tempreg,hister_1
	sbrc	set_mode,mode_2
	lds		tempreg,ustavka_0
	sbrc	set_mode,mode_3
	lds		tempreg,hister_0
	ret

LoadMaxUstavka:
	sbrs	set_mode,sm_on
	lds		tempreg1,ustavka_1+1
	sbrc	set_mode,mode_0
	ldi		tempreg1,45
	sbrc	set_mode,mode_1
	ldi		tempreg1,10
	sbrc	set_mode,mode_2
	ldi		tempreg1,127
	sbrc	set_mode,mode_3
	ldi		tempreg1,20
	ret	

LoadMinUstavka:
	sbrs	set_mode,sm_on
	clr		tempreg1
	sbrc	set_mode,mode_0
	ldi		tempreg1,10
	sbrc	set_mode,mode_1
	ldi		tempreg1,1
	sbrc	set_mode,mode_2
	ldi		tempreg1,40
	sbrc	set_mode,mode_3
	ldi		tempreg1,1
	ret	
