                              1 		.module Programa
                              2 		.include "constantes.asm"
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                         
                             81 		.list
                              3 
                              5 
                              6 		.area	_CODE (REL,CON)
                              7 
                              8 ; Código -----------------------------------------------------------------
   0000                       9 programa::
                             10 
                             11 ; Bienvenida
   0000                      12 		pinta	msg_saluda	; Mensaje de bienvenida
                     0000     1 		.if idn,msg_saluda,^/reg/
                              2 			st STDOUT
                              3 			.mexit
                     0001     4 		.else
                     0000     5 			.if idn,msg_saluda,^/lf/
                              6 				N=1
                              7 				.iifnb ^// N=
                              8 				lda #'\n
                              9 				.rept N
                             10 				sta STDOUT
                             11 				.endm
                             12 				.undefine N
                             13 				.mexit
                     0001    14 			.else
                     0000    15 				.if idn,msg_saluda,^/num/
                             16 					.iifdif ^//,a tfr ,a
                             17 					jsr print_numero
                             18 					.mexit
                     0001    19 				.else
   0000 8E 00 14      [ 3]   20 					ldx #msg_saluda
   0003 BD 00 3A      [ 8]   21 					jsr print
                             22 					.mexit
                             13 
                             14 ; Leer matrices
   0006 CE 00 28      [ 3]   15 		ldu	#mat1		; primera matriz
   0009 C6 01         [ 2]   16 		ldb	#1
                             17 
   000B CE 00 31      [ 3]   18 		ldu	#mat2		; segunda matriz
   000E C6 02         [ 2]   19 		ldb	#2
                             20 
                             21 
   0010 1F 89         [ 6]   22 		tfr	a,b		; copia
                             23 
   0012 20 FE         [ 3]   24 		bra	.
                             25 
                             26 ; Datos ------------------------------------------------------------------
   0014 0A 3D 3D 3D 20 4D    27 msg_saluda:	.asciz	"\n=== Multiplication"
        75 6C 74 69 70 6C
        69 63 61 74 69 6F
        6E 00
                             28 
                             29 ; Variables --------------------------------------------------------------
   0028                      30 mat1:		.ds	DIM*DIM		; primera matriz
   0031                      31 mat2:		.ds	DIM*DIM		; segunda matriz
                             32 
                             33 ; ------------------------------------------------------------------------
   003A 39            [ 5]   34 print::		rts
   003B 39            [ 5]   35 print_numero::	rts
                             36 
                     0000    37 		.end	programa
                             38 
                             39 ; ========================================================================
