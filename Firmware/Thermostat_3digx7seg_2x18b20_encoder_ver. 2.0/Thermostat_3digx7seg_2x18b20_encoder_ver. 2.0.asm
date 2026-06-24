;++++++++++++++++++++++++++++++++++++++++++++++++++++
; Сегмент данных
;++++++++++++++++++++++++++++++++++++++++++++++++++++
.dseg
	
	.include	"Data.asm"

;++++++++++++++++++++++++++++++++++++++++++++++++++++
; Сегмент EEPROM
;++++++++++++++++++++++++++++++++++++++++++++++++++++
.eseg
	.include	"EEPROM\EEPROM_Data.asm"

;++++++++++++++++++++++++++++++++++++++++++++++++++++
; Сегмент кода
;++++++++++++++++++++++++++++++++++++++++++++++++++++

.cseg
	.include	"Define.asm"
	.include	"Init.asm"

	rjmp	start

	.include	"SoftTimer\SoftTimer.asm"
	.include	"DynIndik\Dyn_Indik.asm"
	.include	"Buttons\ButOpros.asm"
	.include	"Encoder\Encoder.asm"
	.include	"OWI\OneWire.asm"
	.include	"TemperReadCtrl\ReadTemper.asm"
	.include	"TemperReadCtrl\DecodeTemper.asm"
	.include	"TemperReadCtrl\ControlTemper.asm"
	.include	"IndikModes\SensErrorsIndik.asm"
	.include	"IndikModes\SM_Indik.asm"
	.include	"ChgUstavka.asm"
	.include	"EEPROM\EEPROM_R_W.asm"

start:

;++++++++++++++++++++++++++++++++++++++++++++++++++++
; Начало программы
;++++++++++++++++++++++++++++++++++++++++++++++++++++

	cli
	rcall	ee_read_ust					; считываем уставки с EEPROM

	clr		flags
	clr		set_mode							; Очищаем регистр режимов установки

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; инициализация порта 1-Wire
; и установка разрешения датчиков 9 бит
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	rcall	owi_reset
	OWI_DELAY	75						; сколько угодно
	ldi		tempreg,0xCC				; все датчики
	rcall	owi_write_byte				; разрешение - 9 бит
	ldi		tempreg,0x4E
	rcall	owi_write_byte
	ser		tempreg
	rcall	owi_write_byte
	ser		tempreg
	rcall	owi_write_byte
	ldi		tempreg,0x1F
	rcall	owi_write_byte

	rcall	convert_temperature
	rcall	ShowUstavka

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; инициализация таймера считывания температуры
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	ldi		tempreg,temp_read_tmrinit
	sts		temp_read_timer,tempreg

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; инициализация таймеров декодирования температуры
; первое декодирование через 110 мс
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	ldi		tempreg,110
	sts		sens_0_decode_timer,tempreg
	sts		sens_1_decode_timer,tempreg
	clr		tempreg
	sts		sens_1_decode_timer+1,tempreg


;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Программно боремся с косяками от импульсного БП
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	ldi		tempreg, (1<<OCF1A)|(1<<OCF1B)|(1<<TOV1)|(1<<OCF0A)|(1<<OCF0B)|(1<<TOV0)
    out		TIFR, tempreg																; Стираем всё, что таймеры успели натикать за время софт-старта
    
    ldi		tempreg, (1<<INTF1)|(1<<INTF0)|(1<<PCIF)
    out		GIFR, tempreg																; Стираем ложные дребезги от кнопок/энкодера и помехи БП

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Запускаем прерывания
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	sei

;++++++++++++++++++++++++++++++++++++++++++++++++++++
; Главный цикл
;++++++++++++++++++++++++++++++++++++++++++++++++++++

main:
	sbrc	set_mode,sm_on
	rjmp	start_set_mode
	rcall	ENC_opros
	sbrc	flags,ButOpros_flag
	rcall	ButOpros
	sbrc	flags,read_temp_flag
	rcall	read_temperature
	sbrc	flags,sens_0_decode_flag
	rcall	save_temperature_0
	sbrc	flags,sens_1_decode_flag
	rcall	save_temperature_1
	sbrc	flags,save_ustavka_1
	rcall	SaveUstEEPROM
	tst		errors
	breq	pc+2
	rjmp	SensErrorsIndik
	rjmp	main
;++++++++++++++++++++++++++++++++++++++++++++++++++++
; Начало работы режима установки
;++++++++++++++++++++++++++++++++++++++++++++++++++++

start_set_mode:

	LOAD_OFF

	ldi		tempreg,10
	sts		ustavka_1,tempreg					; Уставка температуры на внешнем датчике - 10 градусов
	
	clr		flags
	ldi		set_mode,(1<<sm_on|1<<mode_0)

	ldi		tempreg,(1<<Seg_G)
	sts		indik,tempreg
	sts		indik+1,tempreg
	sts		indik+2,tempreg



	sbis	BUT_PIN,BUTTON						; Ждем, когда будет отпущена кнопка
	rjmp	pc-1

;++++++++++++++++++++++++++++++++++++++++++++++++++++
; Главный цикл режима установки
;++++++++++++++++++++++++++++++++++++++++++++++++++++
main_set_mode:
	sbrs	set_mode,sm_on
	rjmp	return_to_main
	rcall	ENC_opros
	sbrc	flags,ButOpros_flag
	rcall	ButOpros
	sbrc	flags,sens_0_decode_flag
	rcall	SM_Indikation
	rjmp	main_set_mode

return_to_main:

	ldi		tempreg,(1<<Seg_A|1<<Seg_D)			; Заставка
	sts		indik,tempreg
	sts		indik+1,tempreg
	sts		indik+2,tempreg
	
	sbis	BUT_PIN,BUTTON						; Ждем, когда будет отпущена кнопка
	rjmp	pc-1
	
	cli
	rcall	ee_write_ust
		
	rjmp	start
