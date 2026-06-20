;================================================================
; Дефайны для библиотеки OneWire
; 
; АХТУНГ!!! Файл располагать в сегменте кода, в файле дефайнов!!!
;================================================================

	#define		OWI_DDR			DDRA
	#define		OWI_PORT		PORTA
	#define		OWI_PIN			PINA
	#define		OWI_BUS_0		1
	#define		OWI_BUS_1		0

	#define		owi_bus_reg			r10			; номер шины OWI

;----------------------------------------------------------------
; Макрокоманды 1-Wire
;----------------------------------------------------------------
.MACRO		OWI_OUT
	sbi		OWI_DDR,OWI_BUS_0
	sbi		OWI_DDR,OWI_BUS_1
.ENDM
.MACRO		OWI_IN
	cbi		OWI_DDR,OWI_BUS_0
	cbi		OWI_DDR,OWI_BUS_1
.ENDM
.MACRO		OWI_PULLUP
	sbi		OWI_PORT,OWI_BUS_0
	sbi		OWI_PORT,OWI_BUS_1
.ENDM
.MACRO		OWI_PULLDWN
	cbi		OWI_PORT,OWI_BUS_0
	cbi		OWI_PORT,OWI_BUS_1
.ENDM
.MACRO		OWI_DELAY
	ldi		tempreg,@0
cont_delay:
	rcall	owi_delay_cycle
	dec		tempreg
	brne	cont_delay
.ENDM

