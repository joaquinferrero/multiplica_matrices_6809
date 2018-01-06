; ------------------------------------------------------------------------
		.title	MultiplicaciOn de matrices 3x3 - Biblioteca de multiplicación

; ========================================================================
		.module	matmul
		.include "constantes.asm"

		.list	(me)

; ========================================================================
; matmul. v4.
;
; Subrutina de multiplicación de matrices de dimensiones arbitrarias.
;
; Propósito:
;	Se realiza la multiplicación de dos matrices y se devuelve el
;	resultado en una tercera.
;	Se considera que los datos de las matrices son octetos (0<=x<256).
;
; Definiciones:
;	Una matriz es un conjunto de datos, ordenado por
;		filas (primera dimensión), y
;		columnas (segunda dimensión).
;
;	La multiplicación de dos matrices se realiza por cada fila y
;	columna de la primera matriz y de las correspondientes columnas y
;	filas de la segunda matriz. Las dimensiones de la matriz resultado
;	serán el número de filas de la primera matriz y el número de
;	columnas de la segunda matriz.
;
;	Se debe cumplir la condición de que el número de columnas de la
;	primera matriz debe ser igual al número de filas de la segunda
;	matriz:
;
;		Si M1(d2) == M2(d1), entonces M3(d1d2) = M1(d1) * M2(d2)
;
; Argumentos:
;	X: puntero a la primera matriz
;	Y: puntero a la segunda matriz
;	U: puntero al espacio reservado para la matriz resultado
;	A: dimensiones (en BCD) de la primera matriz
;	B: dimensiones (en BCD) de la segunda matriz
;
; Entrada:
;	Ninguna.
;
; Salida:
;	U: apunta al resultado, poblado por D1(M1)*D2(M2) octetos.
;	A: resultado de la ejecución:
;		0: no hubo error en el proceso
;		1: las dimensiones de las matrices no son coherentes
;		2: hubo desbordamiento de octeto en un resultado,
;		   y se paró el proceso
;
; Registros afectados:
;	Ninguno.
;
; Llamada típica:
;	ldx #m1
;	ldy #m2
;	ldu #m3
;	lda #0x63
;	ldb #0x35
;	jsr matmul	; el resultado serán 6*5 octetos a partir de #m3
;			; el registro A almacena el estado del resultado
; ------------------------------------------------------------------------
		.area CODE_MATMUL (PAG)
		.setdp			; activar direccionamiento por DP

; Código -----------------------------------------------------------------
matmul::
		guarda	^/b,x,y,u,dp,cc/; guardamos registros

; Inicializar registro DP
		pshs	d		; guardamos la dimensiones, un momento
		tfr	pc,d		; obtenemos la página en donde estamos
		tfr	a,dp		; la guardamos en el registro DP
		puls	d		; recuperar dimensiones

; Almacenar las dimensiones de las matrices
		pshs	a		; guardamos la dimensiones un momento
		anda	#0x0F		; segunda dimensión de la primera matriz
		sta	*dimM1+1	; guardar
		puls	a		; recuperamos las dimensiones
		.rept	4
		lsra
		.endm
		sta	*dimM1		; guardar

		pshs	b		; lo mismo para la segunda matriz
		andb	#0x0F
		stb	*dimM2+1	; segunda dimensión de la segunda matriz
		puls	b
		.rept	4
		lsrb
		.endm
		stb	*dimM2		; primera dimensión de la segunda matriz

; Almacenar puntero a la segunda matriz
		sty	*ptrM2		; almacén del puntero a segunda matriz

; Comprobación de las dimensiones
		lda	*dimM1+1	; segunda dimensión de la primera matriz
		cmpa	*dimM2		; primera dimensión de la segunda matriz
		beq	matmul_inicio	; sí son iguales

		lda	#1		; Error en las dimensiones
		bra	matmul_salida	; salimos

; Inicializar contadores
matmul_inicio:
		lda	*dimM1		; filas a recorrer
		sta	*rows

; Precálculo de desplazamientos por la matriz

		lda	*dimM2		; diferencias entre filas en primera matriz
		nega
		sta	*difrows
		ldb	*dimM2+1	; diferencias entre columnas en segunda matriz
		mul
		incb
		stb	*difcols

; Bucle por las filas
matmul_filas:
		ldy	*ptrM2		; reposicionamos puntero a segunda matriz
		lda	*dimM2+1	; columnas a recorrer
		sta	*cols

