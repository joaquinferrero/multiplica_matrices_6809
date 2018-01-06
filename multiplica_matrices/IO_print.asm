; ========================================================================
		.title	MultiplicaciOn de matrices 3x3 - Bibliotecas I/O
		.sbttl	ImpresiOn de una cadena de texto

; ========================================================================
		.module	IO_print
		.include "constantes.asm"

		.list (me)

; ========================================================================
; print
;
; Propósito:
;	Salida por pantalla de una cadena de caracteres terminada en 0.
;
; Parámetros de entrada:
;	X: puntero a la zona de la cadena de caracteres.
;
; Entrada:
;	Ninguna.
;
; Salida:
;	Salida por la salida estándar de la cadena de caracteres.
;
; Registros usados:
;	A: carácter a pintar
;
; Registros modificados:
;	Ninguno.
;
; Llamada típica:
;	ldx #mensaje
;	jsr print
; ------------------------------------------------------------------------
		.area _CODE (REL,CON)

; Código -----------------------------------------------------------------
print::
		guarda	^/a,x,cc/	; guardamos registros

		bra	2$

; Bucle para todos los caracteres
1$:
		pinta	reg a		; salida del carácter
2$:
		lda	,x+		; leemos carácter
		bne	1$		; no es 0, lo pintamos

; Fin del bucle
		recupera_y_regresa	; recuperar registros y regresar

; ------------------------------------------------------------------------

		.end	print

; ========================================================================
		.nlist

; ========================================================================
; [ Tab=8. UTF-8. ]
; Código para ensamblador ASxxxx <http://shop-pdp.net/ashtml/asxxxx.htm>
; Entorno de ejecución m6809-run <https://github.com/bcd/exec09>
; ========================================================================
