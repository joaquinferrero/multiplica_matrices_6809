		.nlist

; Constantes -------------------------------------------------------------
DIM		.equ	3

; Símbolos globales ------------------------------------------------------
		.globl	print
		.globl	print_numero

; Definiciones del hardware ----------------------------------------------
STDIN		.equ	#0xFF02
STDOUT		.equ	#0xFF00
EXIT_OS		.equ	#0xFF01

VecSWI3		.equ	#0xFFF2
VecSWI2		.equ	#0xFFF4
VecFIRQ		.equ	#0xFFF6
VecIRQ		.equ	#0xFFF8
VecSWI		.equ	#0xFFFA
VecNMI		.equ	#0xFFFC
VecRESET	.equ	#0xFFFE

; Macros -----------------------------------------------------------------
; pinta
;
; 'reg': Imprimir el contenido del registro A o B
;
; 'num': Imprimir el número contenido en el registro A o B
;	Se modifica el registro A
;
; 'lf': Imprimir el carácter de nueva línea, un número de veces (1 por defecto)
;	Se modifica el registro A
;
; dirección absoluta: Imprimir una cadena de caracteres, terminada en 0
;	La cadena está apuntada por el registro X
;
; Ejemplos:
;	pinta	reg a		; Imprime el carácter almacenado en A
;	pinta	num b		; Imprime registro B (su valor numérico)
;	pinta	lf 2		; Imprime dos caracteres \n (uno, por defecto)
;	pinta	msg_pide_matriz	; Imprime una cadena
; -----------------------------------------------------------------------
		.macro	pinta	arg1 arg2
		.if idn,arg1,^/reg/
			st'arg2 STDOUT
			.mexit
		.else
			.if idn,arg1,^/lf/
				N=1
				.iifnb ^/arg2/ N=arg2
				lda #'\n
				.rept N
				sta STDOUT
				.endm
				.undefine N
				.mexit
			.else
				.if idn,arg1,^/num/
					.iifdif ^/arg2/,a tfr arg2,a
					jsr print_numero
					.mexit
				.else
					ldx #arg1
					jsr print
					.mexit
				.endif
			.endif
		.endif
		.endm

; -----------------------------------------------------------------------
; exit
;
; Salir al sistema, devolviendo un valor de estado.
; -----------------------------------------------------------------------
		.macro	exit estado
		lda	#estado
		sta	EXIT_OS
		.endm

		.list
