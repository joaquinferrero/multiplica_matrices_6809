; Programa de ejemplo: hola.asm

        .area PROG (ABS)

        .org 0x100
programa:
	ldx #bufer
bucle1:
	lda 0xFF02
	sta ,x+
	cmpa #'\n
	bne bucle1


        ldx #bufer

bucle:  lda ,x+
        beq acabar
        sta 0xFF00      ; salida por pantalla
        bra bucle

acabar: clra
        sta 0xFF01

cadena: .asciz "Hola, mundo.\n"

bufer:	.ds 80

        .org 0xFFFE     ; Vector de RESET
        .word programa
