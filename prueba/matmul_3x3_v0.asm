;
; Multiplicación de dos matrices 3x3.
;
; v1.1
;
; Variables:
;	fila,columna	: número de fila y columna que estamos calculando
;	m1,m2		: matrices de entrada, a multiplicar
;	m3		: espacio reservado para el resultado de la multiplicación
;	c		: variable contador
;	acumula		: variable sumador
;
; Proceso:
;	Empezando por la primera fila y columna, recorremos los elementos de las dos matrices.
;	Por cada fila y columna debemos realizar la suma de tres multiplicaciones.
;	La suma la vamos guardando en la variable "acumula". El contador "c" nos sirve para
;	recorrer los tres pares de valores.
;	Los punteros X e Y se utilizan para apuntar a los datos dentro de las dos matrices.
;	Usamos el puntero U para ir guardando el resultado.
;

; Opciones de ensamblado ------------------------------------------------------
	.radix	D			; números en decimal
	.list	(me)			; agregar expansión de las macros

; Definiciones del hardware ---------------------------------------------------
STDOUT	.equ	#0xFF00
EXIT	.equ	#0xFF01
STDIN	.equ	#0xFF02

SWI3	.equ	#0xFFF2
SWI2	.equ	#0xFFF4
FIRQ	.equ	#0xFFF6
IRQ	.equ	#0xFFF8
SWI	.equ	#0xFFFA
NMI	.equ	#0xFFFC
RESET	.equ	#0xFFFE

; Macros ----------------------------------------------------------------------
; Imprimir una cadena de caracteres, terminada en 0
	.macro	imprime direccion
	ldx	#direccion
	jsr	print
	.endm

; Imprimir número pasado como argumento, o el registro A
	.macro	imprime_numero A
	.ifnb	A
	lda	A
	.endif
	jsr	pinta_numero
	.endm

; Imprimir número pasado en un registro
	.macro	imprime_registro R
	tfr	R,a
	imprime_numero
	.endm

; Salir del programa
	.macro	exit estado
	lda	#estado
	sta	EXIT
	.endm

; Programa --------------------------------------------------------------------
	.area	PROGRAMA (ABS)
	.org	0x0100

; Variables -------------------------------------------------------------------
mat1:	.ds	9			; primera matriz
mat2:	.ds	9			; segunda matriz
mat3:	.ds	9			; matriz resultado

; Lectura de matrices ---------------------------------------------------------
;
; Registros:
;	X: puntero a cadenas de caracteres a sacar en pantalla
;	Y: contador de matrices
;	U: apuntador a contenidos de las matrices
;	B: contador de filas
;	A: varias cosas
;
programa::
	imprime	msg_saluda		; mensaje de bienvenida

	ldy	#1			; contador de matrices
	ldu	#mat1			; puntero principal

pide_matriz:
	imprime msg_pide_matriz		; "Matriz "
	tfr	y,d
	imprime_registro b		; número de matriz
	imprime	msg_dospuntos
	imprime	msg_crlf

	ldb	#1			; bucle para pedir datos de las filas

pide_fila:
	imprime	msg_pide_fila		; "Fila "
	imprime_registro b		; número de fila
	imprime	msg_dospuntos

	jsr	lee_linea
	cmpa	#3			; ¿hemos leído 3 números?
	beq	sigue_fila

	; ERROR: hay que retroceder el puntero.
	; mejor si lo hacemos de otra manera.
	; reordenar la misión de cada registro.
	; Usar variables, que no pasa nada.

	imprime	msg_error1
	imprime_numero
	imprime msg_error2
	bra	pide_fila

sigue_fila:	
	imprime	msg_crlf
	
	pshs	b,y
	leay	-3,u
	ldb	#3

xxx:	lda	,y+
	imprime_numero
	lda	#' 
	sta	STDOUT
	decb
	bne	xxx
	imprime	msg_crlf
	puls	b,y
	
	incb				; siguiente fila
	cmpb	#3			; ¿hemos pedido 3?
	bls	pide_fila		; no, repite para el resto de filas

	imprime	msg_crlf
	leay	1,y			; siguiente matriz
	cmpy	#2			; ¿hemos pedido 2?
	bls	pide_matriz		; no, repite para la siguiente matriz

	imprime msg_resultado
	imprime_numero #186

	exit	0

; Mensajes  -------------------------------------------------------------------
msg_saluda:
	.ascii	"\nMultiplicaci"
	.db	0xc3,0xb3
	.ascii	"n de dos matrices 3x3.\n\n"
	.ascii	"Introduzca los datos de las matrices, por filas.\n"
	.asciz	"(valores separados por comas o espacios)\n\n"

msg_error1:
	.db	7
	.asciz	"\nERROR: se leyeron "
msg_error2:
	.asciz	" datos. Vuelva a intentarlo\n"
msg_resultado:
	.asciz	"Resultado:\n"

