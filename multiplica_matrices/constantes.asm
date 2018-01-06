; -----------------------------------------------------------------------
		.title	MultiplicaciOn de matrices 3x3 - Definiciones

		.nlist

; ========================================================================
; Definiciones y macros globales
;
;    Este archivo es para ser incluído con .include en los archivos que
;    las necesiten.
; -----------------------------------------------------------------------

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
; guarda
;
; Guarda registros en la pila, para luego ser recuperados con la macro
; recupera.
; -----------------------------------------------------------------------
		.macro	guarda R
		.define	REGS ^/R/
		pshs	REGS
		.endm

; -----------------------------------------------------------------------
; recupera
;
; Recupera registros salvados en la pila.
; -----------------------------------------------------------------------
		.macro	recupera
		puls	REGS
		.undefine REGS
		.endm

; -----------------------------------------------------------------------
; recupera_y_regresa
;
; Recupera registros salvados en la pila, incluyendo el PC.
; -----------------------------------------------------------------------
		.macro	recupera_y_regresa
		puls	REGS,pc
		.undefine REGS
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

; ========================================================================
; [ Tab=8. UTF-8. ]
; Código para ensamblador ASxxxx <http://shop-pdp.net/ashtml/asxxxx.htm>
; Entorno de ejecución m6809-run <https://github.com/bcd/exec09>
; ========================================================================

		.list