; Bucle por las columnas
matmul_columnas:
		clr	*acumula	; limpiamos acumulador
		clr	*acumula+1

		lda	*dimM2		; dimensión común a las dos matrices
		sta	*c		; inicializar contador

; Bucle del sumatorio de los productos
matmul_dato:
		lda	,x		; leer dato de la fila en primera matriz
		ldb	,y		; leer dato de la columna en segunda matriz

		mul			; multiplicar

		addd	*acumula	; y sumar
		std	*acumula	; al acumulador

		tsta			; comprobar octeto superior
		beq	matmul_sigue	; sí, todo va bien

; Desbordamiento
		lda	#2		; Error, hubo un desborde de octeto
		bra	matmul_salida

; Siguiente elemento
matmul_sigue:
		leax	1,x		; apuntamos a siguiente dato en fila
		lda 	*dimM2+1
		leay	a,y		; apuntamos a siguiente dato en columna

; Fin bucle del sumatorio
		dec	*c		; repetimos
		bne	matmul_dato

; Guardar el resultado
		stb	,u+		; guardar resultado

; Reposicionar punteros a los siguientes datos
		lda	*difrows	; reposicionamos puntero a fila
		leax	a,x
		lda	*difcols	; reposicionamos puntero a columna
		leay	a,y

; Fin bucle de las columnas
		dec	*cols		; siguiente columna
		bne	matmul_columnas	; repetir para todas las columnas

; Reposicionar puntero de las filas
		lda 	*dimM1+1
		leax	a,x		; reposicionamos puntero a siguiente fila

; Fin bucle de las filas
		dec	*rows		; siguiente fila
		bne	matmul_filas	; repetir para todas las filas

; Resultado
		clra			; salida sin errores
		brn	matmul_salida

; Salida
matmul_salida:
		recupera_y_regresa	; recupera registros y regresa

; Variables --------------------------------------------------------------
ptrM2:		.dw	1		; almacén puntero a la segunda matriz
dimM1:		.ds	2		; dimensiones de la primera matriz
dimM2:		.ds	2		; dimensiones de la segunda matriz
acumula:	.ds	2		; acumulador (sumatorio) de los productos
difcols:	.ds	1		; diferencia entre columnas de la segunda matriz
difrows:	.ds	1		; diferencia entre filas de la primera matriz
rows:		.ds	1		; contador para las filas
cols:		.ds	1		; contador para las columnas
c:		.ds	1		; contador para cada elemento de la matriz resultado
; ------------------------------------------------------------------------

		.end	matmul

; ========================================================================


; ========================================================================
; Programa: ejemplo de llamada a la subrutina
; ------------------------------------------------------------------------

; Definiciones -----------------------------------------------------------
; Cálculo automático de las dimensiones de las matrices
DIM1C		.equ	m11-m1
DIM2C		.equ	m21-m2
DIM1F		.equ	(m2-m1)/DIM1C
DIM2F		.equ	(m3-m2)/DIM2C

; Código -----------------------------------------------------------------
matmul_test:	LDX     #m1		; apuntamos a base de las matrices
		LDY     #m2 
		LDU     #m3		; puntero U apunta a matriz resultado

		LDA	#DIM1F*16+DIM1C	; dimensiones (BCD) de la primera matriz
		LDB	#DIM2F*16+DIM2C	; dimensiones (BCD) de la segunda matriz

		JSR	matmul

		exit	0

; Datos ------------------------------------------------------------------
; Matrices
m1:		.db	9,6,3		; matriz primera
m11:		.db	8,5,2
		.db	7,4,1
		.db	10,3,0
		.db	11,2,4
		.db	12,0,7

m2:		.db	1,2,3,4,5	; matriz segunda
m21:		.db	4,5,6,7,8
		.db	7,8,9,10,11

; Variables --------------------------------------------------------------
; Matriz resultado
m3:		.ds	DIM1F*DIM2C	; espacio relleno con ceros

; ------------------------------------------------------------------------

		.end	matmul_test

; ========================================================================
		.nlist

; ========================================================================
; [ Tab=8. UTF-8. ]
; Código para ensamblador ASxxxx <http://shop-pdp.net/ashtml/asxxxx.htm>
; Entorno de ejecución m6809-run <https://github.com/bcd/exec09>
; ========================================================================
