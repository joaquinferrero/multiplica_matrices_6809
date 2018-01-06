; ------------------------------------------------------------------------
		.title	MultiplicaciOn de matrices 3x3 - Bibliotecas I/O
		.sbttl	ImpresiOn de un nUmero

; ========================================================================
		.module	IO_print_numero
		.include "constantes.asm"

		.list	(me)

; ========================================================================
; print_numero
;
;	Salida por pantalla del número almacenado en el registro A.
;
;	El proceso se realiza contando las centenas y las decenas por
;	medio de substracciones sucesivas.
;	Usamos una bandera para evitar la salida de los '0' a la
;	izquierda.
;
; Parámetros de entrada:
;	El registro A contiene el número a mostrar.
;
; Entrada:
;	Ninguna.
;
; Salida:
;	Salida de un número en decimal, correspondiente al valor del
;	registro A.
;
; Registros usados:
;	A: número a mostrar
;	B: contador de unidades por divisor (centenas y decenas)
;	X: puntero a los divisores (centenas y decenas)
;	Y: contador de divisores
;	U: bandera de ceros a la izquierda
;
; Registros modificados:
;	Ninguno.
;
; Llamada típica:
;	lda #'H
;	jsr print_numero
; ------------------------------------------------------------------------
		.area _CODE (REL,CON)

; Código -----------------------------------------------------------------
print_numero::
		guarda	^/a,b,x,y,u,cc/	; guardar registros

; Inicialización
		ldu	#0		; bandera para evitar los ceros delanteros
		ldy	#2		; centenas y decenas
		ldx	#print_divisores

; Bucle por los dígitos
1$:		clrb			; cociente

; Bucle por la suma del cociente
2$:		cmpa	,x		; si el número es menor que el divisor,
		blo	6$		; sí, ir a pintar el dígito

		suba	,x		; restamos de número, el divisor
		incb			; contamos una resta más
		bra	2$		; seguir restando

; Comprobar si es un 0
6$:		tstb			; ¿el dígito es 0?
		bne	3$		; no

		cmpu	#0		; ¿hemos pasado los ceros delanteros?
		bne	4$		; sí, hay que pintar ese 0
		bra	5$		; no, no lo pintamos

; Activar bandera de que ya no hay ceros a la izquierda
3$:		leau	1,u		; hemos pasado los ceros delanteros

; Pintar el dígito
4$:		addb	#'0		; pasar a ascii
		stb	STDOUT		; salida a pantalla

; Pasar al siguiente divisor
5$:		leax	1,x		; siguiente divisor
		leay	-1,y		; un dígito menos
		bne	1$

; Pintado de las unidades
		adda	#'0		; pasar unidades a ascii
		sta	STDOUT		; salida de las unidades

; Fin
		recupera_y_regresa	; recuperar registros y regresar

; Datos ------------------------------------------------------------------
print_divisores:.db	100,10		; divisores

; ------------------------------------------------------------------------

		.end	print_numero

; ========================================================================
		.nlist

; ========================================================================
; [ Tab=8. UTF-8. ]
; Código para ensamblador ASxxxx <http://shop-pdp.net/ashtml/asxxxx.htm>
; Entorno de ejecución m6809-run <https://github.com/bcd/exec09>
; ========================================================================
