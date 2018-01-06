		.module Programa
		.include "constantes.asm"

		.list (!,err,loc,bin,eqt,cyc,lin,src,md,me)

		.area	_CODE (REL,CON)

; Código -----------------------------------------------------------------
programa::

; Bienvenida
		pinta	msg_saluda	; Mensaje de bienvenida

; Leer matrices
		ldu	#mat1		; primera matriz
		ldb	#1

		ldu	#mat2		; segunda matriz
		ldb	#2


		tfr	a,b		; copia

		bra	.

; Datos ------------------------------------------------------------------
msg_saluda:	.asciz	"\n=== Multiplication"

; Variables --------------------------------------------------------------
mat1:		.ds	DIM*DIM		; primera matriz
mat2:		.ds	DIM*DIM		; segunda matriz

; ------------------------------------------------------------------------
print::		rts
print_numero::	rts

		.end	programa

; ========================================================================
		.nlist

; ========================================================================
; [ Tab=8. UTF-8. ]
; Código para ensamblador ASxxxx <http://shop-pdp.net/ashtml/asxxxx.htm>
; Entorno de ejecución m6809-run <https://github.com/bcd/exec09>
; ========================================================================
