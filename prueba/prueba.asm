	.module prueba

	.area CODE1 (ABS)

	.org 0x0000
	.globl programa
        .globl print_a
        .globl print_b
        .globl print_c

programa:
        lds #0xF000
        jsr print_a
        jsr print_b
        jsr print_c
	clra
	sta 0xFF01

	.area FIJA (ABS)
	.org 0xFFFE
	.word programa