msg_pide_matriz:
	.asciz	"Matriz "

msg_pide_fila:
	.asciz	"\tFila "

msg_dospuntos:
	.asciz	": "

msg_crlf:
	.asciz	"\n"			; son dos caracteres: CR y LF

; Subrutinas ------------------------------------------------------------------
;==============================================================================
; Lee una fila de 3 datos numéricos por la entrada estándar
;
; Argumentos:
;	U: puntero a la zona donde guardar los datos
;
; Devuelve:
;	A: número de datos numéricos leídos
;
; Registros modificados:
;	A, U
;
; Registros:
; A: tecla pulsada
; B: acumulador del último número leído
; U: puntero a zona almacén
; Y: contador de dígitos del número
;
lee_linea:
	pshs	b,y

	clr	ll_nnum			; inicializar contador de números leídos

ll_bucle_dato:
	ldy	#0			; número de dígitos por número
	clr	ll_acc			; poner a 0 el acumulador

ll_bucle_numero:
	lda	STDIN			; leer del teclado

	cmpa	#'\n
	beq	ll_fin			; ¿se metió un Enter?
	cmpa	#'\r
	bne	ll_digitos		; no, ver si es un dígito

ll_fin:					; pulsado Enter
	lda	#-1
	bra	ll_calc0		; guardar el último número, y salir

ll_digitos:
	cmpa	#'0
	blo	ll_calc0		; ¿menor que '0'?
	cmpa	#'9			; ¿menor o igual a 9?
	bls	ll_calc			; sí, tratar como dígito

ll_calc0:				; encontrado un separado o Enter
	cmpy	#0			; ¿leímos algún dígito antes?
	beq	ll_fin2			; no, ver si hay que salir

	ldb	ll_acc			; leer el acumulador
	stb	,u+			; y almacenar
	inc	ll_nnum			; sumamos un dato leído

ll_fin2:
	cmpa	#-1			; ¿se pulso Enter?
	bne	ll_bucle_dato		; no, seguimos leyendo caracteres

ll_rts:					; sí, salimos
	lda	ll_nnum			; numeros leídos

	puls	b,y,pc			; salir

ll_calc:
	pshs	a
	lda	#10			; acumulador *= 10
	ldb	ll_acc
	mul
	stb	ll_acc			; suponemos siempre que < 256
	puls	a

	suba	#'0			; pasar a binario
	adda	ll_acc			; acumulador += dígito
	sta	ll_acc

	leay	1,y			; dígitos leídos += 1

	bra	ll_bucle_numero		; sigue leyendo dígitos

ll_acc:
	.ds 1				; acumulador por dato
ll_nnum:
	.ds 1				; número de datos numéricos leídos

;==============================================================================
; Imprimir una línea de texto terminada en 0
;
; Argumentos:
;	X: puntero a la cadena a imprimir
;
; Devuelve:
;	Nada. Sólo saca información hacia la salida estándar
;
; Registros modificados:
;	Ninguno
;
print:
	pshs	a,x			; guardamos registros que vamos a usar
print_bucle:
	lda	,x+			; leemos carácter
	beq	print_fin		; si es 0, terminamos
	sta	STDOUT			; salida del carácter
	bra	print_bucle		; y repetimos
print_fin:
	puls	a,x,pc			; recuperar registros y regresar

;==============================================================================
; Imprimir un número (0 a 255)
;
; Argumentos:
;	A: valor a pintar en pantalla
;
; Registros modificados:
;	Ninguno
;
pinta_numero:
	pshs	a,b,x
	ldx	#2			; número de vueltas
	clr	pn_divs			; bandera de ceros por delante

pn_divide:
	clrb

pn_bucle:
	cmpa	pn_divs,x		; si el número es menor que el divisor
	blo	pn_digito		; ir a pintar el dígito

	incb
	suba	pn_divs,x
	bra	pn_bucle

pn_digito:
	tstb				; control de los ceros delanteros (no cuentan)
	bne	pn_si2			; el número es > 0, activar bandera y pintar
	tst	pn_divs			; ¿hemos pasado los ceros delanteros?
	bne	pn_si0			; sí, ir a puntar número
	bra	pn_si1			; no, no pintar nada

pn_si2:
	inc	pn_divs			; hemos pasado los ceros delanteros

pn_si0:
	addb	#'0			; pasar a ascii
	stb	STDOUT			; salida a pantalla

pn_si1:
	leax	-1,x			; siguiente divisor
	bne	pn_divide		; repetir, aún no hemos terminado

	adda	#'0			; pasar unidades a ascii
	sta	STDOUT			; salida de las unidades, que faltaban

	puls	a,b,x,pc

pn_divs:
	.ds	1
	.db	10,100

; Ajuste del vector de reset --------------------------------------------------
        .org	RESET
        .word	programa

; -----------------------------------------------------------------------------

;	.end
