;================================================================
; ПП индикации в режиме Set Mode
;================================================================
SM_Indikation:
	cbr		flags,(1<<sens_0_decode_flag)
	
	sbrc	flags,show_ust_flag
	ret

	sbrc	set_mode,mode_0
	ldi		tempreg,(1<<Seg_B|1<<Seg_C)
	sbrc	set_mode,mode_1
	ldi		tempreg,(1<<Seg_A|1<<Seg_B|1<<Seg_D|1<<Seg_E|1<<Seg_G)
	sbrc	set_mode,mode_2
	ldi		tempreg,(1<<Seg_A)|(1<<Seg_B)|(1<<Seg_C)|(1<<Seg_D)|(1<<Seg_G)
	sbrc	set_mode,mode_3
	ldi		tempreg,(1<<Seg_B)|(1<<Seg_C)|(1<<Seg_F)|(1<<Seg_G)

	sts		indik,tempreg
	ldi		tempreg,(1<<Seg_G)
	sts		indik+1,tempreg
	ldi		tempreg,(1<<Seg_A|1<<Seg_B|1<<Seg_C|1<<Seg_E|1<<Seg_F)
	sts		indik+2,tempreg

	ret
