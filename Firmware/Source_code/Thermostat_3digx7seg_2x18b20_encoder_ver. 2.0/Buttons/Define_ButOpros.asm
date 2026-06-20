;================================================================
; Дефайны для библиотеки опроса кнопки
; 
; АХТУНГ!!! Файл располагать в сегменте кода, в файле дефайнов!!!
;================================================================

	#define		BUT_PORT		PORTD
	#define		BUT_PIN			PIND
	#define		BUT_DDR			DDRD
	#define		BUTTON			3

	#define		buttons			r21
	#define		but_btn			0
	#define		autorepeat		1
	#define		autorepeat_1	2

	#define		ButOpros_tmr_init			20
	