; ------------------------------------------------------------------------
		.title	MultiplicaciOn de matrices 3x3 - Programa principal

; ========================================================================
		.module Programa
		.include "constantes.asm"

		.list (!,err,loc,bin,eqt,cyc,lin,src,md,me,meb)

;err	errors
;loc	program location
;bin	binary output
;eqt	symbol or .if evaluation
;cyc	opcode cycle count
;lin	source line number
;src	source line text
;pag	pagination
;lst	.list/.nlist line listing
;md	macro definition listing
;me	macro expansion listing
;meb	macro expansion binary listing

; ========================================================================
; Ajuste del vector de reset (puntero a inicio del ejecutable)
; ------------------------------------------------------------------------
		.area	CODE_RESET (ABS,OVR,CSEG)

; Variables globales -----------------------------------------------------
		.globl	programa

; Código -----------------------------------------------------------------
		.org	VecRESET

vec_reset::
		.dw	programa

		.end	vec_reset

; ========================================================================


; ========================================================================
; Programa principal
;
;	Presentación y solicitud de datos al usuario.
;	Lectura de los datos de las dos matrices.
;	Multiplicación de las mismas, llamando a biblioteca externa.
;	Salida del estado del resultado (todo correcto o error)
;	En caso de obtener resultado correcto, presentarlo
;
; Parámetros de entrada:
;	No aplicable.
;
; Entrada:
;	Lectura de las matrices por la entrada estándar.
;
; Salida:
;	Resultado de la multiplicación, por la salida estándar.
;
; Registros afectados:
;	A,B,D: para todo lo demás
;	X: puntero para imprimir textos
;	U: puntero a las zonas de las matrices
; ------------------------------------------------------------------------
		.area	_CODE (REL,CON)

; Definiciones -----------------------------------------------------------
PINTADORAPIDO	.equ	0	; 0/1: Control del momento de la salida

; Variables globales -----------------------------------------------------
		.globl	matmul

; Código -----------------------------------------------------------------
programa::

; Bienvenida
		pinta	msg_saluda	; Mensaje de bienvenida

; Leer matrices
		ldu	#mat1		; primera matriz
		ldb	#1
		jsr	leer_matriz
		.iif	ne,PINTADORAPIDO,jsr	pintar_matriz

		ldu	#mat2		; segunda matriz
		ldb	#2
		jsr	leer_matriz
		.iif	ne,PINTADORAPIDO,jsr	pintar_matriz

; Multiplicar
		lda	#DIM*16+DIM	; dimensiones de las matrices
		ldb	#DIM*16+DIM	; en formato BCD
		ldx	#mat1		; matrices
		ldy	#mat2
		ldu	#mat3
		jsr	matmul		; multiplica

		tfr	a,b		; copia
		ldx	#msg_estado_ptrs; puntero a los mensajes de estado
		lslb			; estado *= 2 (tamaño de un .word)
		leax	[b,x]		; según el estado devuelto
		jsr	print		; a pantalla
		tsta			; si no hubo error,
		beq	1$		; presentamos resultado y salimos

		exit	1		; salir con informe de error

; Mostrar resultado
1$:
		.ifeq	PINTADORAPIDO
		ldu	#mat1		; primera matriz
		jsr	pintar_matriz

		pinta	lf
		lda	#'*
		pinta	reg a
		pinta	lf 2

		ldu	#mat2		; segunda matriz
		jsr	pintar_matriz

		pinta	lf
		lda	#'=
		pinta	reg a
		pinta	lf 2
		.endif
		
		ldu	#mat3		; matriz resultado
		jsr	pintar_matriz

; Salir
		exit	0		; todo correcto

; Datos ------------------------------------------------------------------
msg_saluda:	.ascii	"\n=== Multiplicaci"
		.db	0xc3,0xb3
		.ascii	"n de dos matrices "
		.db	DIM+'0
		.ascii	"x"
		.db	DIM+'0
		.ascii	" ===\n"
		.asciz	"Introduzca los datos de las matrices por filas\n"
msg_estado_ptrs:.dw	msg_estado_mul0
		.dw	msg_estado_mul1
		.dw	msg_estado_mul2
msg_estado_mul0:.asciz	"\nResultado:\n"
msg_estado_mul1:.asciz	"\nERROR: Las dimensiones no son coherentes\n"
msg_estado_mul2:.asciz	"\nERROR: Desbordamiento de octeto en el proceso\n"

; Variables --------------------------------------------------------------
mat1:		.ds	DIM*DIM		; primera matriz
mat2:		.ds	DIM*DIM		; segunda matriz
mat3:		.ds	DIM*DIM		; matriz resultado

; ------------------------------------------------------------------------

		.end	programa

; ========================================================================


