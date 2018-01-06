; ------------------------------------------------------------------------
		.title	MultiplicaciOn de matrices 3x3 - Programa principal
		.sbttl	Lectura de una secuencia de tres nUmeros

; ========================================================================
		.module IO_read_row
		.include "constantes.asm"

		.list	(me)

; ========================================================================
; leer_fila
;
;	Lee una fila de DIM datos numéricos por la entrada estándar.
;
; Argumentos:
;	Y: puntero a la zona donde guardar los datos.
;
; Entrada:
;	Ninguna.
;
; Salida:
;	A: número de datos numéricos leídos (siempre tres, en este caso)
;
; Registros usados:
;	A: número de datos leídos
;	B: tecla pulsada
;	X: acumulador del último número leído
;	Y: puntero a zona almacén
;	U: contador de dígitos del dato actual
;
; Registros modificados:
;	Ninguno
; ------------------------------------------------------------------------
		.area _CODE (CON,REL)

; Código -----------------------------------------------------------------
leer_fila::
		guarda	^/b,x,y,u/	; guarda registros

		clra			; inicializar contador de datos leídos

; Bucle por los datos
4$:
		ldu	#0		; inicializar contador de dígitos por dato
		ldx	#0		; poner a 0 el acumulador

; Bucle por los dígitos de cada dato
5$:
		ldb	STDIN		; leer del teclado

		cmpb	#'\n		; ¿se pulsó Enter?
		beq	1$		; sí, procesar dato y ver si hay que salir
		cmpb	#'\r		; ¿se pulsó otro tipo de Enter?
		beq	1$		; sí, procesar dato y ver si hay que salir

; Ver si es un dígito
2$:
		cmpb	#'0		; ¿es menor que '0'?
		blo	1$		; sí, luego no es un dígito
		cmpb	#'9		; ¿es mayor que '9'?
		bhi	1$		; sí, luego no es un dígito

; Es un dígito
		exg	x,d		; bajamos acumulador X a D
		lda	#10		; multiplicando = 10
		mul			; acumulador = acumulador * 10
		exg	x,d		; dejamos acumulador en X
		subb	#'0		; pasar a binario el dígito leído
		abx			; acumulador = acumulador + B
		
		leau	1,u		; dígitos leídos++
		bra	5$		; seguir leyendo dígitos

; Es un separador
1$:
		cmpu	#0		; ¿leímos algún dígito antes en este mismo dato?
		beq	3$		; no, ir a ver si hay que salir

; Guardar dato
		exg	x,d		; pasar acumulador (X) a (D) momentaneamente
		stb	,y+		; almacenar acumulador (B tiene la parte baja de X)
		exg	x,d		; recuperamos
		inca			; sumamos un dato leído más

; Fin del bucle
3$:
		cmpa	#DIM		; ¿ya hemos leído todos los datos?
		bne	4$		; no, seguimos leyendo caracteres

; Fin
		recupera_y_regresa	; recuperar registros y regresar

; ------------------------------------------------------------------------

		.end	leer_fila
; ========================================================================
		.nlist

; ========================================================================
; [ Tab=8. UTF-8. ]
; Código para ensamblador ASxxxx <http://shop-pdp.net/ashtml/asxxxx.htm>
; Entorno de ejecución m6809-run <https://github.com/bcd/exec09>
; ========================================================================
