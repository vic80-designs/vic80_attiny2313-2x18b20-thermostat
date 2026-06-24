;================================================================
; ПП  контроля темпереатуры
;================================================================
ControlTemper:

	tst		errors
	brne	load_power_off

	lds		tempreg,temp_0_decoded
	lds		tempreg1,ustavka_0

	cp		tempreg,tempreg1
	brge	load_power_off

	lds		Zl,hister_0
	sub		tempreg1,Zl
	inc		tempreg1

	cp		tempreg,tempreg1
	brlt	ControlSens1
	ret

ControlSens1:
	lds		tempreg,temp_1_decoded
	lds		tempreg1,ustavka_1

	cp		tempreg,tempreg1
	brge	load_power_off

	lds		Zl,hister_1
	sub		tempreg1,Zl
	inc		tempreg1

	cp		tempreg,tempreg1
	brlt	load_power_on

	ret

load_power_on:
	LOAD_ON

	ret

load_power_off:
	
	LOAD_OFF

	ret