; ========================================================================
; Leer una matriz
;
;	Se realiza un bucle por todas las filas de la matriz.
;	En cada vuelta, se solicitan los datos de esa fila.
;	Se esperan DIM datos numéricos, separados por caracteres que no
;	sean dígitos.
;
; Argumentos:
;	B: número de matriz a pedir
;	U: puntero donde dejar los datos (almacén de la matriz)
;
; Entrada:
;	Ninguna.
;
; Salida:
;	Ninguna.
;	Los datos leídos por la entrada estándar, quedan en el almacén.
;
; Registros usados:
;	A: dato leído
;	B: contador para las filas
;	X: contador para los datos dentro de una fila/pintar texto
;	Y: puntero donde se recojen los datos desde leer_fila
;
; Registros modificados:
;	Ninguno.
; ------------------------------------------------------------------------
		.area	_CODE (REL,CON)

; Definiciones -----------------------------------------------------------
DEBUG_leer	.equ	0		; 0/1: verificar lo leído

; Variables globales -----------------------------------------------------
		.globl	leer_fila

; Código -----------------------------------------------------------------
leer_matriz::
		guarda	^/a,b,x,y,u,cc/	; guarda registros

; Muestra aviso
		pinta	msg_pide_matriz
		pinta	num b
		pinta	msg_dospuntos
		pinta	lf

; Bucle para las filas
		ldb	#1		; bucle de filas de la matriz
1$:
		pinta	msg_pide_fila
		pinta	num b
		pinta	msg_dospuntos

		ldy	#bufer_fila	; sitio donde dejar los números
		jsr	leer_fila	; leer

		.ifne	DEBUG_leer
		pinta	msg_leido	; informar
		.endif

; Bucle para los datos de una fila
		ldx	#DIM		; copiar los valores
2$:
		lda	,y+		; leer dato leído
		sta	,u+		; guardar en matriz

		.ifne	DEBUG_leer
		pinta	num a		; sacar a pantalla
		lda	#' 		; con un espacio de separador
		pinta	reg a
		.endif

		leax	-1,x		; y repetir
		bne	2$

; Fin bucle para los datos
		pinta	lf

		incb			; siguiente fila
		cmpb	#DIM		; ¿ya hemos pedido todas?
		bls	1$		; no, repite

; Fin bucle para las filas
		recupera_y_regresa	; recuperar registros y regresar

; Mensajes  --------------------------------------------------------------
msg_pide_matriz:.asciz	"\nMatriz "
msg_pide_fila:	.asciz	"\tFila "
msg_dospuntos:	.asciz	": "
		.ifne	DEBUG_leer
msg_leido:	.asciz	"\n\tLeido: "
		.endif

; Variables --------------------------------------------------------------
bufer_fila:	.ds	DIM

; ------------------------------------------------------------------------

		.end	leer_matriz

; ========================================================================


; ========================================================================
; Pintar una matriz
;
;	Se presentan los datos de una matriz, formateados, en la salida
;	estándar.
;
; Argumentos:
;	U: puntero a la matriz a pintar
;
; Entrada:
;	Ninguna.
;
; Salida:
;	Una matriz con valores, formateados en anchura (rellenos de
;	espacios) y delimitadores.
;
; Registros usados:
;	A: pintar caracteres extra
;	B: dato a pintar
;	X: contador para las columnas
;	Y: contador para las filas
;
; Registros modificados:
;	Ninguno.
; ------------------------------------------------------------------------
		.area	_CODE (REL,CON)

; Código -----------------------------------------------------------------
pintar_matriz:
		guarda	^/a,b,x,y,u,cc/	; guarda registros

; Primera línea, decorativa
		pinta	msg_matriz_deco

; Bucle por las filas
		ldy	#DIM		; pintar filas
0$:
		lda	#'|
		pinta	reg a
		lda	#' 
		pinta	reg a

; Bucle por las columnas
		ldx	#DIM		; pintar columnas
1$:
		ldb	,u+		; leer dato

; Centenas
		cmpb	#100		; ¿es menor que 100?
		bhs	2$		; sí
		
		lda	#' 
		pinta	reg a

; Decenas
2$:
		cmpb	#10		; ¿es menor que 10?
		bhs	3$		; sí
		
		lda	#' 
		pinta	reg a

; Unidades
3$:
		pinta	num b		; por fin lo pintamos
				
		lda	#' 
		pinta	reg a		; un separador más

		leax	-1,x
		bne	1$		; repite para toda las columnas

; Fin bucle de las columnas

		lda	#'|
		pinta	reg a
		pinta	lf

		leay	-1,y
		bne	0$		; repite para todas las filas

; Fin bucle de las filas
		pinta	msg_matriz_deco

		recupera_y_regresa	; recuperar registros y regresar

; Datos ------------------------------------------------------------------
msg_matriz_deco:.asciz	"+             +\n"

; ------------------------------------------------------------------------

		.end	pintar_matriz

		.end
; ========================================================================
		.nlist

; ========================================================================
; [ Tab=8. UTF-8. ]
; Código para ensamblador ASxxxx <http://shop-pdp.net/ashtml/asxxxx.htm>
; Entorno de ejecución m6809-run <https://github.com/bcd/exec09>
; ========================================================================
